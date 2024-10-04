#include <TeensyStep.h>

/*#include <Stepper.h>*/

/*==========================================================================

 ===========================================================================*/

/*#include "TeensyStep.h"*/

#define endstopPin 21 // for the switch
#define enablePin 14
#define dirPin 16
#define stepPin 15

#define MAXPOSITION 33000 // according to the current calibration code

long initial_homing=-200; // not used for now

//Serial interface setup
const byte numChars = 90;
char receivedChars[numChars];
boolean newData = false;

long stepperPosition = 0;

Stepper motor(stepPin, dirPin);      
  
StepControl controller;    // Use default settings 

void setup()
{
  Serial.begin(9600);
  
  motor
  .setAcceleration(10000) // 20 000
  .setMaxSpeed(16000);

  // Setting up Endstop pin
  pinMode(endstopPin,INPUT_PULLUP);

  // Setting up enable pin and enable the driver
  pinMode(enablePin,OUTPUT);
  digitalWrite(enablePin,LOW);

  // Setup LED pin for debugging  
  pinMode(LED_BUILTIN, OUTPUT);

  Serial.println("This may be sent before your PC is able to receive");
  while (!Serial && millis() < 15000) {
    // wait for Arduino Serial Monitor to be ready
  }
  Serial.println("This line will definitely appear in the serial monitor");
  //Serial.println("Running the homeStepper function...");

  // Home the stepper
  //Serial.println( motor.getPosition());
  //motor.setTargetRel(-1000);  // Set the position to move to
  //controller.move(motor);   // Start moving the stepper
  //Serial.println( motor.getPosition());
  
  //Serial.println(stepperPosition);
  homeStepper();
  //int endstopStatus = digitalRead(endstopPin);
}

void loop() 
{

  //Serial.print("Stepper position: ");
  //Serial.println(stepperPosition);
  // int endstopStatus = digitalRead(endstopPin);
  //Serial.print("Status of the pin: ");
  //Serial.println(digitalRead(endstopPin));
  //delay(1000);  // do not print too fast!

  recvWithEndMarker();
  showNewNumber(); 

  motor.setTargetAbs(stepperPosition);

  //Set the target position:
  if(stepperPosition <= MAXPOSITION && stepperPosition >= 0)
  {
    motor.setTargetAbs(stepperPosition);
    controller.move(motor);    // Do the move
  }
  else if (stepperPosition > MAXPOSITION)
  {
    stepperPosition = MAXPOSITION;
    Serial.print("Out of range! Setting position to MAXPOSITION: ");
    Serial.println(stepperPosition);
    motor.setTargetAbs(stepperPosition);
    controller.move(motor);    // Do the move
  }
  else if (stepperPosition < 0)
  {
    homeStepper();
  }

}

// Serial receive function
void recvWithEndMarker() {
    static byte ndx = 0;
    char endMarker = '\n';
    char rc;
    
    if (Serial.available() > 0) {
        rc = Serial.read();
        Serial.print((char)rc);

        if (rc != endMarker) {
            receivedChars[ndx] = rc;
            ndx++;
            if (ndx >= numChars) {
                ndx = numChars - 1;
            }
        }
        else {
            receivedChars[ndx] = '\0'; // terminate the string
            ndx = 0;
            newData = true;
        }
    }
}

void showNewNumber() {
    if (newData == true) {
        Serial.print("Current position: ");
        Serial.println(stepperPosition);
        stepperPosition = 0;             // new for this version
        stepperPosition = atol(receivedChars);   // new for this version
        Serial.print("New position: ");
        Serial.println(receivedChars);
        newData = false;
    }
}


// Homing routine
void homeStepper(){

  Serial.println("Calibrating device...");
  //Serial.println("Fast Homing begins:");
  int endstopStatus = digitalRead(endstopPin);
  Serial.print("Status of the pin: ");
  Serial.println(endstopStatus);

  // while (digitalRead(endstopPin)) {  // Make the Stepper move CCW until the switch is activated 
  // Serial.println("Switch activated");
  // motor.setTargetRel(initial_homing);  // Set the position to move to
  // controller.move(motor);   // Start moving the stepper
  // delay(4);
  // }

  while (digitalRead(endstopPin)==0) {  // Make the Stepper move CCW until the switch is activated 
    Serial.println("Switch not reached yet...");
    motor.setTargetRel(-300);  // Set the position to move to
    controller.move(motor);   // Start moving the stepper
    delay(2);
  }
  
  //Serial.println("Fast Homing ended");
  Serial.println("Switch reached...");
  endstopStatus = digitalRead(endstopPin);
  Serial.println(endstopStatus);

  Serial.println("Stepping now forward...");
  while (digitalRead(endstopPin)) {  // Make the Stepper move CCW until the switch is activated 
  //Serial.println("Stepping now forward...");
    motor.setTargetRel(5);  // Set the position to move to
    controller.move(motor);   // Start moving the stepper
    Serial.println(motor.getPosition());
    delay(2);
  }
  
  //Serial.println("Stepping now forward...");
  //Serial.println( motor.getPosition());
  //motor.setTargetRel(1500);
  //controller.move(motor);
  //delay(600);
  endstopStatus = digitalRead(endstopPin);
  Serial.println("Re-homing ");
  Serial.println(endstopStatus);
  Serial.println( motor.getPosition());
 

  //while (digitalRead(endstopPin)) {  // Make the Stepper move CCW until the switch is activated   
  //  motor.setTargetRel(-5);  // Set the position to move to
  //  controller.move(motor);   // Start moving the stepper
  //  Serial.println( motor.getPosition());
  //  delay(3);
  //}
  //endstopStatus = digitalRead(endstopPin);
  Serial.println("Finished.");
  //Serial.println(endstopStatus);
  stepperPosition = 0; 
  motor.setPosition(0);
}
