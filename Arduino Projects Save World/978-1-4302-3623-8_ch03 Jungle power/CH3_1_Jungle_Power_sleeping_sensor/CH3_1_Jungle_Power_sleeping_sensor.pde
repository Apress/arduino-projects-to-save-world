/*
 * sketch name   : Rtc8564AttachInterruptSleep_Analogs
 * summary       : RTC8564で定周期タイマー割り込み & スリープ
 * releases      : 2011/3/15
 */

#include <Wire.h>
#include <Rtc8564AttachInterrupt.h>
#include <Sleep.h>

/* Project variables */
int A0raw, A1raw, A2raw, A3raw;


/* RTC */
#define RTC_SEC  0x00  	// seconds
#define RTC_MIN  0x18  	// minutes
#define RTC_HOUR 0x23  	// hour in 24hr format
#define RTC_DAY  0x15  	// day of the month
#define RTC_WEEK 0x02  	// day of the week (00:Sunday – 06:Saturday)
#define RTC_MON  0x03  	// month
#define RTC_YEAR 0x11  	// year
byte date_time[7] = {
   RTC_SEC
  ,RTC_MIN
  ,RTC_HOUR
  ,RTC_DAY
  ,RTC_WEEK
  ,RTC_MON
  ,RTC_YEAR
};

/* Check the power reset flag – this will decide if we should reset the clock or not */
boolean init_flg = false;

/* Measurement interval – how long do we want the Arduino to sleep? */
#define RTC_INTERRUPT_TERM 10

/* What is the interval? 0:seconds, 1:minutes */
#define RTC_INTERRUPT_MODE 0

/* Which pin is the clock interupt connected to? We only have a few options */
#define RTC_INTERRUPT_PIN  2

void setup() {
  Serial.begin(9600);
  
  // Date and Time initialization
  Rtc.initDatetime(date_time);
  
  // RTC start
  Rtc.begin();
  
  // Check periodic interrupt time
  if (!Rtc.isInterrupt()) {
    
    // if so, set interrupt
    Rtc.syncInterrupt(RTC_INTERRUPT_MODE, RTC_INTERRUPT_TERM);
  }
  
  // interrupt setting
  pinMode(RTC_INTERRUPT_PIN, INPUT);
  digitalWrite(RTC_INTERRUPT_PIN, HIGH);
}

void loop() {
  
  // Upon waking up, we should check to see if there was a power event
  if (init_flg) ReadRTC();
  init_flg = true;
  
  // stuff to do before sleep
  // read the pins
  A0raw = analogRead(0);
  A1raw = analogRead(1);
  A2raw = analogRead(2);
  A3raw = analogRead(3);
  // print it up
  Serial.print(A0raw);
  Serial.print(" : ");
  Serial.print(A1raw);
  Serial.print(" : ");
  Serial.print(A2raw);
  Serial.print(" : ");
  Serial.println(A3raw);
  Serial.println();
  

  // Sleep time! Dont put anything else in the main loop after this!
  // Delay required to assure wake cleanly
  delay(100);
  SleepClass::powerDownAndWakeupExternalEvent(0);
}

void ReadRTC()
{
  Rtc.available();
  Serial.print(0x2000 + Rtc.years(), HEX);
  Serial.print("/");
  Serial.print(Rtc.months(), HEX);
  Serial.print("/");
  Serial.print(Rtc.days(), HEX);
  Serial.print(" ");
  Serial.print(Rtc.hours(), HEX);
  Serial.print(":");
  Serial.print(Rtc.minutes(), HEX);
  Serial.print(":");
  Serial.print(Rtc.seconds(), HEX);
  Serial.print(" ");
  Serial.println((int)Rtc.weekdays());
}

