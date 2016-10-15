#include <chibi.h>
byte buf[CHB_MAX_PAYLOAD];
 
void setup()
{
  Serial.begin(57600);
  chibiInit();
}
 
void loop()
{
  if (chibiDataRcvd() == true)
  {
    unsigned int rcv_data;
    chibiGetData(buf);
    Serial.println((char *)buf);
  }
}


