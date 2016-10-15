#include <Wire.h>
#include "RX8025.h"
//********************************************************************

//===============================================
#define  RX8025_address  0x32

unsigned char RX8025_Control[2]=
{
  0x20,0x00
};

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
uint8_t bcd2bin (uint8_t val) 
{ 
  return val - 6 * (val >> 4); 
}

uint8_t bin2bcd (uint8_t val) 
{ 
  return val + 6 * (val / 10); 
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
  date   = bcd2bin(RX8025_time[4]&0x3f);
  week   = bcd2bin(RX8025_time[3]&0x07);
  hour   = bcd2bin(RX8025_time[2]&0x3f);
  minute = bcd2bin(RX8025_time[1]&0x7f);
  second = bcd2bin(RX8025_time[0]&0x7f);
}

//===============================================
void RX8025_init(void)
{
  Wire.begin();
  Wire.beginTransmission(RX8025_address);//clear power on reset flag, set to 24hr format
  Wire.send(0xe0);
  for(unsigned char i=0; i<2; i++)
  {
    Wire.send(RX8025_Control[i]);
  }
  Wire.endTransmission();
  //setRtcTime();
}







