import processing.serial.*;
Serial SinkNode;
String Month, Day, Year, Hour, Minute, Second, NodeData0, NodeData1;

// log file variables
String dataFolder = "../data/";
String logfilename;       // log file name
PrintWriter logFile;

// State variable
boolean logging = false;

void setup (){
  SinkNode = new Serial(this, Serial.list()[1], 57600);
  
   // set tentative file name
  logfilename = dataFolder + "Save_the_World-" + nf(year(),4) + nf(month(),2) + nf(day(),2)
                + "-" + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + ".log";
  
  startLogging();
} 

void draw() {
 int gotData = 0;
 while (gotData == 0){
  if (SinkNode.available() > 0) {
    String data = SinkNode.readStringUntil('\n');
    if (data != null){
      gotData = parseString(data);
      writeLog();
    }
  }
 }
}  


int parseString (String serialString) {
  String items[] = split(serialString, ',');
  println("From SourceNode: " + serialString);
  Month = items[0];
  Day = items[1];
  Year = items[2];
  Hour = items[3];
  Minute = items[4];
  Second = items[5];
  NodeData0 = items[6];
  NodeData1 = items[7];
  
  if (items.length == 7) { 
  return 1;
  } else {
    return 0;
  }
}


String formatLogEntry()
{
  String log_entry =
    Month + "/" + Day + "/" + Year + "," +
    Hour + ":" + Minute + ":" + Second + "," +
    NodeData0 + "," + NodeData1;
  return log_entry;
}

void writeLog()
{ 
  if (logging)
  {
    String log_entry = formatLogEntry();
    logFile.println(log_entry);
  println(log_entry);
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
    logfilename = dataFolder + "Save_the_World-" + nf(year(),4) + nf(month(),2) + nf(day(),2)
      + "-" + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + ".log";
  }
  logFile = createWriter(logfilename);
}

void closeLogFile()
{
  logFile.flush();
  logFile.close();
  println("Log file close.");
  // set tentative file name
  logfilename = dataFolder + "Save_the_World-" + nf(year(),4) + nf(month(),2) + nf(day(),2)
    + "-" + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + ".log";
}

