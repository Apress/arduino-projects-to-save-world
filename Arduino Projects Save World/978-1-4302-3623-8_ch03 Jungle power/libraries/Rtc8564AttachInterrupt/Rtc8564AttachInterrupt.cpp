extern "C" {
  #include <stdlib.h>
  #include <string.h>
  #include <inttypes.h>
}
#include <WConstants.h>
#include <Wire.h>
#include "Rtc8564AttachInterrupt.h"

#define RTC8564_SLAVE_ADRS  (0xA2 >> 1)
#define BCD2Decimal(x)    (((x>>4)*10)+(x&0xf))

// Constructors ////////////////////////////////////////////////////////////////

Rtc8564AttachInterrupt::Rtc8564AttachInterrupt()
  : _seconds(0), _minutes(0), _hours(0), _days(0), _weekdays(0), _months(0), _years(0), _century(0)
{
}

void Rtc8564AttachInterrupt::init(void)
{
  delay(1000);
  Wire.beginTransmission(RTC8564_SLAVE_ADRS);
  Wire.send(0x00);  // write reg addr 00
  Wire.send(0x20);  // 00 Control 1, STOP=1
  Wire.send(0x00);  // 01 Control 2
  Wire.send(0x00);  // 02 Seconds
  Wire.send(0x00);  // 03 Minutes
  Wire.send(0x09);  // 04 Hours
  Wire.send(0x01);  // 05 Days
  Wire.send(0x01);  // 06 Weekdays
  Wire.send(0x01);  // 07 Months
  Wire.send(0x01);  // 08 Years
  Wire.send(0x00);  // 09 Minutes Alarm
  Wire.send(0x00);  // 0A Hours Alarm
  Wire.send(0x00);  // 0B Days Alarm
  Wire.send(0x00);  // 0C Weekdays Alarm
  Wire.send(0x00);  // 0D CLKOUT
  Wire.send(0x00);  // 0E Timer control
  Wire.send(0x00);  // 0F Timer
  Wire.send(0x00);  // 00 Control 1, STOP=0
  Wire.endTransmission();
}

// Public Methods //////////////////////////////////////////////////////////////

void Rtc8564AttachInterrupt::begin(void)
{
  Wire.begin();
  if(isvalid() == false) {
    
    init();
    
    if (isInitDatetime()) {
      byte date_time[7];
      date_time[0] = _seconds;
      date_time[1] = _minutes;
      date_time[2] = _hours;
      date_time[3] = _days;
      date_time[4] = _weekdays;
      date_time[5] = _months;
      date_time[6] = _years;
      sync(date_time);
    }
  }
}

void Rtc8564AttachInterrupt::beginWithoutIsValid(void)
{
  Wire.begin();
  
  init();
  
  if (isInitDatetime()) {
    byte date_time[7];
    date_time[0] = _seconds;
    date_time[1] = _minutes;
    date_time[2] = _hours;
    date_time[3] = _days;
    date_time[4] = _weekdays;
    date_time[5] = _months;
    date_time[6] = _years;
    sync(date_time);
  }
}

void Rtc8564AttachInterrupt::initDatetime(uint8_t date_time[])
{
  _seconds  = (date_time[0]) ? date_time[0] : 0x00;
  _minutes  = (date_time[1]) ? date_time[1] : 0x00;
  _hours    = (date_time[2]) ? date_time[2] : 0x09;
  _days     = (date_time[3]) ? date_time[3] : 0x01;
  _weekdays = (date_time[4]) ? date_time[4] : 0x01;
  _months   = (date_time[5]) ? date_time[5] : 0x01;
  _years    = (date_time[6]) ? date_time[6] : 0x01;
}

bool Rtc8564AttachInterrupt::isInitDatetime(void)
{
  bool flg = false;
  if ((_seconds  & 0x00) != 0x00) flg = true;
  if ((_minutes  & 0x00) != 0x00) flg = true;
  if ((_hours    & 0x09) != 0x09) flg = true;
  if ((_days     & 0x01) != 0x01) flg = true;
  if ((_weekdays & 0x01) != 0x01) flg = true;
  if ((_months   & 0x01) != 0x01) flg = true;
  if ((_years    & 0x01) != 0x01) flg = true;
  return flg;
}

