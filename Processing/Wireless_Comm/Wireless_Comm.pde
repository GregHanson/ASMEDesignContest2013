
import processing.serial.*;
import procontroll.*;
import processing.serial.*;

//
// controller variables
//
//
ControllIO controll;
// Change this depending on Operating System
private int usingController = 1;  // 1: XBOX controller with windows
                                  // 2: XBOX controller with mac

private ControllDevice gamepad;
public ControllStick leftStick;
public ControllStick rightStick;
private ControllCoolieHat DPad;
private ControllSlider XBOXTrig;

// concessions to the XBOX Controller, maybe I'm going a little overboard?
public float leftTriggerMultiplier, leftTriggerTolerance, leftTriggerTotalValue;
public float rightTriggerMultiplier, rightTriggerTolerance, rightTriggerTotalValue;

boolean invertLeftX, invertLeftY, invertRightX, invertRightY;

private ControllButton Y;
private ControllButton B;
private ControllButton A; 
private ControllButton X;
private ControllButton L1;
private ControllButton L2;
private ControllButton L3;
private ControllButton R1;
private ControllButton R2;
private ControllButton R3;
private ControllButton Select;
private ControllButton Start;
private ControllButton DPadUp;
private ControllButton DPadDown;
private ControllButton DPadLeft;
private ControllButton DPadRight;


boolean yPressed, bPressed, aPressed, xPressed;
boolean l1Pressed, r1Pressed;
boolean dUpPressed, dDownPressed, dLeftPressed, dRightPressed;
boolean rjsPressed, ljsPressed;
boolean rtPressed, ltPressed;
float leftJoystickX, leftJoystickY, rightJoystickX, rightJoystickY;


//
// serial data variables
//
//
Serial port = null;
String portName;
int lastInput = 0;
int[] command = new int[3];
int[] lastCommand = new int[3];
int speed = 9;
int lastSpeed = 0;
int speedStep = (255 - 130) / 8;
boolean running = true;

// Value for joystick
float WIGGLE_ROOM = 0.2;

//Flags for motors and camera
int DIR_FORWARD = 0x1;
int DIR_BACKWARD = 0x2;
int DIR_LEFT = 0x4;
int DIR_RIGHT = 0x8;
int BEGIN_COMMAND = 0x7F;

// Flags for buttons
int A_BUTTON = 0x1;
int B_BUTTON = 0x2;
int X_BUTTON = 0x4;
int Y_BUTTON = 0x8;
int LB_BUTTON = 0x10;
int RB_BUTTON = 0x20;
int LT_BUTTON = 0x40;
int RT_BUTTON = 0x80;

SimpleDateFormat df = new SimpleDateFormat("hh:mm:ss.SSS");


void setup() {
  size(1, 1);
  //
  // Serial Setup
  //
  //
  println(Serial.list());
  portName = Serial.list()[0];
  try {
    port = new Serial(this, portName, 19200);
  } catch (Exception e) {
    e.printStackTrace();
  } 
  //
  // Controller setup
  //
  //
  controll = ControllIO.getInstance(this);
  
  if(usingController == 1){
    mapXBOXwindows();
  }
  else if(usingController == 2){
    mapXBOXmac();
  }
  
  yPressed = bPressed = aPressed = xPressed = false;
  dUpPressed = dDownPressed = dLeftPressed = dRightPressed = false;
  l1Pressed = r1Pressed = false;
  rjsPressed = ljsPressed = false;
  rtPressed = ltPressed = false;
  leftJoystickX = leftX();
  leftJoystickY = leftY();
  rightJoystickX = rightX();
  rightJoystickY = rightY();
  
}

String timestamp() {
  return df.format(new Date());
}

void draw() {
  
  getControllerState();
  sendCommand();

}

void interruptibleDelay(int millis) {
  int start = millis();
  int d;
  while (running) {
    int timeLeftToWait = millis-(millis()-start);
    d = min(10, timeLeftToWait);
    if (d <= 0) return;
    delay(d);
  }
}

