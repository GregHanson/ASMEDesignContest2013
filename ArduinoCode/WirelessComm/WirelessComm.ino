#include <Servo.h>

//
// Pin assignments
//
#define STANDBY  4 //standby
#define CAM_POW 2 //camera power

//Left Hand Motors
#define PWM_LEFT  3 //Speed control 
#define LEFT_IN1  7 //Direction
#define LEFT_IN2  8 //Direction

//Right Hand Motors
#define PWM_RIGHT  5 //Speed control
#define RIGHT_IN1  13 //Direction
#define RIGHT_IN2  12 //Direction

//Claw servo
#define CLAW_OPEN  6//11
#define CLAW_UP  9
Servo clawOpenServo, clawUpServo;

//Camera Servos
#define CAM_PAN 10
#define CAM_TILT 11//6
Servo cameraPanServo, cameraTiltServo;

//
// Controller Commands
//
//

// Flags for camera and motors
#define FORWARD  0x1
#define BACKWARD  0x2
#define LEFT  0x4
#define RIGHT  0x8
#define BEGIN_COMMAND  0x7F

// Flags for controller buttons
#define A_BUTTON  0x1
#define B_BUTTON  0x2
#define X_BUTTON  0x4
#define Y_BUTTON  0x8
#define LB_BUTTON  0x10
#define RB_BUTTON  0x20
#define LT_BUTTON  0x40
#define RT_BUTTON  0x80

//
//Servo Values
//
#define OPEN_MAX 150
#define OPEN_MIN 15
#define UP_MAX 130
#define UP_MIN 95
#define STEP_SIZE 1
#define PAN_MIN 20
#define PAN_MAX 160
#define TILT_MIN 20
#define TILT_MAX 85

#define DELAY 900

int command[3];
int clawUpVal = UP_MIN;
int clawOpenVal = OPEN_MIN;
int camTiltVal = TILT_MAX;
int camPanVal = 90;
int delay_open = 0;
int delay_raise = 0;
int delay_pan = 0;
int delay_tilt = 0;
int motorSpeed = 0;

boolean opening, closing, raising, lowering, spinLeft, spinRight;
boolean panLeft, panRight, tiltUp, tiltDown;


void setup() {
  Serial.begin(19200);      

  Serial.println("Starting Arduino");
  
  // Setup pins
  pinMode(STANDBY, OUTPUT);
  //pinMode(CAM_POW, OUTPUT);

  pinMode(PWM_LEFT, OUTPUT);
  pinMode(LEFT_IN1, OUTPUT);
  pinMode(LEFT_IN2, OUTPUT);

  pinMode(PWM_RIGHT, OUTPUT);
  pinMode(RIGHT_IN1, OUTPUT);
  pinMode(RIGHT_IN2, OUTPUT);
  
  // "attach" pins to servo object.  write initial value
  clawOpenServo.attach(CLAW_OPEN);
  clawUpServo.attach(CLAW_UP);
  clawUpServo.write(UP_MIN);
  clawOpenServo.write(OPEN_MIN);

  cameraPanServo.attach(CAM_PAN);
  cameraTiltServo.attach(CAM_TILT);
  cameraPanServo.write(camPanVal);
  cameraTiltServo.write(camTiltVal);

  opening = closing = raising = lowering = spinLeft = spinRight = false;
  panLeft = panRight = tiltUp = tiltDown = false;
  
  //digitalWrite(CAM_POW, HIGH);
  
  clawOpenServo.write(OPEN_MAX);
  clawUpServo.write(UP_MAX);
  delay(2000);
  clawOpenServo.write(OPEN_MIN);
  delay(2000);
  clawUpServo.write(UP_MIN);
  
}


void loop() {

  // listen for wireless commands
  if (Serial.available() > 0) {
    Serial.println("data available");
    if (readCommand() > 0) {
      executeCommand();
    }
  }
  
  handleClaw();
  handleSpin();
  handleCamera();

}

void handleClaw(){
  
  if(raising){
    if(delay_raise==DELAY){
      clawUpVal = (clawUpVal-STEP_SIZE <= UP_MIN) ? UP_MIN : clawUpVal-STEP_SIZE;
      clawUpServo.write(clawUpVal); 
      delay_raise = 0;  
    } 
    delay_raise++;   
  }
  if(lowering){
    if(delay_raise==DELAY){
      clawUpVal = (clawUpVal+STEP_SIZE >= UP_MAX) ? UP_MAX : clawUpVal+STEP_SIZE;
      clawUpServo.write(clawUpVal);
      delay_raise = 0;
    }
    delay_raise++;
  }
}

