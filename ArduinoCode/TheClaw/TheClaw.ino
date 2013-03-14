#include <Firmata.h>
#include <Servo.h>
Servo servoOpen;
Servo servoUp;

int STBY = 10;

//Left Hand Motors
int PWMLeft = 3; //Speed control 
int LeftIN1 = 7; //Direction
int LeftIN2 = 8; //Direction

//Right Hand Motors
int PWMRight = 5; //Speed control
int RightIN1 = 13; //Direction
int RightIN2 = 12; //Direction

//Claw servo
int ClawOpen = 11;
int ClawUp = 9;

void analogWriteCallback(byte pin, int value)
{
    
    if(pin == ClawOpen)
      servoOpen.write(value);
    if(pin == ClawUp)
      servoUp.write(value);
//    if(pin == STBY)
//      digitalWrite(STBY, value);
//    if(pin == LeftIN2)
//      digitalWrite(LeftIN2, value);
//    if(pin == LeftIN1)
//      digitalWrite(LeftIN1, value);
//    if(pin == RightIN1)
//      digitalWrite(RightIN1, value);
//    if(pin == RightIN2)
//      digitalWrite(RightIN2, value);
//    if(pin == PWMRight)
//      analogWrite(PWMRight, value);
//    if(pin == PWMLeft)
//      analogWrite(PWMLeft, value);
      
}


void setup() 
{
    Firmata.setFirmwareVersion(0, 2);
    Firmata.attach(ANALOG_MESSAGE, analogWriteCallback);

    servoUp.attach(ClawUp);
    servoOpen.attach(ClawOpen);
//    pinMode(STBY, OUTPUT);
//
//    pinMode(PWMLeft, OUTPUT);
//    pinMode(LeftIN1, OUTPUT);
//    pinMode(LeftIN2, OUTPUT);
//  
//    pinMode(PWMRight, OUTPUT);
//    pinMode(RightIN1, OUTPUT);
//    pinMode(RightIN2, OUTPUT);
   
    Firmata.begin(57600);
}

void loop() 
{
    while(Firmata.available())
        Firmata.processInput();
}

