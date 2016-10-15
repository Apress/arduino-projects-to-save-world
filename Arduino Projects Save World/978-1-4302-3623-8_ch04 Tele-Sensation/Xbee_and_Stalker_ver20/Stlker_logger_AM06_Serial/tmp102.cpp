#include "tmp102.h"

//**********************************
void tmp102_init(void) 
{
  Wire.begin(); // start the I2C library
}


void getTemp102(void)
{
  unsigned char firstbyte; 
  unsigned char secondbyte; //these are the bytes we read from the TMP102 temperature registers
  unsigned int complement;// = 0xe70 - 1

  //float correctedtemp; 
  // The sensor overreads (?) 

  /* Reset the register pointer (by default it is ready to read temperatures)
   You can alter it to a writeable register and alter some of the configuration - 
   the sensor is capable of alerting you if the temperature is above or below a specified threshold. */

  Wire.beginTransmission(TMP102_I2C_ADDRESS); //Say hi to the sensor. 
  Wire.send(0x00);
  Wire.endTransmission();
  Wire.requestFrom(TMP102_I2C_ADDRESS, 2);
  Wire.endTransmission();

  firstbyte = (Wire.receive()); 
  /*read the TMP102 datasheet - here we read one byte from
   each of the temperature registers on the TMP102*/
  secondbyte = (Wire.receive()); 
  /*The first byte contains the most significant bits, and 
   the second the less significant */
  tmp102_val = ((firstbyte) << 4);  
  /* MSB */
  tmp102_val |= (secondbyte >> 4);    
  /* LSB is ORed into the second 4 bits of our byte.
   Bitwise maths is a bit funky, but there's a good tutorial on the playground*/

  /*
   
   Serial.println();
   Serial.print("complement1 = 0x");
   Serial.println(complement,HEX);
   
   complement ^= 0xfff;
   
   Serial.println();
   Serial.print("complement2 = 0x");
   Serial.println(complement,HEX);
   */

  if(tmp102_val&0x800)//negative temperature
  {
    complement = tmp102_val - 1;
    complement ^= 0xfff;
    convertedtemp = complement * 0.0625 * (-1);
  }
  else
  {
    convertedtemp = tmp102_val * 0.0625;
  }
  //correctedtemp = convertedtemp - 5; 
  /* See the above note on overreading */
}