void handleSpin(){
  
  int motorSpeed = 255;
  
  if(spinRight){
    Serial.println("SPINNING");
     digitalWrite(STANDBY, HIGH);
     digitalWrite(LEFT_IN1, LOW);
     digitalWrite(LEFT_IN2, HIGH);
     digitalWrite(RIGHT_IN1, LOW);
     digitalWrite(RIGHT_IN2, HIGH);
     analogWrite(PWM_RIGHT, motorSpeed);
     analogWrite(PWM_LEFT, motorSpeed); 
  }
  
  if(spinLeft){
      Serial.println("SPINNING left");
      digitalWrite(STANDBY, HIGH);
      digitalWrite(LEFT_IN1, HIGH);
      digitalWrite(LEFT_IN2, LOW);
      digitalWrite(RIGHT_IN1, HIGH);
      digitalWrite(RIGHT_IN2, LOW);
      analogWrite(PWM_RIGHT, motorSpeed);
      analogWrite(PWM_LEFT, motorSpeed);   
  }
  
}

void handleCamera(){
  if(panRight){
    if(delay_pan==DELAY){
      camPanVal = (camPanVal-STEP_SIZE <= PAN_MIN) ? PAN_MIN : camPanVal-STEP_SIZE;
      cameraPanServo.write(camPanVal);
      delay_pan = 0;
    }
    delay_pan++;   
  }
  if(panLeft){
    if(delay_pan==DELAY){
      camPanVal = (camPanVal+STEP_SIZE >= PAN_MAX) ? PAN_MAX : camPanVal+STEP_SIZE;
      cameraPanServo.write(camPanVal);    
      delay_pan = 0;
    }
    delay_pan++;
  }
  if(tiltUp){
    if(delay_tilt==DELAY){
      camTiltVal = (camTiltVal-STEP_SIZE <= TILT_MIN) ? TILT_MIN : camTiltVal-STEP_SIZE;
      cameraTiltServo.write(camTiltVal); 
      delay_tilt = 0;  
    } 
    delay_tilt++;   
  }
  if(tiltDown){
    if(delay_tilt==DELAY){
      camTiltVal = (camTiltVal+STEP_SIZE >= TILT_MAX) ? TILT_MAX : camTiltVal+STEP_SIZE;
      cameraTiltServo.write(camTiltVal);
      delay_tilt = 0;
    }
    delay_tilt++;
  }  
}

int readCommand() {
  int b = Serial.read();
  if (b == BEGIN_COMMAND) {
    command[0] = readByte();
    command[1] = readByte();
    command[2] = readByte();
    return 1;
  } else {
    return 0;
  }
}

// blocking read
int readByte() {
  while (true) {
    if (Serial.available() > 0) {
      return Serial.read();
    }
  }
}

