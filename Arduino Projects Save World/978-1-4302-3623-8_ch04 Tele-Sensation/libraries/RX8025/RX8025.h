#ifndef RX8025_h
#define RX8025_h

#define RX8025_SEC      0
#define RX8025_MIN      1
#define RX8025_HR       2
#define RX8025_WEEK     3
#define RX8025_DATE     4
#define RX8025_MTH      5
#define RX8025_YR       6
#define RX8025_Doffset  7
#define RX8025_AW_MIN   8
#define RX8025_AW_HR    9
#define RX8025_AW_WEEK  10
#define RX8025_AD_MIN   11
#define RX8025_AD_HR    12
#define RX8025_CTL1     14
#define RX8025_CTL2     15

extern unsigned char RX8025_time[7];

extern unsigned char hour;
extern unsigned char minute;
extern unsigned char second;
extern unsigned char week;
extern unsigned char year;
extern unsigned char month;
extern unsigned char date;


void RX8025_init(void);
void getRtcTime(void);
void setRtcTime(void);

#endif
