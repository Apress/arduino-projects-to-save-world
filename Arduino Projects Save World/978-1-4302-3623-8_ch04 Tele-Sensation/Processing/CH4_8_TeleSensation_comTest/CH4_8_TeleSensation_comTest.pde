import processing.serial.*;
Serial SinkNode;
String Month, Day, Year, Hour, Minute, Second, NodeData0, NodeData1;

void setup (){
  //sets up a serial connection named SinkNode.
  //The value after Serial.list in the [] indicates the port
  SinkNode = new Serial(this, Serial.list()[1], 57600);
}

void draw() {
 int gotData = 0;
 while (gotData == 0){
  if (SinkNode.available() > 0) {
    String data = SinkNode.readStringUntil('\n');
    if (data != null){
      gotData = parseString(data);
      PrintData();
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

void PrintData() {
  print(Month);
  print("/");
  print(Day);
  print("/");
  print(Year);
  print(" ");
  print(Hour);
  print(":");
  print(Minute);
  print(":");
  print(Second);
  print("  ");
  print("A0 = ");
  print(NodeData0);
  print("  ");
  print("A1 = ");
  println(NodeData1);
}

