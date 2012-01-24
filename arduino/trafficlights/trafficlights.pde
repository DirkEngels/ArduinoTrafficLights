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
String webRoot = "http://192.168.1.59/tmp/";

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
          // Switch leds according get request params
          params(requestFirstLine);
          
          // Send Response
          header(client);
          body(client);
          footer(client);

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


/**
 * Header
 */
void header(Client client) {
  // Send standard header response
  client.println("HTTP/1.1 200 OK");
  client.println("Content-Type: text/html");
  client.println();

  // HTML Header
  client.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">");
  client.println("<html>");
  client.println("<head>");
  client.println("  <title>Ibuildings Traffic Light</title>");
  client.println("  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">");
  client.print("  <link rel=\"stylesheet\" href=\"");
  client.print(webRoot);
  client.println("style.css\" type=\"text/css\" />");
  client.println("</head>");
  client.println("<body>");
  client.println("<div id=\"centered\">");
  client.println("<a href=\"http://www.ibuildings.nl/\" target=\"_blank\">");
  client.print("<img id=\"logo\" src=\"");
  client.print(webRoot);
  client.println("logo.jpg\" alt=\"Ibuildings Logo\" width=\"350\" height=\"85\" border=\"0\" />");
  client.println("</a>");
}


/**
 * Body
 */
void body(Client client) {
  // HTML Header
  client.println("<div id=\"lights\">");
  
  // Green
  client.print("  <div class=\"circle ");
  if (stateGreen == 1) {
    client.print("green");
  } else {
    client.print("gray");
  }
  client.println("\"></div>");
  client.println("  <form action=\"/\" method=\"GET\">");
  client.print("    <input type=\"submit\" name=\"green\" value=\"");
  if (stateGreen == 1) {
    client.print("off");
  } else {
    client.print("on");
  }
  client.println("\" />");
  client.println("  </form>");

  // Yellow
  client.print("  <div class=\"circle ");
  if (stateYellow == 1) {
    client.print("yellow");
  } else {
    client.print("gray");
  }
  client.println("\"></div>");
  client.println("  <form action=\"/\" method=\"GET\">");
  client.print("    <input type=\"submit\" name=\"yellow\" value=\"");
  if (stateYellow== 1) {
    client.print("off");
  } else {
    client.print("on");
  }
  client.println("\" />");
  client.println("  </form>");

  // Red
  client.print("  <div class=\"circle ");
  if (stateRed == 1) {
    client.print("red");
  } else {
    client.print("gray");
  }
  client.println("\"></div>");
  client.println("  <form action=\"/\" method=\"GET\">");
  client.print("    <input type=\"submit\" name=\"red\" value=\"");
  if (stateRed== 1) {
    client.print("off");
  } else {
    client.print("on");
  }
  client.println("\" />");
  client.println("  </form>");
  
  client.println("</div>");
}


/**
 * Footer
 */
void footer(Client client) {
  // HTML Footer
  client.println("<div id=\"disclaimer\">");
  client.println("  Created by: <a href=\"http://www.dirkengels.com\" target=\"_blank\">Dirk Engels</a>");
  client.println("  Used by: <a href=\"http://www.ibuildings.nl\" target=\"_blank\">Ibuildings</a>");
  client.println("</div>");
  client.println("</div>");
  client.println("</body>");
  client.println("</html>");
}

