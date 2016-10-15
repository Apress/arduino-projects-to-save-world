#include <Wire.h>
#include <Rtc8564AttachInterrupt.h>
#include <Sleep.h>
#include <chibi.h>

/* Project variables */
const int bufSize = 30;
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
  chibiInit(); 
  Rtc.initDatetime(date_time);  // set the clock
  Rtc.begin();  // RTC start
  if (!Rtc.isInterrupt()) {    // check for interrupt
    // set the interrupt
    Rtc.syncInterrupt(RTC_INTERRUPT_MODE, RTC_INTERRUPT_TERM);
  }
  // prepare the interrupt pin
  pinMode(RTC_INTERRUPT_PIN, INPUT);
  digitalWrite(RTC_INTERRUPT_PIN, HIGH);
}

void loop() {
  
 PrepMsg();
 WakeRadio();
 Transmit();
   // Arduino Sleep time! Dont put anything else in the main loop after this! 
 GoToSleep();
}

void PrepMsg()
{
  Rtc.available();
  char temp[bufSize];
  sprintf(temp, "%x,%x,%x,%x,%x,%x,%d,%d", 
   Rtc.months(), Rtc.days(), (0x2000 + Rtc.years()), 
   Rtc.hours(), Rtc.minutes(), Rtc.seconds(),
   analogRead(A0), analogRead(A1));
  memcpy(XmitBuf, temp, bufSize);
}

void WakeRadio()
{
  // wake the radio, transmit, then put it back to sleep
 chibiSleepRadio(0);  // wake up the radio
 delay(100);                 // adjust min wakeup time before xmit
}
 
void Transmit()
{
  chibiTx(BROADCAST_ADDR, XmitBuf, bufSize);
}
 
void GoToSleep()
{
  chibiSleepRadio(1);  // Sleep the radio
  delay(100);                 // adjust min radio shutdown time
  SleepClass::powerDownAndWakeupExternalEvent(0);
}


