import cc.arduino.*;
import procontroll.*;
import processing.serial.*;

Arduino arduino;

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
float leftJoystickX, leftJoystickY, rightJoystickX, rightJoystickY;

int STBY = 10; //standby

//Motor A
int PWMA = 3; //Speed control 
int AIN1 = 9; //Direction
int AIN2 = 8; //Direction

//Motor B
int PWMB = 5; //Speed control
int BIN1 = 11; //Direction
int BIN2 = 12; //Direction

int speed = 128;


void setup()
{
  /*
  println(Arduino.list());
  
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  //arduino.pinMode(ledPin, Arduino.OUTPUT);
  
  arduino.pinMode(STBY, Arduino.OUTPUT);

  arduino.pinMode(PWMA, Arduino.OUTPUT);
  arduino.pinMode(AIN1, Arduino.OUTPUT);
  arduino.pinMode(AIN2, Arduino.OUTPUT);

  arduino.pinMode(PWMB, Arduino.OUTPUT);
  arduino.pinMode(BIN1, Arduino.OUTPUT);
  arduino.pinMode(BIN2, Arduino.OUTPUT);
  */
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
  leftJoystickX = leftX();
  leftJoystickY = leftY();
  rightJoystickX = rightX();
  rightJoystickY = rightY();
  println("Starting");
}

void draw()
{

  getControllerState();

  delay(50);
}

void getControllerState(){
  checkButtons();
  
  checkDPad();

  checkLeftJoyStick();
  
  checkRightJoyStick();
  
  checkBumpers();
  
}

void checkBumpers(){
 if(L1() && !l1Pressed){
  println("Left bumper pressed");
    l1Pressed = true; 
  }
  else if(!L1()){
   l1Pressed = false; 
  } 
 if(R1() && !r1Pressed){
  println("Right bumper pressed"); 
    r1Pressed = true; 
  }
  else if(!R1()){
   r1Pressed = false; 
  }
}

void checkLeftJoyStick(){
  
  float x = leftX();
  float y = leftY();
  
  if(L3() && !ljsPressed){
   println("Left Joystick Pressed");
    ljsPressed = true; 
  }
  else if(!L3()){
   ljsPressed = false; 
  }
  
  if(leftJoystickX != x || leftJoystickY != y){
    println("Y:  " + y + "     X:  " + x);
    leftJoystickX = x;
    leftJoystickY = y;
  }

}

void checkRightJoyStick(){
  
  float x = rightX();
  float y = rightY();
  
  if(R3() && !rjsPressed){
   println("Right Joystick Pressed");
    rjsPressed = true; 
  }
  else if(!R3()){
   rjsPressed = false; 
  }
  
  if(rightJoystickX != x || rightJoystickY != y){
    println("Y:  " + y + "     X:  " + x);
    rightJoystickX = x;
    rightJoystickY = y;
  }
  
}

void checkDPad(){
  if(DUp() && !dUpPressed){
   println("Up on DPad pressed");
   dUpPressed = true; 
  }
  else if(!DUp()){
   dUpPressed = false; 
  }
  if(DDown() && !dDownPressed){
   println("Down on DPad pressed");
   dDownPressed = true; 
  }
  else if(!DDown()){
   dDownPressed = false;  
  }
  if(DLeft() && !dLeftPressed){
   println("Left on DPad pressed"); 
   dLeftPressed = true; 
  }
  else if(!DLeft()){
   dLeftPressed = false; 
  }  
  if(DRight() && !dRightPressed){
   println("Right on DPad pressed"); 
   dRightPressed = true; 
  }
  else if(!DRight()){
   dRightPressed = false; 
  }  
}

