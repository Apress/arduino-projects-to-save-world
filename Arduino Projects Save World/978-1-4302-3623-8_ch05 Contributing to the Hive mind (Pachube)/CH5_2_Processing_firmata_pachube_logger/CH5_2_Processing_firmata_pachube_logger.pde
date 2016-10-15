import processing.serial.*;
import cc.arduino.*;
import eeml.*;

Arduino arduino1;
float lastUpdate;

int Analog0, Analog1, Analog2, Analog3, Analog4;

DataOut dOut1; 


int TSensor = 4;       // temperature sensor ADC input pin
int TempADC = 0;           // variable to store ADC value read
int TempOffset = 500;  // value in mV when ambient is 0 degrees C
int TempCoef = 10;     // Temperature coefficient mV per Degree C
float ADCmV = 4.88;    // mV per ADC increment (5 volts / 1024 increments)
float TempCalc = 0;        // calculated temperature in C (accuraccy to two decimal places)



void setup()
{
  // establish connection to the Arduino
  println(Arduino.list());
  arduino1 = new Arduino(this, Arduino.list()[2], 28800);
  
  dOut1 = new DataOut(this, "http://www.pachube.com/api/[your feed number here].xml", "[ your api key here ]");

// notify Pachube of the Stream ID and Stream TAGs  
  dOut1.addData(0, "Analog 0, knob 1");        // add one line for each stream
  dOut1.addData(1, "Analog 1, knob 2");        // the Stream ID in the stream number plus tags
  dOut1.addData(2, "Analog 2, knob 3");
  dOut1.addData(3, "Analog 3, knob 4");
  dOut1.addData(4, "Analog 4, temperature sensor, MCP9700");
}

void draw()
{
    // update once every 12 seconds (could also be e.g. every mouseClick)
    if ((millis() - lastUpdate) > 12000){
        println("ready to POST: ");
        // Read Arduino1’s analog ports:
        Analog0 = arduino1.analogRead(0);
        Analog1 = arduino1.analogRead(1);
        Analog2 = arduino1.analogRead(2);
        Analog3 = arduino1.analogRead(3);
        Analog4 = arduino1.analogRead(4);
        
        // Convert the temperature sensor:
        TempADC = arduino1.analogRead(TSensor);                        // read the input pin
        TempCalc = ((TempADC * ADCmV) - TempOffset) / TempCoef;   // the ADC to C equation
        
        // Display the data in the Processing debug window:
        println(Analog0); 
        println(Analog1);
        println(Analog2);
        println(Analog3);
        println(TempCalc);
        
        // Send the data streams to Pachube:
        dOut1.update(0, Analog0);
        dOut1.update(1, Analog1);
        dOut1.update(2, Analog2);
        dOut1.update(3, Analog3);
        dOut1.update(4, TempCalc);
        
        // Check for a response from Pachube;
        int response = dOut1.updatePachube(); // updatePachube() updates by an authenticated PUT HTTP request
        println(response); // should be 200 if successful; 401 if unauthorized; 404 if feed doesn't exist
        lastUpdate = millis();
    }   
}

