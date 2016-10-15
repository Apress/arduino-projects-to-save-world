#ifndef tmp102_h
#define tmp102_h

//**********************************************
#include <WProgram.h>
#include <Wire.h>
#define TMP102_I2C_ADDRESS 72 /* This is the I2C address for our chip.
This value is correct if you tie the ADD0 pin to ground. See the datasheet for some other values. */

/*
 Table 1. Pointer Register Byte
 P7 P6 P5 P4 P3 P2    P1 P0
 0  0  0  0  0  0  Register Bits
 
 P1 P0 REGISTER
 0  0  Temperature Register (Read Only)
 0  1  Configuration Register (Read/Write)
 1  0  T LOW Register (Read/Write)
 1  1  T HIGH Register (Read/Write)
 */

//==============================================
extern float convertedtemp;
extern int tmp102_val;
//==============================================
void tmp102_init(void);
void getTemp102(void);
//**********************************************

#endif



