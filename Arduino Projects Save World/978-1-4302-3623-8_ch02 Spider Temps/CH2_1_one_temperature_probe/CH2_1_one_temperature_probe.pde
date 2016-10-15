int TSensor = 0;       	// temperature sensor ADC input pin
int val = 0;          	// variable to store ADC value read
int TempOffset = 500;  	// value in mV when ambient is 0 degrees C
int TempCoef = 10;    	// Temperature coefficient mV per Degree C
float ADCmV = 4.8828;  	// mV per ADC increment (5 volts / 1024 increments)
float Temp = 0;      	// calculated temperature in C (accuraccy to two decimal places)

void setup()
{
  Serial.begin(9600);	//  setup serial
}

void loop()
{
  val = analogRead(TSensor); 				// read the input pin
  Temp = ((val * ADCmV) - TempOffset) / TempCoef;		// the ADC to C equation
  Serial.println(Temp);					// display in the SerialMonitor
  delay (200);
}

