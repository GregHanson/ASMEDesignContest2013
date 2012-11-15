
/*
  XBee sensor data graphing sketch
 
 This sketch takes data in from a file containing XBee records and graphs the analog
 input values.  It's for XBee series 1 radios
 
 Based on code from  Rob Faludi and Daniel Shiffman
 http://www.faludi.com
 http://www.shiffman.net 
 
 created 15 Jan 2009
 by Tom Igoe
 */


import processing.serial.*;
import xbee.*;

// Your XBee Reader object
XBeeReader xbee;

// set up a font for displaying text:
PFont myFont;
int fontSize = 12;

String fileName = "LOG05.txt";
String outputFileName = "Signal strength test 05";

// set up Xbee parameters:
int rssi = 0;                           // received signal strength
int address = 0;                        // sender's address
int[] analogReadings = new int[6];      // values from the analog I/O pins
int[] previousValue = new int[6];       // previous values from the pins
int oldRssi = 0;

float sensorMin = 0;                    // bottom of the range you want to map the analog values to
float sensorMax = 1023;                 // top of the range

float rssiMin = 0;                      // rssi minimum
float rssiMax = 120;                    // rssi max

int numSensors = 3;                     // number of sensors you actually plan to graph

int xpos = 0;                           // graph x position
float oldYPos = 0;                      // graph y position
float yPos = 0;                         // previous y position

int readingCount = 0;                   // how many readings have been read

boolean newData = false;                // whether or not you got a new reading 
boolean DEBUG = true;                   // whether or not to print status messages

long slowSpeed = 10000;                 // how fast to graph, in ms per point (slow speed)
long fastSpeed = 30;                    // how fast to graph, in ms per point (fast speed)
boolean fontInitalized = false;         // whether the font object's been created or not


void setup() {
  size(800, 600);                        // window size
  frameRate(60);                         // frame rate
  smooth();                              // clean the jagged edges

  // create a font with the third font available to the system:
  myFont = createFont(PFont.list()[2], fontSize);
  textFont(myFont);
  fontInitalized = true;

  // initialize the xbee object:
  xbee = new XBeeReader(this, fileName, fastSpeed);
  xbee.startXBee();
  println("XBee Library version " + xbee.getVersion());

  // open a file to write values to:
  openFile();

  // white screen:
  background(255);
}

public void draw() {
  // not much here.  If you're done reading the file, stop and let the user know.
  if (xbee.fileEmpty) {
    text("Done Reading File", width/2, height/2); 
  }
}

/*
  This function works just like a "serialEvent()" and is
 called for you when data is available to be read from your XBee data file.
 */

public void xBeeEvent(XBeeReader xbee) {
  // Grab a frame of data
  XBeeDataFrame data = xbee.getXBeeReading();

  // This version of the library only works with IOPackets
  if (data.getApiID() == xbee.SERIES1_IOPACKET) {

    // Get the transmitter address
    int addr = data.getAddress16();

    // Get the RSSI reading in dBM 
    rssi = data.getRSSI();

    long addr64 = data.getAddress64();
    int totalSamples = data.getTotalSamples();

    // make two strings, one that'll be the title of the file, and 
    // another that'll be the format of the other lines:
    String sampleString = readingCount +",";
    String titleString = "Reading,rssi,16-bit address,64-bit address,";

    // add rssi and the addresses to the sample string:
    sampleString += rssi +"," + addr + "," + addr64 + ",";

    // loop over the samples and extract the data:
    for (int n = 0; n < totalSamples; n++) {
      // add each sample's data:
      titleString += "Sample,";
      sampleString +=  n + ",";

      // Current state of each digital channel (-1 indicates channel is not configured):
      int[] digital = data.getDigital(n);  
      // Current state of each analog channel (-1 indicates channel is not configured):
      int[] analog = data.getAnalog(n);  

      // add the digitals to the string:
      for (int i = 0; i < digital.length; i++) {
        titleString += "D" + i +",";
        sampleString += digital[i] + ",";
      }


      // add the analogs to the string.  Also add them to the global 
      // variable analogReadings[] for graphing:
      for (int i = 0; i < analog.length; i++) {
        titleString += "AN"+i+",";
        sampleString += analog[i] + ",";
        analogReadings[i] = analog[i];

      }
      // add to the graph:
      drawGraph();
    }

    // add a return character:
    sampleString += "\r";

    // got all the samples, now print them
    if (fileIsOpen) {
      if (readingCount == 0) {
        // only write the title if this is before the first element:
        writeData(titleString); 
      }
      // write the data to the file:
      writeData(sampleString); 
    }  
    else { 
      // print it to the message pane:
      if (DEBUG) println(sampleString); 
    }
    // increment the number of readings:
    readingCount++;
  }
  else {
    // if this is not an I/O data packet, say so:
    if (DEBUG) println("Not I/O data: " + data.getApiID());
  }

}

