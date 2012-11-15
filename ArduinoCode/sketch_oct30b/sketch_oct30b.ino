void setup(){
 pinMode(7, OUTPUT);
Serial.begin(9600);
Serial.print("Begin Program");
}

void loop(){
  digitalWrite(7, HIGH);
  Serial.println("7 HIGH");
  delay(1000);
}
