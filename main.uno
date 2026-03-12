#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// Pin definitions
const int piezoPin = A0;   
const int ledPin = 8;      

// Threshold for detecting a step
const int threshold = 200;  

// Variables
int stepCount = 0;
int prevState = 0;

// Timing control
unsigned long previousMillis = 0;
const long interval = 200;   // debounce time (200ms)

// Voltage variables
float vin = 5.0;
float vout = 0;
float actualVoltage = 0;

// Initialize LCD
LiquidCrystal_I2C lcd(0x27, 16, 2);

void setup() {

  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);

  Serial.begin(9600);

  lcd.init();
  lcd.backlight();

  // Startup screen
  lcd.setCursor(4,0);
  lcd.print("Piezowalk");

  lcd.setCursor(3,1);
  lcd.print("Generator");

  delay(2000);
  lcd.clear();

  // Display layout
  lcd.setCursor(0,0);
  lcd.print("Steps: 0");

  lcd.setCursor(0,1);
  lcd.print("Voltage: 0V");

  Serial.println("Piezowalk Generator Started...");
}

void loop() {

  unsigned long currentMillis = millis();

  int sensorValue = analogRead(piezoPin);

  // Print for debugging
  Serial.print("Sensor: ");
  Serial.println(sensorValue);

  // LED indication
  if(sensorValue > threshold)
  {
    digitalWrite(ledPin, HIGH);
  }
  else
  {
    digitalWrite(ledPin, LOW);
  }

  // Step detection
  if(currentMillis - previousMillis >= interval)
  {
    previousMillis = currentMillis;

    if(sensorValue > threshold && prevState == 0)
    {
      stepCount++;

      // Calculate voltage
      vout = (sensorValue * vin) / 1023.0;
      actualVoltage = vout * 11.0;   // for 100k/10k divider

      // Update LCD
      lcd.setCursor(7,0);
      lcd.print("    ");
      lcd.setCursor(7,0);
      lcd.print(stepCount);

      lcd.setCursor(9,1);
      lcd.print("     ");
      lcd.setCursor(9,1);
      lcd.print(actualVoltage,1);
      lcd.print("V");

      prevState = 1;
    }

    if(sensorValue < threshold)
    {
      prevState = 0;
    }
  }
}