void Rtc8564AttachInterrupt::sync(uint8_t date_time[],uint8_t size)
{
  Wire.beginTransmission(RTC8564_SLAVE_ADRS);
  Wire.send(0x00);
  Wire.send(0x20);
  Wire.endTransmission();
  
  Wire.beginTransmission(RTC8564_SLAVE_ADRS);
  Wire.send(0x02);
  Wire.send(date_time, size);
  Wire.endTransmission();
  
  Wire.beginTransmission(RTC8564_SLAVE_ADRS);
  Wire.send(0x00);
  Wire.send(0x00);
  Wire.endTransmission();
}

void Rtc8564AttachInterrupt::syncInterrupt(unsigned int mode, unsigned long term)
{
  Wire.beginTransmission(RTC8564_SLAVE_ADRS);
  Wire.send(0x01);
  Wire.send(0x11);
  Wire.endTransmission();
  
  byte buf[2];
  if (mode == 1) {
    buf[0] = 0x83;
  } else {
    buf[0] = 0x82;
  }
  buf[1] = term;
  Wire.beginTransmission(RTC8564_SLAVE_ADRS);
  Wire.send(0x0E);
  Wire.send(buf, 2);
  Wire.endTransmission();
}

bool Rtc8564AttachInterrupt::available(void)
{
  uint8_t buff[7];
  
  Wire.beginTransmission(RTC8564_SLAVE_ADRS);
  Wire.send(0x02);
  Wire.endTransmission();
  
  Wire.requestFrom(RTC8564_SLAVE_ADRS, 7);
  
  for(int i=0; i<7; i++){
    if(Wire.available()){
      buff[i] = Wire.receive();
    }
  }
  
  _seconds  = buff[0] & 0x7f;
  _minutes  = buff[1] & 0x7f;
  _hours    = buff[2] & 0x3f;
  _days     = buff[3] & 0x3f;
  _weekdays = buff[4] & 0x07;
  _months   = buff[5] & 0x1f;
  _years    = buff[6];
  _century  = (buff[5] & 0x80) ? 1 : 0;
  return (buff[0] & 0x80 ? false : true);
}

bool Rtc8564AttachInterrupt::isvalid(void)
{
  Wire.beginTransmission(RTC8564_SLAVE_ADRS);
  Wire.send(0x02);
  Wire.endTransmission();
  Wire.requestFrom(RTC8564_SLAVE_ADRS, 1);
  if(Wire.available()){
    uint8_t buff = Wire.receive();
    return (buff & 0x80 ? false : true);
  }
  return false;
}

bool Rtc8564AttachInterrupt::isInterrupt(void)
{
  Wire.beginTransmission(RTC8564_SLAVE_ADRS);
  Wire.send(0x01);
  Wire.endTransmission();
  Wire.requestFrom(RTC8564_SLAVE_ADRS, 1);
  if(Wire.available()){
    return ((Wire.receive() & 0x04) != 0x04 ? false : true);
  }
  return false;
}

uint8_t Rtc8564AttachInterrupt::seconds(uint8_t format) const {
  if(format == Decimal) return BCD2Decimal(_seconds);
  return _seconds;
}

uint8_t Rtc8564AttachInterrupt::minutes(uint8_t format) const {
  if(format == Decimal) return BCD2Decimal(_minutes);
  return _minutes;
}

uint8_t Rtc8564AttachInterrupt::hours(uint8_t format) const {
  if(format == Decimal) return BCD2Decimal(_hours);
  return _hours;
}

uint8_t Rtc8564AttachInterrupt::days(uint8_t format) const {
  if(format == Decimal) return BCD2Decimal(_days);
  return _days;
}

uint8_t Rtc8564AttachInterrupt::weekdays() const {
  return _weekdays;
}

uint8_t Rtc8564AttachInterrupt::months(uint8_t format) const {
  if(format == Decimal) return BCD2Decimal(_months);
  return _months;
}

uint8_t Rtc8564AttachInterrupt::years(uint8_t format) const {
  if(format == Decimal) return BCD2Decimal(_years);
  return _years;
}

bool Rtc8564AttachInterrupt::century() const {
  return _century;
}


// Preinstantiate Objects //////////////////////////////////////////////////////

Rtc8564AttachInterrupt Rtc = Rtc8564AttachInterrupt();