void drawGraph() {
  // iterate over the number of sensors:

  for (int thisSensor = 0; thisSensor < numSensors; thisSensor++) {
    // map the incoming values (0 to  1023) to an appropriate
    // graphing range (0 to window height/number of values):
    yPos = map(analogReadings[thisSensor], sensorMin, sensorMax, 0, height/(numSensors+1));
    oldYPos = map(previousValue[thisSensor], sensorMin, sensorMax, 0, height/(numSensors+1));

    // figure out the y position for this particular graph:
    float graphTop = thisSensor * height/(numSensors+1);
    yPos = yPos + graphTop;
    oldYPos = oldYPos + graphTop;
    // make a white block to erase the previous text:
    noStroke();
    fill(255);
    rect(10, graphTop+1, 110, 20);

    int textPos = int(graphTop) + 14;
    if (fontInitalized) {
      fill(0);
      text("Sensor " + thisSensor + ":" + analogReadings[thisSensor], 10, textPos);
    }
    // draw a line at the top of each graph:
    stroke(127);
    line(0, graphTop, width, graphTop);
    // change colors to draw the graph line:
    stroke(64*thisSensor, 32*thisSensor, 255);

    // draw the graph line from last value to current:
    line(xpos, oldYPos, xpos+1, yPos);
    // save the current reading for use in the next time through the loop:
    previousValue[thisSensor] = analogReadings[thisSensor];
  }

  // graph the RSSI:

  // map the incoming values (0 to  1023) to an appropriate
  // graphing range (0 to window height/number of values):
  yPos = map(abs(rssi), rssiMin, rssiMax, 0, height/(numSensors+1));
  oldYPos = map(abs(oldRssi), rssiMin, rssiMax, 0, height/(numSensors+1));

  // figure out the y position for this particular graph:
  float graphTop = numSensors * height/(numSensors+1);
  yPos = yPos + graphTop;
  oldYPos = oldYPos + graphTop;
  // make a white block to erase the previous text:
  noStroke();
  fill(255);
  rect(10, graphTop+1, 110, 20);

  int textPos = int(graphTop) + 14;
  if (fontInitalized) {
    fill(0);
    text("RSSI: " + rssi, 10, textPos);
  }
  // draw a line at the bottom of each graph:
  stroke(127);
  line(0, graphTop, width, graphTop);
  // change colors to draw the graph line:
  stroke(0, 0, 255);

  // draw the graph line from last value to current:
  line(xpos, oldYPos, xpos+1, yPos);

  // save the current value as the old value for next time through the loop:
  oldRssi = rssi;
  // you're done with this packet. You need new data:
  newData = false;

  // if you're at the right of the screen,
  // clear and go back to the left:
  if (xpos >= width) {
    xpos = 0;
    background(255);
  }
  else {
    xpos++;
  }

  // write the text at the top
  noStroke();
  fill(255);
  rect(610, 0, width, 100);
  fill(0);
  text("From: " + hex(address), 620, 20);
  text ("RSSI: " + rssi + " dBm", 620, 40);
  text("X: " + analogReadings[0] + "  Y: " + analogReadings[1] + "  Z: " + analogReadings[2], 620, 60);
  text ("Number of readings: " + readingCount, 620, 80);
}

void keyPressed() {
  //  if the user hits the space bar, slow down to 10 seconds between readings.
  // a second hit on the space bare resumes normal speedL:  switch (key) {
  switch(key) {
  case ' ':
    if (xbee !=null) {
      if (xbee.getSleepTime() <= fastSpeed ) {
        xbee.setSleepTime(slowSpeed);
      } 
      else {
        xbee.setSleepTime(fastSpeed);
      }
    }
    break;
  case 'a':
    break;
  } 
}