void checkButtons(){
  if(Y() && !yPressed){
    println("Y pressed"); 
    yPressed = true;
  }
  else if (!Y()){
   yPressed = false; 
  }
  if(B() && !bPressed){
    println("B pressed"); 
    bPressed = true;
  }
  else if (!B()){
   bPressed = false; 
  }
  if(A() && !aPressed){
    println("A pressed"); 
    aPressed = true;
  }
  else if (!A()){
   aPressed = false; 
  }
  if(X() && !xPressed){
    println("X pressed"); 
    xPressed = true;
  } 
  else if (!X()){
   xPressed = false; 
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
     ---- for mapping 360 controller on a mac
  //sliders
  sliderWheel = controlDevice.getSlider(2);
  sliderThrottle = controlDevice.getSlider(5);
  sliderReverse = controlDevice.getSlider(4);
  sliderCameraX = controlDevice.getSlider(0);
  //buttons
  buttonStart = controlDevice.getButton(4);      //START BUTTON
  buttonESC = controlDevice.getButton(5);     //BACK BUTTON
  buttonSendSettings = controlDevice.getButton(4); //start button, clutch must be in.
  buttonResetOnFlatline = controlDevice.getButton(5);      //back BUTTON (clutch must be in for this one to work).
 
  buttonGEARUP = controlDevice.getButton(9);        //RB
  buttonGEARDOWN = controlDevice.getButton(8);       //LB
 
  buttonCLUTCH = controlDevice.getButton(7);    //RJD
 
  buttonCentreCamera = controlDevice.getButton(6);    //LJD (also pressed to adjust camera trim).
  buttonAutoCamera = controlDevice.getButton(11);    //A. autoCamera ON/OFF
  buttonCameraMoveLeft = controlDevice.getButton(13);       //X
  buttonCameraMoveRight = controlDevice.getButton(12);        //B
 
  buttonCalibrateSensors = controlDevice.getButton(14);        //Y  (clutch must be in. calibrates sensors. Vehicle should be stopped!!)
  buttonSendFFaccels = controlDevice.getButton(14);        //Y (when clutch is NOT in).
 
  //cooliehat
  //handled by cooliehat: steering trim (when clutch is depressed) and camera trim (when cameraCentre is depressed).
  coolieUP = controlDevice.getButton(0);    //cooliehat UP
  coolieDOWN = controlDevice.getButton(1);    //cooliehat DOWN
  coolieLEFT = controlDevice.getButton(2);    //cooliehat LEFT
  coolieRIGHT = controlDevice.getButton(3);    //cooliehat RIGHT 
  */
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
  
  gamepad.setTolerance(0.05f);  //was 0.5f.
  
  
  /*
  wheelMovementMin = 0.001;  //wheel has to be moved this much in order to calculate new value.
  wheelStickDeadZone = 0.005;    //stick neutral deadzone
  wheelHardValue = 0.93;
  wheelPOW = 1.0;
  pedalDeadZone = 0.004;
  pedalMovementMin = 0.002;
  pedalHardValue = 0.95;
  cameraMoveInterval = 6; //milliseconds between camera steps.
  cameraMovementMin = 0.01; //if camera movement is controlled by a stick, the stick has to be moved this much to calculate a new value.
  cameraStickDeadZone = 0.2;
  cameraHardValue = 0.90;
  cameraMaxStep = 6;
  cameraMinStep = 1;
  hasCoolieHat = true;    //the controller has a cooliehat.
  coolieIsCoolie = true;  //the cooliehat is broken into buttons.
  clutchForGears = true;  //does the clutch need to be depressed to change gears?
  hasSlidingClutch = false;
  hasForRevGear = false;  //false. used to determine if we should pay attention to "direction".
  oneSliderForThrottle = true; //even though there are two pedals, on this controller in windows one slider represents both pedals.
  hasReversePedal = false; //this controller does not have a dedicated reverse pedal.
  wheelIsStick = true;    //steering is controlled by a stick.
  throttleIsStick = false; //make sure you use pedal deadzones.
  hasCameraStick = true;   //is camera control a stick on this controller?
  hasCameraButtons = true;
  hasCameraCentreButton = true;
  hasRumblers = 2;  //controller has rumblers, though I can't get them to work.
  maxRumbleIntensity = 1.0;
  throttleBase = 2;  //0 = -1 to 1, rests at 0. 1 = -1 to 1, rests at -1. 2= SPLIT across two padels, rests at 0, range: 1 to -1.
  reverseBase = 0;
  clutchBase = 0;
  //sliders
  sliderWheel = controlDevice.getSlider(3);
  sliderThrottle = controlDevice.getSlider(4);
  sliderCameraX = controlDevice.getSlider(1);
  //stick = new ControllStick(sliderWheel,sliderThrottle);
  //buttons
  buttonStart = controlDevice.getButton("Button 7");      //START BUTTON
  buttonESC = controlDevice.getButton("Button 6");     //BACK BUTTON
  buttonSendSettings = controlDevice.getButton("Button 7");      //START BUTTON, clutch must be in.
  buttonResetOnFlatline = controlDevice.getButton("Button 6");      //BACK BUTTON (clutch must be in for this one to work).
 
  buttonGEARUP = controlDevice.getButton("Button 5");        //RB
  buttonGEARDOWN = controlDevice.getButton("Button 4");       //LB
  buttonCLUTCH = controlDevice.getButton("Button 9");    //RJD
 
  buttonCentreCamera = controlDevice.getButton("Button 8");    //LJD  (press to adjust camera trim).
  buttonAutoCamera = controlDevice.getButton("Button 0");    //A. autoCamera ON/OFF
  buttonCameraMoveLeft = controlDevice.getButton("Button 2");       //X
  buttonCameraMoveRight = controlDevice.getButton("Button 1");        //B
 
  buttonCalibrateSensors = controlDevice.getButton("Button 3");        //Y  (clutch must be in. calibrates sensors. Vehicle should be stopped!!)
  buttonSendFFaccels = controlDevice.getButton("Button 3");        //Y (when clutch is NOT in).
 
  //cooliehat
  //handled by cooliehat: steering trim (when clutch is depressed) and camera trim (when cameraCentre is depressed).
  cooliehat = controlDevice.getCoolieHat(10);
  */
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
