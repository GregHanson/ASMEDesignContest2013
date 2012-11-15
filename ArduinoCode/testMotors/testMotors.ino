//left motors in parallel connected between A01 and A02
//right motors in parallel connected between B01 and B02

int STBY = 10; //standby

//Left Hand Motors
int PWMLeft = 3; //Speed control 
int LeftIN1 = 9; //Direction
int LeftIN2 = 8; //Direction

//Right Hand Motors
int PWMRight = 5; //Speed control
int RightIN1 = 11; //Direction
int RightIN2 = 12; //Direction

//car commands
const int left = 1;
const int right = 2;
const int forward = 3;
const int backward = 4;

void setup(){
  Serial.begin(9600);
  Serial.print("Program St
  pinMode(STBY, OUTPUT);

  pinMode(PWMLeft, OUTPUT);
  pinMode(LeftIN1, OUTPUT);
  pinMode(LeftIN2, OUTPUT);

  pinMode(PWMRight, OUTPUT);
  pinMode(RightIN1, OUTPUT);
  pinMode(RightIN2, OUTPUT);
}

void loop(){
  move(forward, 128);
  wait();
  
  move(backward, 128);
  wait();
  
  move(left, 128);
  wait();
  
  move(right, 128);
  wait();


}

void wait(){
  delay(1000); //go for 1 second
  stop(); //stop
  delay(250); //hold for 250ms until move again 
}

void move(int command, int speed){
//Move specific motor at speed and direction
//motor: 0 for B 1 for A
//speed: 0 is off, and 255 is full speed
//direction: 0 clockwise, 1 counter-clockwise

  digitalWrite(STBY, HIGH); //disable standby

  boolean leftPin1 = LOW;
  boolean leftPin2 = HIGH;
  boolean rightPin1 = HIGH;
  boolean rightPin2 = LOW;
  
  /*
  if(direction == 1){
    leftPin1 = HIGH;
    leftPin2 = LOW;
  }
  */
  
  switch(command){
    case left:
      leftPin1 = LOW;
      leftPin2 = HIGH;
      rightPin1 = LOW;
      rightPin2 = HIGH;
      
      digitalWrite(LeftIN1, leftPin1);
      digitalWrite(LeftIN2, leftPin2);
      analogWrite(PWMLeft, speed);
      
      digitalWrite(RightIN1, rightPin1);
      digitalWrite(RightIN2, rightPin2);
      analogWrite(PWMRight, speed);
      break;
      
    case right:
      leftPin1 = HIGH;
      leftPin2 = LOW;
      rightPin1 = HIGH;
      rightPin2 = LOW;
      
      digitalWrite(LeftIN1, leftPin1);
      digitalWrite(LeftIN2, leftPin2);
      analogWrite(PWMLeft, speed);
      
      digitalWrite(RightIN1, rightPin1);
      digitalWrite(RightIN2, rightPin2);
      analogWrite(PWMRight, speed);
      break;
      
    case forward:
      leftPin1 = LOW;
      leftPin2 = HIGH;
      rightPin1 = HIGH;
      rightPin2 = LOW;
      
      digitalWrite(LeftIN1, leftPin1);
      digitalWrite(LeftIN2, leftPin2);
      analogWrite(PWMLeft, speed);
      
      digitalWrite(RightIN1, rightPin1);
      digitalWrite(RightIN2, rightPin2);
      analogWrite(PWMRight, speed);
      break;
      
    case backward:
      leftPin1 = HIGH;
      leftPin2 = LOW;
      rightPin1 = LOW;
      rightPin2 = HIGH;
      
      digitalWrite(LeftIN1, leftPin1);
      digitalWrite(LeftIN2, leftPin2);
      analogWrite(PWMLeft, speed);
      
      digitalWrite(RightIN1, rightPin1);
      digitalWrite(RightIN2, rightPin2);
      analogWrite(PWMRight, speed);
      break;
      
    default:
       stop();
  }
}

void stop(){
//enable standby  
  digitalWrite(STBY, LOW);
}
