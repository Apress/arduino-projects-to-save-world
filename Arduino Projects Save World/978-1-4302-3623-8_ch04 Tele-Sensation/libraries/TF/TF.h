#ifndef TF_h
#define TF_h

//**********************************************
/*
 * Append Example
 *
 * This sketch shows how to use open for append and the Arduino Print class
 * with Fat16.
 */
#include <Fat16.h>
#include <Fat16util.h> // use functions to print strings from flash memory


#define SD_power_IO  4

//==============================================
extern char name[];//file name in TF card root dir

extern float convertedtemp;
extern int tmp102_val;

extern float bat_voltage;
extern unsigned int bat_read;
extern unsigned char charge_status;

extern unsigned char hour;
extern unsigned char minute;
extern unsigned char second;
extern unsigned char week;
extern unsigned char year;
extern unsigned char month;
extern unsigned char date;
extern unsigned char RX8025_time[7];
//==============================================
void TF_card_init(void);
void write_data_to_TF(void);
//**********************************************

#endif
