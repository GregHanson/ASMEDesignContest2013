/** 
 * XBee ACD API Reader
 * by Rob Faludi and Daniel Shiffman and Tom Igoe
 * http://www.faludi.com
 * http://www.shiffman.net
 * http://tigoe.net 
 * v 1.2  (added multiple samples)
 * v 1.3  (added Znet IO and AT support
 * v 1.4 added file input support
 */


import processing.core.*;
import processing.serial.*;
import xbee.XBeeDataFrame;
import xbee.XBeeReader;

    // Your Serial Port
    Serial port;
    // Your XBee Reader object
    XBeeReader xbee;

    int ad64H=0x0013A200;
    int [] ad64L={0x403E17E5,0x403E17E6,0x403E17E3};
    int [] ad16={0xFFFE,0xFFFE,0xFFFE};
    String [] ni={" 204"," 203"," 205"};

    
    static public void main(String args[]) {
        PApplet.main(new String[] { "processing.XBee"});
    }

    public void setup() {
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


    // This function works just like a "serialEvent()" and is 
    // called for you when data is available to be read from your XBee radio.
    public void xBeeEvent(XBeeReader xbee) {
        println("Xbee Event!");
        // Grab a frame of data
        XBeeDataFrame data = xbee.getXBeeReading();

        // This version of the library only works with IOPackets
        if (data.getApiID() == xbee.SERIES1_IOPACKET) {

            // Get the transmitter address
            int addr = data.getAddress16();

            // Get the RSSI reading in dBM 
            int rssi = data.getRSSI();

            long addr64 = data.getAddress64();

            int totalSamples = data.getTotalSamples();
            
            for (int n = 0; n < totalSamples; n++) {
                print("Sample: " + n + "  ");

                // Current state of each digital channel (-1 indicates channel is not configured)
                int[] digital = data.getDigital(n);  
                // Current state of each analog channel (-1 indicates channel is not configured);
                int[] analog = data.getAnalog(n);   

                // This example simply prints the data to the message window
                print("16 address: " + addr + " rssi: " + rssi + "  64address: " + addr64);
                print("  digital: ");
                for (int i = 0; i < digital.length; i++) {
                    print(digital[i] + " ");
                }

                print("  analog: ");
                for (int i = 0; i < analog.length; i++) {
                    print(analog[i] + " ");
                }
                println("");

            }
        } else {
            println("Not I/O data: " + data.getApiID());
        }
    }

    public void draw() {
        background(0);
        fill(255);
        rect(frameCount % width,0,10,height);
    }

    

//  This method responds to key presses when the 
//  program window is active: These methods test the 
//  Znet AT commands and such:
    
 public void keyPressed() {

   switch (key) {

   case 'a': 
     println("Executing node discover: ");
     xbee.nodeDiscover();
     break;
   case 'b':  
     println("Executing setting destination node: ");
     xbee.setDestinationNode(" 203");
     println();
     break;
   case 'c':
     println("Querying Channel: ");
     xbee.getCH();
     break;
      case 'd':
      println("Executing sending datastring: ");
     xbee.sendDataString(ad64H, ad64L[1], "Hello!");
     break;
   case 'h':
     println("Querying DH: ");
     xbee.getDH();
     break;
   case 'i':
     println("Querying PAN ID: ");
     xbee.getID();
     break;  
      case 'l':
      println("Querying DL: ");
     xbee.getDL();
     break;
   case 'n':
     println("Querying Node Identifier: ");
     xbee.getNI();
     break;
   case '1':
     println("set pin 1 on ..E5 to HIGH ");
     xbee.sendRemoteCommand(ad64H, ad64L[0],ad16[0],"D1", 5);
     break;
      case '2':
     println("set pin 1 on ..E5 to LOW ");
     xbee.sendRemoteCommand(ad64H, ad64L[0],ad16[0],"D1", 4);
     break;
      case '3':
     println("set pin 1 on ..E6 to HIGH ");
     xbee.sendRemoteCommand(ad64H, ad64L[1],ad16[1],"D1", 5);
     break;
      case '4':
     println("set pin 1 on ..E6 to LOW ");
     xbee.sendRemoteCommand(ad64H, ad64L[1],ad16[1],"D1", 4);
     break;
     case '5':
     xbee.setIOPin(1, 5);
     break;
         case '6':
     xbee.setIOPin(1, 4);
     break;
          case '7':
     println("query MY ");
     xbee.sendRemoteCommand(0x0013A200, 0x403E17E5,0xFFFE,"MY",-1);
     break;
          case 'p':
     println("print address database");
     for (int i=0; i<ad64L.length;i++) {
       println("64:"+hex(ad64H,8)+hex(ad64L[i],8)+" 16:"+hex(ad16[i],4)+" NI:"+ni[i]);
     }
     break;    
   }
 }

 void addressupdate(int address64High,int address16) {
   for (int i=0; i< ad64L.length;i++) {
     if (ad64L[i]==address64High) {
       ad16[i]=address16;
     }
   }
 }

