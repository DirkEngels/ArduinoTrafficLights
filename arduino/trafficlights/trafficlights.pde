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
          // Print request params
          Serial.print("- Request Info:");
          Serial.print(requestFirstLine);

          // Switch next led
          next();
          
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

