import processing.serial.*;

// Zero Adjustments (around 512 +- for mount angle offsets)
int xadj=-494;
int yadj=-509;
int zadj=-755;

int linefeed = 10;
// For storing serial port input
int sensors[] = new int[3];
// For line drawing purposes
int old_sensors[] = new int[3];
int xpos = 1;
// For dropping instances from the plot
int count = 0;
int count_limit = 15;

// logging
String dataFolder = "../data/Seismo/";
String folderName;
String logfilename;
PrintWriter logFile;
int logDay, logHour;
boolean logging = false;


Serial port;

void setup()
{
  // prep screen
  size(800,600,P2D);
  background(0);
  stroke(255,255,255);
  line(0,height*1/6,width,height*1/6);
  line(0,height*2/6,width,height*2/6);
  line(0,height*3/6,width,height*3/6);
  line(0,height*4/6,width,height*4/6);
  line(0,height*5/6,width,height*5/6);
  
  

  // prep serial port
  println(Serial.list());
  port = new Serial(this,Serial.list()[1],57600);
  port.bufferUntil(linefeed);
  
  // logging
  logDay = day();
  logHour = hour();
  folderName = dataFolder + nf(year(),4) + nf(month(),2)
  + nf(day(),2) + "/";
  
  logfilename = folderName + "Seismo-" + nf(year(),4)
  + nf(month(),2) + nf(day(),2) + "-" + nf(hour(),2) 
  + nf(minute(),2) + nf(second(),2) + ".log";
  
  startLogging();
}

void draw()
{
  if (logDay != day())
  {
    logging = false;
    closeLogFile();
    logDay = day();
    logHour = hour();
    
    folderName = dataFolder + nf(year(),4) + nf(month(),2)
    + nf(day(),2) + "/";
  
    logfilename = folderName + "Seismo-" + nf(year(),4)
    + nf(month(),2) + nf(day(),2) + "-" + nf(hour(),2) 
    + nf(minute(),2) + nf(second(),2) + ".log";
    
    openLogFile();
    logging = true;
  }
  if (logHour != hour())
  {
    logging = false;
    closeLogFile();
    logHour = hour();
      
    logfilename = folderName + "Seismo-" + nf(year(),4)
    + nf(month(),2) + nf(day(),2) + "-" + nf(hour(),2) 
    + nf(minute(),2) + nf(second(),2) + ".log";
    
    openLogFile();
    logging = true;
  }
  if(count >= count_limit)
  {
    count = 0;
    plotSensors();
  }
}

void serialEvent(Serial port)
{
  String input = port.readStringUntil(linefeed);
  
  if(input != null)
  {
    input = trim(input);
    
    sensors = int(split(input,','));

    adjustSensors();
//    printData();
    plotSensors();
    writeLog();
    count++;
  }
}

void printData()
{
  for(int i=0; i<sensors.length; i++)
  {
    print(sensors[i]);
    print(" ");
  }
  println();
}

void adjustSensors()
{
  sensors[0] = sensors[0]+xadj;
  sensors[1] = sensors[1]+yadj;
  sensors[2] = sensors[2]+zadj;
}

void plotSensors()
{
  stroke(255,0,0);
  line(xpos-1,(height*1/6)-((old_sensors[0]*200)/1024), xpos,(height*1/6)-((sensors[0]*200)/1024));

  stroke(0,255,0);
  line(xpos-1,(height*3/6)-((old_sensors[1]*200)/1024), xpos,(height*3/6)-((sensors[1]*200)/1024));

  stroke(0,0,255);
  line(xpos-1,(height*5/6)-((old_sensors[2]*200)/1024), xpos,(height*5/6)-((sensors[2]*200)/1024));
  
  old_sensors = sensors;
  
  if(xpos >= width)
  {
    xpos = 0;
    background(0);
    stroke(255,255,255);
    line(0,height*1/6,width,height*1/6);
    line(0,height*2/6,width,height*2/6);
    line(0,height*3/6,width,height*3/6);
    line(0,height*4/6,width,height*4/6);
    line(0,height*5/6,width,height*5/6);
  }
  else
  {
    xpos++;
  }
}

String formatLogEntry()
{
  String Hour, Minute, Second;
  Hour = nf(hour(),2);
  Minute = nf(minute(),2);
  Second = nf(second(),2);

  String log_entry =
    Hour + ":" + Minute + ":" + Second + "," +
    sensors[0] + "," + sensors[1] + "," + sensors[2];
  return log_entry;
}

void writeLog()
{ 
  if (logging)
  {
    String log_entry = formatLogEntry();
    logFile.println(log_entry);
    logFile.flush();
  }
}

void startLogging()
{
  // open file
  openLogFile();
  // start running
  logging = true;
  println("Started logging to " + logfilename);
}

void stopLogging()
{
  logging = false;
  closeLogFile();
  println("Stopped Logging.");
}

void openLogFile()
{
 // logfilename = logfileTextField.getText();
  if (logfilename.equals(""))
  {
    // set tentative file name
    logfilename = dataFolder + "Seismo-" + nf(year(),4) + nf(month(),2) + nf(day(),2)
      + "-" + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + ".log";
  }
  logFile = createWriter(logfilename);
  println("Log file opened: " + logfilename);
}

void closeLogFile()
{
  logFile.flush();
  logFile.close();
  println("Log file close.");
  // set tentative file name
  logfilename = dataFolder + "Seismo-" + nf(year(),4) + nf(month(),2) + nf(day(),2)
    + "-" + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + ".log";
}


