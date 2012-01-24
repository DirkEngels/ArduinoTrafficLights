/**
 * Arduino Traffic Lights
 *
 * This is the arduino source code for the Arduino Traffic
 * Lights project. 

 * https://github.com/DirkEngels/ArduinoTrafficLights
 */ 

/**
 * Setup
 * - Set output pins
 * - Load serial support
 */
void setup() {                
  // Initialize output pins
  pinMode(4, OUTPUT);      // Green light
  pinMode(5, OUTPUT);      // Yellow light
  pinMode(6, OUTPUT);      // Red light
  pinMode(7, OUTPUT);      // Optional Power/Progress light
  
  // Setup serial debugging support
  Serial.begin(9600);
  Serial.println("Initializing device");
}

/**
 * Loop
 * - Blink leds
 */
void loop() {

}
