#include <Wire.h>
#include <Rtc8564AttachInterrupt.h>
#include <Sleep.h>
#include <chibi.h>

// Project variables
int A0raw, A1raw;
const int bufSize = 5;
byte XmitBuf[bufSize]; 

/* RTC preset clock*/
#define RTC_SEC  0x00  // seconds
#define RTC_MIN  0x18  // minutes
#define RTC_HOUR 0x23  // hours
#define RTC_DAY  0x15  // day
#define RTC_WEEK 0x02  // weekday(00:sunday 〜 06:saturday)
#define RTC_MON  0x03  // month
#define RTC_YEAR 0x11  // year
byte date_time[7] = {
   RTC_SEC
  ,RTC_MIN
  ,RTC_HOUR
  ,RTC_DAY
  ,RTC_WEEK
  ,RTC_MON
  ,RTC_YEAR
};

/* clock reset flag */
boolean init_flg = false;

/* countdown timer period */
#define RTC_INTERRUPT_TERM 10

/* Arduino wake interupt pin */
#define RTC_INTERRUPT_PIN  2

/* countdowntimer mode 0:seconds/1:minutes */
#define RTC_INTERRUPT_MODE 0

void setup() {
  Serial.begin(9600);
  chibiInit();
  
  // set the clock
  Rtc.initDatetime(date_time);
  
  // RTC start
  Rtc.begin();
  
  // check for interrupt
  if (!Rtc.isInterrupt()) {
    
    // set the interrupt
    Rtc.syncInterrupt(RTC_INTERRUPT_MODE, RTC_INTERRUPT_TERM);
  }
  
  // prepare the interrupt pin
  pinMode(RTC_INTERRUPT_PIN, INPUT);
  digitalWrite(RTC_INTERRUPT_PIN, HIGH);
}

void loop() {
  
  // check the flag and read the clock data
  if (init_flg) ReadRTC();
  init_flg = true;
  
  // stuff to do before sleep
  // read the pins
 A0raw = analogRead(A0);
 A1raw = analogRead(A1);
 Serial.print(A0raw);
 Serial.print(" ");
 Serial.println(A1raw);
 
 memcpy(XmitBuf, &A0raw, 2);
 
 chibiSleepRadio(0);  // wake up the radio
 delay(100);
 chibiTx(BROADCAST_ADDR, XmitBuf, bufSize);
 chibiSleepRadio(1);  // go back to sleep

  // Arduino Sleep time! Dont put anything else in the main loop after this!  
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

