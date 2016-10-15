/*
  SpiderTemps - LCD
  Arduino projects to save the world
  
  This sketch reads all six analog inputs, calculates temperature
  and outputs to the serial monitor.
  It also displays them on an attached 20x2 LCD
*/

#include <LiquidCrystal.h>
//LCD pin setup
//           (RS, Enable, D4, D5, D6, D7)
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

// working variables
int ADC0, ADC1, ADC2, ADC3, ADC4, ADC5;
float temp0, temp1, temp2, temp3, temp4, temp5;

// sensor offset constants
int MCPoffset = 500;
int LM35offset = 0;

// sensor calibrations
int calibration0 = 0;
int calibration1 = 1;
int calibration2 = 0;
int calibration3 = 0;
int calibration4 = 0;
int calibration5 = 0;


void setup() {
  Serial.begin(9600);
  lcd.begin(20, 2);
}

void loop() {
  getADC();
  calcLoop();
  serialPrint();
  lcdPrint();
  delay(2000);
}

void calcLoop(){
  temp0 = calcTemp(ADC0, MCPoffset, calibration0);
  temp1 = calcTemp(ADC1, MCPoffset, calibration1);
  temp2 = calcTemp(ADC2, MCPoffset, calibration2);
  temp3 = calcTemp(ADC3, MCPoffset, calibration3);
  temp4 = calcTemp(ADC4, MCPoffset, calibration4);
  temp5 = calcTemp(ADC5, MCPoffset, calibration5);
}

void getADC() {
  ADC0 = analogRead(A0);
  ADC1 = analogRead(A1);
  ADC2 = analogRead(A2);
  ADC3 = analogRead(A3);
  ADC4 = analogRead(A4);
  ADC5 = analogRead(A5);
}

float calcTemp (int val, int offset, int cal) {
  return (((val * 4.8828) - offset) / 10) + cal;
}

void serialPrint(){
  Serial.print(temp0, 1);
  Serial.print("  ");
  Serial.print(temp1, 1);
  Serial.print("  ");
  Serial.print(temp2, 1);
  Serial.print("  ");
  Serial.print(temp3, 1);
  Serial.print("  "); 
  Serial.print(temp4, 1);
  Serial.print("  "); 
  Serial.println(temp5, 1);
}

void lcdPrint(){
   lcd.clear();
   lcd.setCursor(0, 0);
   lcd.print(temp0, 1);
   lcd.setCursor(7, 0);
   lcd.print(temp1, 1);
   lcd.setCursor(14, 0);
   lcd.print(temp2, 1);
   lcd.setCursor(0, 1);
   lcd.print(temp3, 1);
   lcd.setCursor(7, 1);
   lcd.print(temp4, 1);
   lcd.setCursor(14, 1);
   lcd.print(temp5, 1);
}