//
// Methods for seting the motor and cam flags
//
// true:   motors
// false:  camera
//
void doForward(boolean i) {
  int andVal = 0;
  int orVal = 0;
  if(i){
    andVal = DIR_BACKWARD;
    orVal = DIR_FORWARD;
  }
  else{
    andVal = DIR_BACKWARD << 4;
    orVal = DIR_FORWARD << 4;    
  }
  
  command[2] = command[2] & ~andVal;
  command[2] = command[2] | orVal;  
}

void doBackward(boolean i) {
  int andVal = 0;
  int orVal = 0;
  if(i){
    andVal = DIR_FORWARD;
    orVal = DIR_BACKWARD;
  }
  else{
    andVal = DIR_FORWARD << 4;
    orVal = DIR_BACKWARD << 4;    
  }
  
  command[2] = command[2] & ~andVal;
  command[2] = command[2] | orVal;
}

void doLeft(boolean i) {
  int andVal = 0;
  int orVal = 0;
  if(i){
    andVal = DIR_RIGHT;
    orVal = DIR_LEFT;
  }
  else{
    andVal = DIR_RIGHT << 4;
    orVal = DIR_LEFT << 4;    
  }
  
  command[2] = command[2] & ~andVal;
  command[2] = command[2] | orVal;  
}

void doRight(boolean i) {
  int andVal = 0;
  int orVal = 0;
  if(i){
    andVal = DIR_LEFT;
    orVal = DIR_RIGHT;
  }
  else{
    andVal = DIR_LEFT << 4;
    orVal = DIR_RIGHT << 4;    
  }
  
  command[2] = command[2] & ~andVal;
  command[2] = command[2] | orVal;  
}

void doStraight(boolean i) {
  int andVal_1 = 0;
  int andVal_2 = 0;
  if(i){
    andVal_1 = DIR_RIGHT;
    andVal_2 = DIR_LEFT;
  }
  else{
    andVal_1 = DIR_RIGHT << 4;
    andVal_2 = DIR_LEFT << 4;    
  }
  
  command[2] = command[2] & ~andVal_1;
  command[2] = command[2] & ~andVal_2;  
}

void doStop(boolean i) {
  int andVal_1 = 0;
  int andVal_2 = 0;
  if(i){
    andVal_1 = DIR_FORWARD;
    andVal_2 = DIR_BACKWARD;
  }
  else{
    andVal_1 = DIR_FORWARD << 4;
    andVal_2 = DIR_BACKWARD << 4;    
  }
  
  command[2] = command[2] & ~andVal_1;
  command[2] = command[2] & ~andVal_2;  
}


//
// Unused Serial Read Event
// 
void serialEvent(Serial p) {
  int input = p.read();
  lastInput = input;
  println("input received: " + input);
  //processInput(input);
} 


void sendCommand() {
  if (!isNewCommand()) {
    return;
  }
  if (port != null) {
    port.write(BEGIN_COMMAND);
    port.write(command[0]);
    command[1] = 255;
    port.write(command[1]);
    port.write(command[2]);
    
    // Sends stop command for twisting multiple times
    if (
        (  ((command[0] & X_BUTTON) == 0) && (lastCommand[0] & X_BUTTON) > 0) || 
        (  ((command[0] & B_BUTTON) == 0) && (lastCommand[0] & B_BUTTON) > 0) ) {
      int send_count = 0;
      while (send_count < 2){
            println(timestamp() + " RESending STOP command");
            port.write(BEGIN_COMMAND);
            port.write(command[0]);
            port.write(command[1]);
            port.write(command[2]);
            delay(1);
            send_count++;
      }
    }

    lastCommand[0] = command[0];
    lastCommand[1] = command[1];
    lastCommand[2] = command[2];
    lastSpeed = speed;
    println(command);
  }
}

//
// Checks for changes in the serial commands so
// Serial input buffer for Arduino doesn't fill up
//
boolean isNewCommand() {
  return ((command[0] != lastCommand[0]) || (command[1] != lastCommand[1]) || (lastCommand[2] != command[2]) || (speed != lastSpeed));
}

//
// Sets all flags based on controller input
//
void getControllerState(){
  checkButtons();
  
  checkDPad();

  checkLeftJoyStick();
  
  checkRightJoyStick();
  
  checkBumpers();
  
  checkTriggers();
  
}

