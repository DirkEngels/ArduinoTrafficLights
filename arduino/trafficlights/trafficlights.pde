/**
 * Arduino Traffic Lights
 *
 * This is the arduino source code for the Arduino Traffic
 * Lights project. 

 * https://github.com/DirkEngels/ArduinoTrafficLights
 */ 

/**
 * Include Libraries
 */
#include <SPI.h>
#include <Ethernet.h>


/**
 * Initialize variables
 */
int current = 4;
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,1,99 };
Server server(80);
int stateGreen = 0;
int stateYellow = 0;
int stateRed = 0;
int stateProgress = 0;


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
  
  // Switch on power/progress led
  digitalWrite(7, HIGH);

  // Setup serial debugging support
  Serial.begin(9600);
  Serial.println("Initializing device");

  // Initalize the Ethernet connection
  Serial.println("Initializing ethernet connection");
  Ethernet.begin(mac, ip);
  
  // Start the webserver
  Serial.println("Starting webserver");
  server.begin();
  
  // Switch off power/progress led
  digitalWrite(7, LOW);
  Serial.println("");
}

/**
 * Loop
 * - Listen for incoming connections
 * - Read (get) request
 * - Switch next led
 */
void loop() {
  // Listen for incoming clients
  Client client = server.available();
  String requestFirstLine = "";

  if (client) {
    // Print debug
    Serial.println("Accepted client");

    // An http request ends with a blank line
    boolean currentLineIsBlank = true;
    // Only the first line of the request is needed
    boolean firstLine = true;

    while (client.connected()) {
      if (client.available()) {
        // Append the character to get the uri string
        char c = client.read();
        if (firstLine) {
          requestFirstLine += c;
        }

        // If you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so the reply can be sent
        if (c == '\n' && currentLineIsBlank) {
          // Switch next led
//          next();
          
          // Switch leds according get request params
          params(requestFirstLine);

          
          // Send a standard http response header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println();

          break;
        }
        if (c == '\n') {
          // New line found
          currentLineIsBlank = true;
          firstLine = false;
        } 
        else if (c != '\r') {
          // Next line contains a character
          currentLineIsBlank = false;
        }
      }
    }

    // Give the web browser time to receive the data
    delay(10);

    // close the connection:
    client.stop();
    Serial.println("");
  }
}


/**
 * Next
 * - Switch off previous led
 * - Switch on next led
 */
void next() {
  int prev = current;
  current = (current>=7) ? 4 : current+1;

  Serial.println("Switching leds");
  Serial.print("- Prev: ");
  Serial.println(prev);
  Serial.print("- Next: ");
  Serial.println(current);

  digitalWrite(prev, LOW);
  digitalWrite(current, HIGH);
  delay(1000); 
}


/**
 * Params
 * - Switch leds according params
 */
void params(String requestFirstLine) {
  // Print request params
  Serial.print("- Request Info:");
  Serial.print(requestFirstLine);

  // Check get parameters: Green light
  if(requestFirstLine.indexOf("green=on") >0) {
    digitalWrite(4, HIGH);
    stateGreen = 1;
    Serial.println("- Switching green light to ON!");
  }
  if(requestFirstLine.indexOf("green=off") >0) {
    digitalWrite(4, LOW);
    stateGreen = 0;
    Serial.println("- Switching green light to OFF!");
  }

  // Check get parameters: Yellow light
  if(requestFirstLine.indexOf("yellow=on") >0) {
    digitalWrite(5, HIGH);
    stateYellow = 1;
    Serial.println("- Switching yellow light to ON!");
  }
  if(requestFirstLine.indexOf("yellow=off") >0) {
    digitalWrite(5, LOW);
    stateYellow = 0;
    Serial.println("- Switching yellow light to OFF!");
  }

  // Check get parameters: Red light
  if(requestFirstLine.indexOf("red=on") >0) {
    digitalWrite(6, HIGH);
    stateRed = 1;
    Serial.println("- Switching red light to ON!");
  }
  if(requestFirstLine.indexOf("red=off") >0) {
    digitalWrite(6, LOW);
    stateRed = 0;
    Serial.println("- Switching red light to OFF!");
  }

  // Check get parameters: All lights
  if(requestFirstLine.indexOf("all=on") >0) {
    digitalWrite(4, HIGH);
    digitalWrite(5, HIGH);
    digitalWrite(6, HIGH);
    stateGreen = stateYellow = stateRed = 1;
    Serial.println("- Switching all lights to ON!");
  }
  if(requestFirstLine.indexOf("all=off") >0) {
    digitalWrite(4, LOW);
    digitalWrite(5, LOW);
    digitalWrite(6, LOW);
    stateGreen = stateYellow = stateRed = 0;
    Serial.println("- Switching all lights to OFF!");
  }
}

