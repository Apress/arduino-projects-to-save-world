#include "TF.h"

//**********************************


SdCard card;
Fat16 file;

// store error strings in flash to save RAM
#define error(s) error_P(PSTR(s))

void error_P(const char* str) 
{
  PgmPrint("error: ");
  SerialPrintln_P(str);
  if (card.errorCode) 
  {
    PgmPrint("SD error: ");
    Serial.println(card.errorCode, HEX);
  }
  Serial.println("TF error");
}

void TF_card_init(void) 
{
  //Serial.println();
  pinMode(SD_power_IO,INPUT);//extern power
  //pinMode(SD_power_IO,OUTPUT);
  //digitalWrite(SD_power_IO,HIGH);//power up SD card
  //delay(10);
  //PgmPrintln("Type any character to start");

  // initialize the SD card
  if (!card.init()) error("card.init");

  // initialize a FAT16 volume
  if (!Fat16::init(&card)) error("Fat16::init");
  // clear write error
  file.writeError = false;
}

//=======================================
void store_tmp102_data(void)
{
  file.print("tep102_temperature = ");
  file.println(convertedtemp);
}

//========================================
void store_Battery_data(void)
{
  switch (charge_status) 
  {
  case 0x01:    
    {
      file.print("CH_sleeping");
      break;
    }
  case 0x02:    
    {
      file.print("CH_complete");
      break;
    }
  case 0x04:    
    {
      file.print("CH_charging");
      break;
    }
  case 0x08:    
    {
      file.print("CH_bat_not_exist");
      break;
    }
  }
  file.print(" battery voltage = ");
  file.println(bat_voltage);
}

//=============================
void store_RTC_time(void)
{
  /*  unsigned char RX8025_time[7]=
   {
   0x15,0x44,0x14,0x03,0x03,0x11,0x10 //second, minute, hour, week, date, month, year, BCD format
   };
   */

  file.print(year,DEC);
  file.print("/");
  file.print(month,DEC);
  file.print("/");
  file.print(date,DEC);
  switch(week)
  {
  case 0x00:
    {
      file.print("/Sunday  ");   
      break;
    }
  case 0x01:
    {
      file.print("/Monday  ");
      break;
    }
  case 0x02:
    {
      file.print("/Tuesday  ");
      break;
    }
  case 0x03:
    {
      file.print("/Wednesday  ");
      break;
    }
  case 0x04:
    {
      file.print("/Thursday  ");
      break;
    }
  case 0x05:
    {
      file.print("/Friday  ");
      break;
    }
  case 0x06:
    {
      file.print("/Saturday  ");
      break;
    }
  }
  file.print(hour,DEC);
  file.print(":");
  file.print(minute,DEC);
  file.print(":");
  file.println(second,DEC);
}

//======================================
void write_data_to_TF(void)
{
  // O_CREAT - create the file if it does not exist
  // O_APPEND - seek to the end of the file prior to each write
  // O_WRITE - open for write
  if (!file.open(name, O_CREAT | O_APPEND | O_WRITE)) 
  {
    error("open");
  }


  store_RTC_time();
  store_tmp102_data();
  store_Battery_data();

  file.println("--------------next--data---------------");
  file.println();

  if (file.writeError) 
  {
    error("write");
  }
  if (!file.close()) 
  {
    error("close");
  }
}

















