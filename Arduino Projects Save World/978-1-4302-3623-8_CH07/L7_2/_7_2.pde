#include <LiquidCrystal.h>
#include <SD.h>

LiquidCrystal lcd(3, 5, 6, 7, 8, 9);
File file;

const int voltageSensor = A0;
const int currentSensor = A1;
const int SDcs = 4;

const int numberOfSamples = 3000;

// Calibration constants
const float AC_WALL_VOLTAGE     = 120.9;
const float AC_ADAPTER_VOLTAGE  = 14.1;
const float AC_VOLTAGE_DIV_VOUT = 0.85;
const float CT_BURDEN_RESISTOR  = 40.2;
const float CT_TURNS            = 2280.0;

// Calibration coeficients
const float VCAL = 1.0;
const float ICAL = 1.0;
const float PHASECAL = 0.9;

// Calculated ratio constants, modified by VCAL/ICAL
const float AC_ADAPTER_RATIO = AC_WALL_VOLTAGE / AC_ADAPTER_VOLTAGE;
const float AC_VOLTAGE_DIV_RATIO = AC_ADAPTER_VOLTAGE / AC_VOLTAGE_DIV_VOUT;
const float V_RATIO = AC_ADAPTER_RATIO * AC_VOLTAGE_DIV_RATIO * 5 / 1024 * VCAL;
const float I_RATIO = CT_TURNS / CT_BURDEN_RESISTOR * 5 / 1024 * ICAL;

// Sample variables
int lastSampleV, lastSampleI, sampleV, sampleI;

// Filter variables
float lastFilteredV, lastFilteredI, filteredV, filteredI;

// Power sample totals
float sumI, sumV, sumP;

// Phase calibrated instantaneous voltage
float calibratedV;

// Calculated power variables
float realPower, apparentPower, powerFactor, voltageRMS, currentRMS;
unsigned long last_kWhTime, kWhTime;
float kilowattHour = 0.0;

unsigned long startTime = 0;
unsigned long interval = 10000;

void setup() {
 lcd.begin(16,2);
 Serial.begin(9600);
 
 // Starts the SD card
 Serial.print("Initializing SD card...");
 pinMode(10, OUTPUT);
 
 // Checks that the SD card is present 
 if (!SD.begin(SDcs)) {
   Serial.println("initialization failed!");
   return;
 }
 Serial.println("initialization done.");
}

void loop() { 
  calculatePower();
  displayPower();
  
  // Opens file on SD if interval has passed
  if (startTime + interval < millis()) {
    // Opens files and sets to write mode
    file = SD.open("data.txt", FILE_WRITE);
    
    // Writes values to file if present
    if (file) {
      Serial.print("Writing to data.txt... ");
      
      file.print(realPower);
      file.print(",");
      file.print(apparentPower);
      file.print(",");
      file.print(powerFactor * 100);
      file.print(",");
      file.print(voltageRMS);
      file.print(",");
      file.print(currentRMS);
      file.print(",");
      file.println(kilowattHour);
    
      Serial.println("done.");
      // Need to close a file to save the data
      file.close();
      Serial.println("File closed.");
    } else Serial.println("Error opening data.txt."); 
    startTime = millis();
  }
}

void calculatePower() {
  for (int i = 0; i < numberOfSamples; i++) {
    // Used for voltage offset removal
    lastSampleV = sampleV;
    lastSampleI = sampleI;

    // Read voltage and current values  
    sampleV = analogRead(voltageSensor);
    sampleI = analogRead(currentSensor);

    // Used for voltage offset removal
    lastFilteredV = filteredV;
    lastFilteredI = filteredI;

    // Digital high pass filters to remove 2.5V DC offset
    filteredV = 0.996 * (lastFilteredV + sampleV - lastSampleV);
    filteredI = 0.996 * (lastFilteredI + sampleI - lastSampleI);

    // Phase calibration
    calibratedV = lastFilteredV + PHASECAL * (filteredV - lastFilteredV);

    // Root-mean-square voltage
    sumV += calibratedV * calibratedV;

    // Root-mean-square current
    sumI += filteredI * filteredI;

    // Instantaneous Power
    sumP += abs(calibratedV * filteredI);
  }

  // Calculation of the root of the mean of the voltage and current squared (rms)
  // Calibration coeficients applied 
  voltageRMS = V_RATIO * sqrt(sumV / numberOfSamples); 
  currentRMS = I_RATIO * sqrt(sumI / numberOfSamples); 

  // Calculate power values
  realPower = V_RATIO * I_RATIO * sumP / numberOfSamples;
  apparentPower = voltageRMS * currentRMS;
  powerFactor = realPower / apparentPower;

  // Calculate running total kilowatt hours
  // This value will reset in 50 days
  last_kWhTime = kWhTime;
  kWhTime = millis();
  // Convert watts into kilowatts and multiply by the time since the last reading
  kilowattHour += (realPower / 1000) * ((kWhTime - last_kWhTime) / 3600000.0);

  // Reset sample totals
  sumV = 0;
  sumI = 0;
  sumP = 0;
}

void displayPower() {
  lcd.clear();
  lcd.print(realPower, 0);
  lcd.print("w ");
  lcd.print(apparentPower, 0);
  lcd.print("va ");
  lcd.print(powerFactor * 100, 0);
  lcd.print("%");
  lcd.setCursor(0,1);
  lcd.print(voltageRMS, 0);
  lcd.print("v ");
  lcd.print(currentRMS, 1);
  lcd.print("a ");
  lcd.print(kilowattHour, 4);
}