//
// Check the left and right triggers
// triggers are used for controlling claw's
// up/down and open/close movement
//
void checkTriggers(){
 if(leftZ() > 0.1 && !ltPressed){
    println(timestamp() + " Left Trigger");
    ltPressed = true;
    command[0] = command[0] | LT_BUTTON; 
  }
  else if(leftZ() <= 0.1){
    ltPressed = false;
    command[0] = command[0] & ~LT_BUTTON;
  } 
 if(rightZ() > 0.1 && !rtPressed){
    println(timestamp() + " Right Trigger"); 
    rtPressed = true;
    command[0] = command[0] | RT_BUTTON; 
  }
  else if(rightZ() <= 0.1){
    rtPressed = false; 
    command[0] = command[0] & ~RT_BUTTON;   
  } 
}

// Check the left and right bumpers
// bumpers are used for controlling claw's
// up/down and open/close movement
// 
void checkBumpers(){
 if(L1() && !l1Pressed){
    println(timestamp() + " Left Bumper");
    l1Pressed = true;
    command[0] = command[0] | LB_BUTTON; 
  }
  else if(!L1()){
   l1Pressed = false; 
   command[0] = command[0] & ~LB_BUTTON;
  } 
 if(R1() && !r1Pressed){
    println(timestamp() + " Right Bumper"); 
    r1Pressed = true; 
    command[0] = command[0] | RB_BUTTON;     
  }
  else if(!R1()){
   r1Pressed = false; 
    command[0] = command[0] & ~RB_BUTTON; 
  }
}

//
// Check left joystick values
// values are used for motor commands
//
void checkLeftJoyStick(){
  
  float x = leftX();
  float y = leftY();
  
  if(L3() && !ljsPressed){
    println(timestamp() + " Left Joystick Pressed");
    ljsPressed = true; 
  }
  else if(!L3()){
    ljsPressed = false; 
  }
  
  if(leftJoystickX != x || leftJoystickY != y){
    leftJoystickX = x;
    leftJoystickY = y;
    if(x <= -WIGGLE_ROOM){
      println(timestamp() + " Going Left");      
      doLeft(true);
    }
    
    else if(x >= WIGGLE_ROOM){
      println(timestamp() + " Going Right");
      doRight(true);
    }
    
    else{
      println(timestamp() + " Going Straight");
      doStraight(true);
    }
    
    if(y <= -WIGGLE_ROOM){
      println(timestamp() + " Going Backward");
      doBackward(true); 
    }
    else if(y > -WIGGLE_ROOM && y < WIGGLE_ROOM){
      println(timestamp() + " Stopping");
      doStop(true);
    }
    else if(y >= WIGGLE_ROOM){
      println(timestamp() + " Going Forward");
      doForward(true);
    }
  }

}

//
// Check right joystick values
// values used for comtrolling camera (pan/tilt)
//
void checkRightJoyStick(){
  
  float x = rightX();
  float y = rightY();
  
  if(R3() && !rjsPressed){
    println(timestamp() + " Right Joystick Pressed");
    rjsPressed = true; 
  }
  else if(!R3()){
   rjsPressed = false; 
  }
  
  if(rightJoystickX != x || rightJoystickY != y){
    rightJoystickX = x;
    rightJoystickY = y;
    if(x <= -WIGGLE_ROOM){
      println(timestamp() + " CAM Pan Left");      
      doLeft(false);
    }
    
    else if(x >= WIGGLE_ROOM){
      println(timestamp() + " CAM Pan Right");
      doRight(false);
    }
    
    else{
      println(timestamp() + " CAM Pan Stop");
      doStraight(false);
    }
    
    if(y <= -WIGGLE_ROOM){
      println(timestamp() + " CAM Tilt Down");
      doBackward(false); 
    }
    
    else if(y > -WIGGLE_ROOM && y < WIGGLE_ROOM){
      println(timestamp() + " CAM Tilt Stop");
      doStop(false);
    }
    
    else if(y >= WIGGLE_ROOM){
      println(timestamp() + " CAM Tilt Stop");
      doForward(false);
    }
  }
  
}

