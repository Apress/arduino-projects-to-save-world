#ifndef myRX8025_h
#define myRX8025_h

//=================================================
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
#define RX8025_AW_WEEK  10  // A
#define RX8025_AD_MIN   11  // B
#define RX8025_AD_HR    12  // C
#define RX8025_AD_RES   13  // D Reserved! DONT OVERWRITE!
#define RX8025_CTL1     14  // E
#define RX8025_CTL2     15  // F

//=================================================
extern unsigned char second;          // 0
extern unsigned char minute;          // 1
extern unsigned char hour;            // 2
extern unsigned char weekday;            // 3
extern unsigned char day;            // 4
extern unsigned char month;           // 5
extern unsigned char year;            // 6
extern unsigned char Doffset;          // 7
extern unsigned char alarmW_minute;   // 8
extern unsigned char alarmW_hour;     // 9
extern unsigned char alarmW_weekday;  // 10 A
extern unsigned char alarmD_minute;   // 11 B
extern unsigned char alarmD_hour;     // 12 C
extern unsigned char RX8025_Reserved; // 13 D Leave it alone!
extern unsigned char RX8025_control_1;// 14 E
extern unsigned char RX8025_control_2;// 15 F

//=================================================
extern unsigned char RX8025_all[16];
extern unsigned char RX8025_time[7];
extern unsigned char RX8025_alarmW[3];
extern unsigned char RX8025_alarmD[2];
extern unsigned char RX8025_Control[2];

//=================================================
void RX8025_init(void);
void setRtcTime(void);
void getRtcTime(void);
void getRtcAll(void);
void setRtcAlarmW(void);
void setRtcAlarmD(void);
void setRtcCtrl(void);
void RtcClearFlags(void);

//=================================================
#endif
