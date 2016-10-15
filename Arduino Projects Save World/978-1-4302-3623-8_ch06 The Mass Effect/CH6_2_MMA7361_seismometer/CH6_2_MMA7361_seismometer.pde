/*
  Seismometer using SparkFun MMA7361 sensor
  and Arduino Pro Mini 3.3Volt 8Mhz
  
  Setting GSEL
  0 = 1.5g, 800 mV/g
  1 = 6g, 206 mV/g
  Sleep: 0 = Sleep, 1 = Wake
  ZeroGD (output): logic high on this pin inidicates
  all three axis at zero G (freefall)
  
  */

// MMA7361 control pins
int ST = 6;        // Self Test
int GSEL = 7;      // G-mode
int ZeroGD = 8;    // Zero-g detect output
int SLP = 9;       // sleep pin
// Axis outputs
int Xaxis_pin = 2;
int Yaxis_pin = 1;
int Zaxis_pin = 0;

void setup()
{
  Serial.begin(57600);
  pinMode(13, OUTPUT);
  digitalWrite(13, HIGH);
  digitalWrite(SLP, HIGH);  //Awake
  digitalWrite(GSEL, LOW);  //1.5 G mode
}

void loop()
{
  char temp[15];
    sprintf(temp, "%d,%d,%d", 
     analogRead(Xaxis_pin), analogRead(Yaxis_pin), analogRead(Zaxis_pin));
    Serial.println(temp);
    delay(5);
}