//
// Check the Dpad values
// currently unused and only configured for windows
//
void checkDPad(){
  if(DUp() && !dUpPressed){
   println("Up on DPad pressed: ");
   dUpPressed = true; 
  }
  else if(!DUp()){
   dUpPressed = false; 
  }
  if(DDown() && !dDownPressed){
   println("Down on DPad pressed: ");
   dDownPressed = true; 
  }
  else if(!DDown()){
   dDownPressed = false;  
  }
  if(DLeft() && !dLeftPressed){
   println("Left on DPad pressed: "); 
   dLeftPressed = true; 
  }
  else if(!DLeft()){
   dLeftPressed = false; 
  }  
  if(DRight() && !dRightPressed){
   println("Right on DPad pressed: "); 
   dRightPressed = true; 
  }
  else if(!DRight()){
   dRightPressed = false; 
  }  
}

//
// Check buttons on controller
// X/B twisting
// A/Y positioning camera to set positions
//
void checkButtons(){
  if(Y() && !yPressed){
    println(timestamp() + " Y Pressed");
    command[0] = command[0] | Y_BUTTON;
    yPressed = true;
  }
  else if (!Y()){
   yPressed = false; 
   command[0] = command[0] & ~Y_BUTTON;
  }
  if(B() && !bPressed){
    println(timestamp() + " B Pressed");
    command[0] = command[0] | B_BUTTON; 
    bPressed = true;
  }
  else if (!B()){
   bPressed = false; 
   command[0] = command[0] & ~B_BUTTON;
  }
  if(A() && !aPressed){
    println(timestamp() + " A Pressed");
    command[0] = command[0] | A_BUTTON; 
    aPressed = true;
  }
  else if (!A()){
   aPressed = false;
   command[0] = command[0] & ~A_BUTTON; 
  }
  if(X() && !xPressed){
    println(timestamp() + " X Pressed"); 
    command[0] = command[0] | X_BUTTON;
    xPressed = true;
  } 
  else if (!X()){
   xPressed = false; 
   command[0] = command[0] & ~X_BUTTON;
  } 
}


void mapXBOXmac(){
  
  gamepad = controll.getDevice("Controller");
  //printDeviceItems();
  gamepad.setTolerance(0.05f);  //was 0.5f.
  gamepad.printSliders();
  gamepad.printButtons();
  Y = gamepad.getButton(14);
  B = gamepad.getButton(12);
  A = gamepad.getButton(11);
  X = gamepad.getButton(13);
  Select = gamepad.getButton(5);
  Start = gamepad.getButton(4);
  DPadUp = gamepad.getButton(0);
  DPadDown = gamepad.getButton(1);
  DPadLeft = gamepad.getButton(2);
  DPadRight = gamepad.getButton(3);
  
  // Following code needs to be debugged
  R1 = gamepad.getButton(5);
  R3 = gamepad.getButton(9);
  L1 = gamepad.getButton(4);
  L3 = gamepad.getButton(8);
  leftStick = new ControllStick(gamepad.getSlider(0), gamepad.getSlider(1));
  rightStick = new ControllStick(gamepad.getSlider(2), gamepad.getSlider(3));
  XBOXTrig = gamepad.getSlider(4);
  leftTriggerTolerance = rightTriggerTolerance = XBOXTrig.getTolerance();
  leftTriggerMultiplier = rightTriggerMultiplier = XBOXTrig.getMultiplier();
  
  /* ---- Example code from http://www.blairkelly.ca/2012/04/20/arduino-wifly-mini-processing-code/
     ---- for mapping 360 controller on a mac */
}

