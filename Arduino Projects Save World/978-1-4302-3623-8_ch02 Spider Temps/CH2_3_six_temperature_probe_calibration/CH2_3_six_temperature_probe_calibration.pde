/*
SpiderTemps 6 sensor plus software calibration
Arduino projects to save the world

This sketch reads all six analog inputs, calculates temperature(C) and outputs them to the serial monitor.
*/

float temp0, temp1, temp2, temp3, temp4, temp5;
int ADC0, ADC1, ADC2, ADC3, ADC4, ADC5;
int MCPoffset = 500;
int LM35offset = 0;

float calibration0 = 0;
float calibration1 = 0;
float calibration2 = 0;
float calibration3 = 0;
float calibration4 = 0;
float calibration5 = 0;


void setup() {
  Serial.begin(9600);
}

void loop() {
  getADC();
  temp0 = calcTemp(ADC0, LM35offset, calibration0);
  temp1 = calcTemp(ADC1, LM35offset, calibration1);
  temp2 = calcTemp(ADC2, MCPoffset, calibration2);
  temp3 = calcTemp(ADC3, MCPoffset, calibration3);
  temp4 = calcTemp(ADC4, MCPoffset, calibration4);
  temp5 = calcTemp(ADC5, MCPoffset, calibration5);
  
  Serial.print(temp0, 0);
  Serial.print("  ");
  Serial.print(temp1, 0);
  Serial.print("  ");
  Serial.print(temp2, 0);
  Serial.print("  ");
  Serial.print(temp3, 0);
  Serial.print("  "); 
  Serial.print(temp4, 0);
  Serial.print("  "); 
  Serial.println(temp5, 0);
  
  delay(500);
}

void getADC() {
  ADC0 = analogRead(A0);
  ADC1 = analogRead(A1);
  ADC2 = analogRead(A2);
  ADC3 = analogRead(A3);
  ADC4 = analogRead(A4);
  ADC5 = analogRead(A5);
}

float calcTemp (int val, int offset, float cal) {
  return (((val * 4.8828) - offset) / 10) + cal;
}