//
// Reads Serial data from XBee
//
void executeCommand() {
  int motor_com = command[2] & 0x0F;
  int camera_com = (command[2] & 0xF0) >> 4;
  int motorSpeed = command[1]; 
  int button_com = command[0];
  
  //
  // Handle Motor Flags
  //
  
  // Enable Motors
  digitalWrite(STANDBY, HIGH);
  
  if (motor_com & FORWARD) {
    Serial.println("Going Stragiht");
    digitalWrite(LEFT_IN1, LOW);
    digitalWrite(LEFT_IN2, HIGH);
    digitalWrite(RIGHT_IN1, HIGH);
    digitalWrite(RIGHT_IN2, LOW);
    analogWrite(PWM_RIGHT, motorSpeed);
    analogWrite(PWM_LEFT, motorSpeed);
  }
  
  if (motor_com & BACKWARD) {
    Serial.println("Going Backward");    
    digitalWrite(LEFT_IN1, HIGH);
    digitalWrite(LEFT_IN2, LOW);
    digitalWrite(RIGHT_IN1, LOW);
    digitalWrite(RIGHT_IN2, HIGH);
    analogWrite(PWM_RIGHT, motorSpeed);
    analogWrite(PWM_LEFT, motorSpeed);
  }
  
  // Cuts power to motors if stopped
  if (!(motor_com & (FORWARD | BACKWARD | LEFT | RIGHT))) {
    digitalWrite(STANDBY, LOW);
  }
  
  if (motor_com & LEFT) {
      Serial.println("Going Left");    
      analogWrite(PWM_RIGHT, motorSpeed/3);
      analogWrite(PWM_LEFT, motorSpeed);
  }
  if (motor_com & RIGHT) {   
      Serial.println("Going Right");
      analogWrite(PWM_RIGHT, motorSpeed);
      analogWrite(PWM_LEFT, motorSpeed/3);
  }
  
  //
  // Handle Camera Flags
  //
  if (camera_com & RIGHT){
    panRight = true;
    delay_pan = 0;
    Serial.println("Panning right");
  }
  else{
    panRight = false;
  }
  if (camera_com & LEFT){
    panLeft = true;
    delay_pan = 0;
    Serial.println("Panning left");    
  }
  else{
    panLeft = false;
  }
  if (camera_com & BACKWARD){
    tiltUp = true;
    delay_tilt = 0;
    Serial.println("Tilting up");
  }
  else{
    tiltUp = false;
  }
  if (camera_com & FORWARD){
    tiltDown = true;
    delay_tilt = 0;
    Serial.println("Tilting down");    
  }
  else{
    tiltDown = false;
  }
  
  //
  // Handle Claw
  //
  
  //raise claw
  if (button_com & RB_BUTTON){
    raising = true;
    delay_raise = 0;
//    clawUpServo.write(UP_MIN);
//    clawUpVal = UP_MIN;
//    clawUpVal = (clawUpVal-5 <= 100) ? 100 : clawUpVal-5;
//    clawUpServo.write(clawUpVal);
//    Serial.println("Raising Claw");
//    Serial.print("Claw Up Val: ");
//    Serial.println(clawUpVal);  
  }
  else{
    raising = false;
  }
  
  //lower claw
  if (button_com & RT_BUTTON){
    lowering = true;
    delay_raise = 0;
//    clawUpServo.write(UP_MAX);
//    clawUpVal = UP_MAX;
//    clawUpVal = (clawUpVal+5 >= 160) ? 160 : clawUpVal+5;
//    clawUpServo.write(clawUpVal);    
//    Serial.println("Lowering Claw");
//    Serial.print("Claw Up Val: ");
//    Serial.println(clawUpVal);
  }
  else{
    lowering = false;
  }
  
  //Close claw
  if (button_com & LT_BUTTON){
    opening = true;
    Serial.println("Closing Claw");
    clawOpenServo.write(OPEN_MIN);
    clawOpenVal = OPEN_MIN;
//    clawOpenVal = (clawOpenVal-5 <= 15) ? 15 : clawOpenVal-5;
//    clawOpenServo.write(clawOpenVal);
//    Serial.print("Claw Open Val: ");
//    Serial.println(clawOpenVal);
  }
  else{
    opening = false; 
  }
  
  //Open claw
  if (button_com & LB_BUTTON){
    closing = true;   
    Serial.println("Opening Claw");
    clawOpenServo.write(OPEN_MAX);
    clawOpenVal = OPEN_MAX;
//    clawOpenVal = (clawOpenVal+5 >= 160) ? 160 : clawOpenVal+5;
//    clawOpenServo.write(clawOpenVal); 
//    Serial.print("Claw Open Val: ");
//    Serial.println(clawOpenVal);
  }
  else{
    closing = false;
  }
  
  //
  // Handle Buttons
  //
  if (button_com & X_BUTTON){
    spinLeft = true ;
    Serial.println("Spinning left");
  }
  else{
    spinLeft = false;
  }
  
  if (button_com & B_BUTTON){
    spinRight = true;
    Serial.println("Spinning right");
  }
  else{
    spinRight = false;
  }
  
  // Centers camera
  if (button_com & A_BUTTON){
    Serial.println("Centering Camera");
    camTiltVal = TILT_MAX;
    camPanVal = 90;
    cameraTiltServo.write(camTiltVal);
    cameraPanServo.write(camPanVal);
  }
  
  // Centers camera on the claw
  if (button_com & Y_BUTTON){
    Serial.println("Centering Camera On Claw");
    camTiltVal = 40;
    camPanVal = 110;
    cameraTiltServo.write(camTiltVal);
    cameraPanServo.write(camPanVal);
  }
}

