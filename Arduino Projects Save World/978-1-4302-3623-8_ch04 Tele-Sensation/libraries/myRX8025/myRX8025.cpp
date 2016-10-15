#include <Wire.h>
#include "myRX8025.h"

//===============================================
#define  RX8025_address  0x32

//===============================================
uint8_t bcd2bin (uint8_t val) 
{ 
  return val - 6 * (val >> 4); 
}

uint8_t bin2bcd (uint8_t val) 
{ 
  return val + 6 * (val / 10); 
}

//===============================================
void RX8025_init(void)
{
  setRtcCtrl();
  setRtcTime();
}

//===============================================
void setRtcTime(void)
{
  Wire.beginTransmission(RX8025_address);
  Wire.send(0x00);
  for(unsigned char i=0; i<7; i++)
  {
    Wire.send(RX8025_time[i]);
  }
  Wire.endTransmission();
}

//===============================================
void getRtcTime(void)
{
  unsigned char i=0;
  Wire.beginTransmission(RX8025_address);
  Wire.send(0x00);
  Wire.endTransmission();//
  Wire.requestFrom(RX8025_address,8);
  RX8025_time[i]= Wire.receive();//not use
  while(Wire.available())
  { 
    RX8025_time[i]= Wire.receive();
    i++;
  }
  Wire.endTransmission();//

  year   = bcd2bin(RX8025_time[6]&0xff);
  month  = bcd2bin(RX8025_time[5]&0x1f);
  day   = bcd2bin(RX8025_time[4]&0x3f);
  weekday   = bcd2bin(RX8025_time[3]&0x07);
  hour   = bcd2bin(RX8025_time[2]&0x3f);
  minute = bcd2bin(RX8025_time[1]&0x7f);
  second = bcd2bin(RX8025_time[0]&0x7f);
}

//===============================================
void getRtcAll(void)
{
  unsigned char i=0;
  unsigned char RX8025_all[16];
  Wire.beginTransmission(RX8025_address);
  Wire.send(0x00);
  Wire.endTransmission();//
  Wire.requestFrom(RX8025_address,16);
  RX8025_all[i]= Wire.receive();//not use
  while(Wire.available())
  { 
    RX8025_all[i]= Wire.receive();
    i++;
  }
  Wire.endTransmission();
  RX8025_control_2 = bcd2bin(RX8025_all[15]);
  RX8025_control_1 = bcd2bin(RX8025_all[14]); 
  RX8025_Reserved  = bcd2bin(RX8025_all[13]);
  alarmD_hour      = bcd2bin(RX8025_all[12]&0x3f);
  alarmD_minute    = bcd2bin(RX8025_all[11]&0x7f);
  alarmW_weekday   = bcd2bin(RX8025_all[10]&0x07);
  alarmW_hour      = bcd2bin(RX8025_all[9]&0x3f);
  alarmW_minute    = bcd2bin(RX8025_all[8]&0x7f);
  Doffset          = bcd2bin(RX8025_all[7]);
  year             = bcd2bin(RX8025_all[6]&0xff);
  month            = bcd2bin(RX8025_all[5]&0x1f);
  day              = bcd2bin(RX8025_all[4]&0x3f);
  weekday          = bcd2bin(RX8025_all[3]&0x07);
  hour             = bcd2bin(RX8025_all[2]&0x3f);
  minute           = bcd2bin(RX8025_all[1]&0x7f);
  second           = bcd2bin(RX8025_all[0]&0x7f);
}

//===============================================
void setRtcAlarmD(void)
{
  Wire.beginTransmission(RX8025_address);
  Wire.send(0xB0);
  for(unsigned char i=0; i<2; i++)
  {
    Wire.send(RX8025_alarmD[i]);
  }
  Wire.endTransmission();
}

//===============================================
void setRtcAlarmW(void)
{
  Wire.beginTransmission(RX8025_address);
  Wire.send(0x80);
  for(unsigned char i=0; i<3; i++)
  {
    Wire.send(RX8025_alarmW[i]);
  }
  Wire.endTransmission();
}

//===============================================
void setRtcCtrl(void)
{
Wire.beginTransmission(RX8025_address);
  Wire.send(0xE0);
  for(unsigned char i=0; i<2; i++)
  {
    Wire.send(RX8025_Control[i]);
  }
  Wire.endTransmission();
}

//===============================================
void RtcClearFlags(void)
{
  Wire.beginTransmission(RX8025_address);
  Wire.send(0xF0);
  Wire.send(RX8025_Control[1]);
  Wire.endTransmission();
}
