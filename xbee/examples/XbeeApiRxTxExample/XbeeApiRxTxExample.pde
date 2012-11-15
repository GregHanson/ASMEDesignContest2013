import processing.serial.*;
import xbee.*;

Serial port;
XBeeReader xbee;

void setup()
{
  size(200, 200);

  // println("Available serial ports:");
  // println(Serial.list());
  port = new Serial(this, Serial.list()[0], 9600);
  xbee = new XBeeReader(this,port);

  // println("Setting up Xbee");

  // start() issues your initialization commands to the Xbee radio
  // start() is a blocking function (takes ~3 seconds on average) and will time out after 10 seconds
  // Do not send CN\r\n, the xbee object will do that for you
  // String response = xbee.startXBee("ATRE,ID3333,MY89,DH0,DL0");
  // println("Setup response: " + response);

  xbee.startXBee();
  println("XBee Library version " + xbee.getVersion());
}

void draw()
{
}

void xBeeEvent(XBeeReader xbee) {
  XBeeDataFrame data = xbee.getXBeeReading();

  if (data.getApiID() == xbee.SERIES1_RX16PACKET) {
    int addr = data.getAddress16();
    int[] bytes = data.getBytes();
    
    print(millis() + "\t[" + addr + "]:");
    
    for (int n = 0; n < bytes.length; n++) {
      print(" " + bytes[n]);
      
    }
    
    println();
    
    // echo data back to the xbee.
    xbee.sendDataString16(addr, bytes);
  } 
}