void mapXBOXwindows()
{
  controll.printDevices();
  gamepad = controll.getDevice("Controller (XBOX 360 For Windows)");
  //printDeviceItems();
  
  gamepad.printSliders();
  gamepad.printButtons();
  leftStick = new ControllStick(gamepad.getSlider(1), gamepad.getSlider(0));
  rightStick = new ControllStick(gamepad.getSlider(3), gamepad.getSlider(2));
  XBOXTrig = gamepad.getSlider(4);
  leftTriggerTolerance = rightTriggerTolerance = XBOXTrig.getTolerance();
  leftTriggerMultiplier = rightTriggerMultiplier = XBOXTrig.getMultiplier();
  Y = gamepad.getButton(3);
  B = gamepad.getButton(1);
  A = gamepad.getButton(0);
  X = gamepad.getButton(2);
  R1 = gamepad.getButton(5);
  R3 = gamepad.getButton(9);
  L1 = gamepad.getButton(4);
  L3 = gamepad.getButton(8);
  DPad = gamepad.getCoolieHat(10);
  Select = gamepad.getButton(6);
  Start = gamepad.getButton(7);
  
  gamepad.setTolerance(0.1f);  //was 0.5f.
  leftTriggerTotalValue = rightTriggerTotalValue = 0;
  invertLeftX = invertLeftY = invertRightX = invertRightY = false;
}

// X value of the leftStick, adjusts for inversion
float leftX()
{
  int i = (invertLeftX ? -1 : 1);
  return leftStick.getX()*i;
}

// X value of the rightStick, adjusts for inversion
float rightX()
{
  int i = (invertRightX ? -1 : 1);
  return rightStick.getX()*i;
}

// Y value of the leftStick, adjusts for inversion
float leftY()
{
  int i = (invertLeftY ? 1 : -1);
  return leftStick.getY()*i;
}

// Y value of the rightStick, adjusts for inversion
float rightY()
{
  int i = (invertRightY ? 1 : -1);
  return rightStick.getY()*i;
}

// Returns the value of the left trigger in the case of the XBOX 360 controller
float leftZ()
{
  if ( XBOXTrig != null )
  {
    float v = leftTriggerMultiplier*XBOXTrig.getValue();
    if ( v > leftTriggerTolerance ) 
    {
      leftTriggerTotalValue += v;
      return v;
    }
    else return 0;
  }
  else if ( L2 != null )
  {
    if ( L2.pressed() )
    {
      leftTriggerTotalValue += leftTriggerMultiplier;
      return leftTriggerMultiplier;
    }
    else return 0;
  }
  else return 0;
}

// Returns the value of the right trigger in the case of the XBOX 360 controller
float rightZ()
{
  if ( XBOXTrig != null )
  {
    float v = -rightTriggerMultiplier*XBOXTrig.getValue();
    if ( v > rightTriggerTolerance ) 
    {
      rightTriggerTotalValue += v;
      return v;
    }
    else return 0;
  }
  else if ( R2 != null )
  {
    if ( R2.pressed() )
    {
      rightTriggerTotalValue += rightTriggerMultiplier;
      return rightTriggerMultiplier;
    }
    else return 0;
  }
  else return 0;
}

// Returns true if the Y button is pressed
boolean Y() { return Y.pressed(); }

// Returns true if the B button is pressed
boolean B() { return B.pressed(); }
boolean A() { return A.pressed(); }
boolean X() { return X.pressed(); }
boolean L1(){ return L1.pressed(); }

boolean L2()
{
  if ( L2 != null ) return L2.pressed();
  else if ( XBOXTrig != null ) return leftZ() > 0;
  else return false;
}

boolean L3() { return L3.pressed(); }
boolean R1() { return R1.pressed(); }

boolean R2()
{
  if ( R2 != null ) return R2.pressed();
  else if ( XBOXTrig != null ) return rightZ() > 0;
  else return false;
}

boolean R3() { return R3.pressed(); }
boolean Start() { return Start.pressed(); }
boolean Select() { return Select.pressed(); }

boolean DUp()
{
  if ( DPadUp != null ) return DPadUp.pressed();
  else if ( DPad != null ) return DPad.getY() < 0;
  else return false;
}

boolean DDown()
{
  if ( DPadDown != null ) return DPadDown.pressed();
  else if ( DPad != null ) return DPad.getY() > 0;
  else return false;
}

boolean DLeft()
{
  if ( DPadLeft != null ) return DPadLeft.pressed();
  else if ( DPad != null ) return DPad.getX() < 0;
  else return false;
}

boolean DRight()
{
  if ( DPadRight != null ) return DPadRight.pressed();
  else if ( DPad != null ) return DPad.getX() > 0;
  else return false;
}

