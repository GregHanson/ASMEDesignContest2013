#include <AFMotor.h>

#define MIN_THRESHOLD 50
#define NUM_DIGITAL_SAMPLES 12
#define NUM_ANALOG_SAMPLES 4
#define LED1 50
#define LED2 51
#define LED3 52
#define LED4 53
#define SCANNER_LIMIT 10000

AF_DCMotor leftRear(1, MOTOR12_1KHZ);
AF_DCMotor rightRear(2, MOTOR12_1KHZ);
AF_DCMotor rightFront(3, MOTOR34_1KHZ);
AF_DCMotor leftFront(4, MOTOR34_1KHZ);
AF_DCMotor motors[4] = {leftRear, rightRear, rightFront, leftFront};

int packet[32];
int digitalSamples[NUM_DIGITAL_SAMPLES];
int analogSamples[NUM_ANALOG_SAMPLES];

int xV;
int yV;
int x;
int y;
int right;
int left;

int lightsButtonState = 0;
int scannerButtonState = 0;
boolean lightsOn = false;
boolean scannerOn = false;
int scannerDir = -1;
int scannerPos = LED1;
int scannerCounter = 0;

void setup() {
  allStop();

  Serial.begin(115200); // Terminal
  Serial1.begin(9600); // XBee

  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);
}

void debug() {
    Serial.print("x = ");
    Serial.print(x);
    Serial.print("  y = ");
    Serial.print(y);

    Serial.print("   left = ");
    Serial.print(left);
    Serial.print("  right = ");
    Serial.print(right);

    Serial.println("");
    Serial.println("");
}


void setLights(int state) {
  digitalWrite(LED1, state);
  digitalWrite(LED2, state);
  digitalWrite(LED3, state);
  digitalWrite(LED4, state);
}
  

void loop() {
  if (readData()) {
    
    if (scannerOn) {
      digitalWrite(scannerPos, LOW);
      if ((scannerPos == LED4) || (scannerPos == LED1)) {
	scannerDir = -scannerDir; // reverse direction
      }
      scannerPos += scannerDir;
      digitalWrite(scannerPos, HIGH);
    } else {
      if (lightsOn) {
	setLights(HIGH);
      } else {
	setLights(LOW);
      }
    }
      

    xV = constrain(xV, 60, 1100);
    yV = constrain(yV, 0, 1075);
    x = map(xV, 60, 1100, -255, 255);
    y = map(yV, 0, 1075, 255, -255);

    mapSpeeds();

    //debug();
    setLeftSpeed(left);
    setRightSpeed(right);

  } else {
    allStop();
  }

  delay(100);
}

void mapSpeeds() {
  left = 0;
  right = 0;
  int dir = (y>0) ? 1 : -1;
  if (abs(y) >= abs(x/2)) {
    left = y;
    right = y;
    if (x>0) {
      // decrease right wheels speed
      right -= (dir * x);
      right = (dir>0) ? max(right, 0) : min(right, 0);
      // increase left speed a bit if turning in an arc
      left += (dir * (x/2));
      left = (dir>0) ? min(left, 255) : max(left, -255);
    } else {
      // decrease left wheels speed
      left -= (dir * -x);
      left = (dir>0) ? max(left, 0) : min(left, 0);
      // increase right speed a bit if turning in an arc
      right += (dir * (-x/2));
      right = (dir>0) ? min(right, 255) : max(right, -255);
    }
  } else {
    left = x;
    right = -x;
  }
}

int readByte() {
  while (true) {
    if (Serial1.available() > 0) {
      return Serial1.read();
    }
  }
}

void printPacket(int l) {
  for(int i=0;i<l;i++) {
    if (packet[i] < 0xF) {
      // print leading zero for single digit values
      Serial.print(0);
    }
    Serial.print(packet[i], HEX);
    Serial.print(" ");
  }
  Serial.println("");
}

boolean readData() {
  int reading;
  float mv;
  int digitalChannelMask;

  if (Serial1.available() > 0) {
    int b = Serial1.read();
    if (b == 0x7E) {
      packet[0] = b;
      packet[1] = readByte();
      packet[2] = readByte();
      int dataLength = (packet[1] << 8) | packet[2];

      for(int i=1;i<=dataLength;i++) {
        packet[2+i] = readByte();
      }
      int apiID = packet[3];
      packet[3+dataLength] = readByte(); // checksum
      
      //printPacket(dataLength+4);

      if (apiID == 0x92) {
        int analogSampleIndex = 19;
        digitalChannelMask = (packet[16] << 8) | packet[17];
        if (digitalChannelMask > 0) {
          int d = (packet[19] << 8) | packet[20];
          for(int i=0;i < NUM_DIGITAL_SAMPLES;i++) {
            digitalSamples[i] = ((d >> i) & 1);
          }
          analogSampleIndex = 21;
        }

        int analogChannelMask = packet[18];
	for(int i=0;i<4;i++) {
          if ((analogChannelMask >> i) & 1) {
            analogSamples[i] = (packet[analogSampleIndex] << 8) | packet[analogSampleIndex+1];
            analogSampleIndex += 2;
          } else {
            analogSamples[i] = -1;
          }
        }
      }
    }

    reading = analogSamples[2];  // pin 18
    xV = ((float)reading/(float)0x3FF)*1200.0;

    reading = analogSamples[1];  // pin 19
    yV = ((float)reading/(float)0x3FF)*1200.0;

    boolean lightsButtonPressed = ((digitalChannelMask >> 3) & 1) && (digitalSamples[3] == 0);
    if (lightsButtonPressed) {
      // toggle headlights
      if (lightsButtonState == 0) {
	lightsOn = !lightsOn;
      }
    }
    lightsButtonState = lightsButtonPressed;

    boolean scannerButtonPressed = ((digitalChannelMask >> 4) & 1) && (digitalSamples[4] == 0);
    if (scannerButtonPressed) {
      // toggle scanner
      if (scannerButtonState == 0) {
	scannerOn = !scannerOn;
	setLights(LOW);
      }
    }
    scannerButtonState = scannerButtonPressed;

    return true;
  } else {
    return false;
  }

}


void setLeftSpeed(int s) {
  if (abs(s) < MIN_THRESHOLD) {
    leftFront.setSpeed(0);
    leftRear.setSpeed(0);
    leftFront.run(RELEASE);
    leftRear.run(RELEASE);
  } else {
    if (s > 0) {
      leftFront.run(FORWARD);
      leftRear.run(FORWARD);
    } else {
      leftFront.run(BACKWARD);
      leftRear.run(BACKWARD);
    }
    s = abs(s);
    if (s > 250) {
      s = 255;
    }
    leftFront.setSpeed(s);
    leftRear.setSpeed(s);
  }
}

void setRightSpeed(int s) {
  if (abs(s) < MIN_THRESHOLD) {
    rightFront.setSpeed(0);
    rightRear.setSpeed(0);
    rightFront.run(RELEASE);
    rightRear.run(RELEASE);
  } else {
    if (s > 0) {
      rightFront.run(FORWARD);
      rightRear.run(FORWARD);
    } else {
      rightFront.run(BACKWARD);
      rightRear.run(BACKWARD);
    }
    s = abs(s);
    if (s > 250) {
      s = 255;
    }
    rightFront.setSpeed(s);
    rightRear.setSpeed(s);
  }
}

void allStop() {
  for(int m=0;m<4;m++) {
    motors[m].setSpeed(0);
    motors[m].run(RELEASE);
  }
}
