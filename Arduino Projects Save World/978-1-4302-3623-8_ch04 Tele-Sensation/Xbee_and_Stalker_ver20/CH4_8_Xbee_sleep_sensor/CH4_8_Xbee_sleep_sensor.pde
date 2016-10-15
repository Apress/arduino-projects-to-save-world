#include <avr/sleep.h>
#include "myRX8025.h"
#include "tmp102.h"
#include "TF.h"
#include "Battery.h"
#include <Wire.h>
#include <Fat16.h>
#include <Fat16util.h>

//**************************************
// RX8025 stuff
unsigned char second = 0;
unsigned char minute = 0;
unsigned char hour = 0;
unsigned char weekday = 0;
unsigned char day = 0;
unsigned char month = 0;
unsigned char year = 0;
unsigned char Doffset = 0;
unsigned char alarmD_hour = 0;
unsigned char alarmD_minute = 0;
unsigned char alarmW_weekday = 0;
unsigned char alarmW_hour = 0;
unsigned char alarmW_minute = 0;
unsigned char RX8025_control_1 = 0;
unsigned char RX8025_control_2 = 0;
unsigned char RX8025_Reserved;

unsigned char RX8025_time[7]=
{
//second, minute, hour, week, date, month, year, BCD format
  0x00,0x45,0x14,0x03,0x28,0x05,0x11 
};
  
unsigned char RX8025_alarmD[2]=  // daily alarm
{
  0x15,0x12  // minute, hour
};

unsigned char RX8025_alarmW[3]=
{
  0x45,0x07,0x06    // minute, hour, weekday
};

unsigned char RX8025_Control[2]=
{
  0x25,0x00  // E - Set 24 hour clock, 1-minute interrupts
             // F - clear all flags
};  // end RX8025 stuff

//======================================
// Sleep stuff
int wakePin = 2;                 // pin used for waking up
int beeSleep = 4;                // set high to sleep, low to wake up
int beeSleepStatus = 5;          // gets the Bee sleep status

//======================================
// program stuff
int LEDpin = 8;
float convertedtemp; /* We then need to multiply our two bytes by 
                        a scaling factor, mentioned in the datasheet. */
int tmp102_val; /* an int is capable of storing two bytes, this is 
                   where we "chuck" the two bytes together. */
char name[] = "data.log";     // file name in TF card root dir 
unsigned int bat_read;        //analog read battery voltage
float bat_voltage;            //battery voltage
unsigned char charge_status;  //battery charge status


//======================================
//======================================
void wakeUpNow()        // here the interrupt is handled after wakeup
{
  // execute code here after wake-up before returning to the loop() function
  digitalWrite(LEDpin, HIGH);
  digitalWrite(beeSleep, LOW); // wake the bee
}

//======================================
void setup(void)
{
  Wire.begin();
  Serial.begin(9600);
  RX8025_init();
  //  TF_card_init();
  tmp102_init();
  Battery_init();
  pinMode(LEDpin, OUTPUT);//LED pin set to OUTPUT
  pinMode(wakePin, INPUT);  // setup interrupt pin
  pinMode(beeSleep, OUTPUT);
  pinMode(beeSleepStatus, INPUT);
  attachInterrupt(0, wakeUpNow, LOW); // use interrupt 0 (pin 2) and run function
                                      // wakeUpNow when pin 2 gets LOW
  digitalWrite(LEDpin, HIGH);
  digitalWrite(beeSleep, LOW); // wake the bee
}

//======================================
void loop(void)
{
  while(digitalRead(beeSleepStatus) == LOW) {
    break;
  }

  RtcClearFlags();
  getRtcTime();
  getTemp102();
  Battery_charge_status();
  Battery_voltage_read();  
  //  write_data_to_TF();
 
  //debug data
  print_data();
  Serial_Command();  // pending return commands?

  sleepNow();  // nighty night
}


//======================================
void print_data(void)
{
  Serial.print(month,DEC);
  Serial.print(",");
  Serial.print(day,DEC);
  Serial.print(",");
  Serial.print(2000 + year,DEC);
  Serial.print(",");
  Serial.print(hour,DEC);
  Serial.print(",");
  Serial.print(minute,DEC);
  Serial.print(",");
  Serial.print(second,DEC);
  Serial.print(",");
  Serial.print(bat_voltage);
  Serial.print(",");
  Serial.print(convertedtemp);
  Serial.println("\0");
 }

//======================================
void Serial_Command(void)
{
  if(Serial.available()==3)
  {
    if(Serial.read()=='c')
    {
      if(Serial.read()=='c')
      {
        if(Serial.read()=='c')
        {
          Serial.println("Got Serial data");
        }
      }
    }
  }
  else
  {
    Serial.flush();
  }
}

//======================================
void sleepNow()         // here we put the arduino to sleep

{
  digitalWrite(LEDpin, LOW);
  digitalWrite(beeSleep, HIGH);
    /* Now is the time to set the sleep mode. In the Atmega8 datasheet
     * http://www.atmel.com/dyn/resources/prod_documents/doc2486.pdf on page 35
     * there is a list of sleep modes which explains which clocks and 
     * wake up sources are available in which sleep mode.
     *
     * In the avr/sleep.h file, the call names of these sleep modes are to be found:
     *
     * The 5 different modes are:
     *     SLEEP_MODE_IDLE         -the least power savings 
     *     SLEEP_MODE_ADC
     *     SLEEP_MODE_PWR_SAVE
     *     SLEEP_MODE_STANDBY
     *     SLEEP_MODE_PWR_DOWN     -the most power savings
     *
     * For now, we want as much power savings as possible, so we 
     * choose the according 
     * sleep mode: SLEEP_MODE_PWR_DOWN
     * 
     */  
    set_sleep_mode(SLEEP_MODE_PWR_DOWN);   // sleep mode is set here
    sleep_enable();          // enables the sleep bit in the mcucr register
                             // so sleep is possible. just a safety pin 
    /* Now it is time to enable an interrupt. We do it here so an 
     * accidentally pushed interrupt button doesn't interrupt 
     * our running program. if you want to be able to run 
     * interrupt code besides the sleep function, place it in 
     * setup() for example.
     * 
     * In the function call attachInterrupt(A, B, C)
     * A   can be either 0 or 1 for interrupts on pin 2 or 3.   
     * 
     * B   Name of a function you want to execute at interrupt for A.
     *
     * C   Trigger mode of the interrupt pin. can be:
     *             LOW        a low level triggers
     *             CHANGE     a change in level triggers
     *             RISING     a rising edge of a level triggers
     *             FALLING    a falling edge of a level triggers
     *
     * In all but the IDLE sleep modes only LOW can be used.
     */
    attachInterrupt(0,wakeUpNow, LOW); // use interrupt 0 (pin 2) and run function
                                       // wakeUpNow when pin 2 gets LOW 
    delay(500);              // keeps serial output clean after waking up.
    sleep_mode();            // here the device is actually put to sleep!!
                             // THE PROGRAM CONTINUES FROM HERE AFTER WAKING UP
    sleep_disable();         // first thing after waking from sleep:
                             // disable sleep...
    detachInterrupt(0);      // disables interrupt 0 on pin 2 so the 
                             // wakeUpNow code will not be executed 
                             // during normal running time.                    
}

