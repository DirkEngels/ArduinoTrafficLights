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
int current = 6;
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,1,99 };
Server server(80);
int stateGreen = 0;
int stateYellow = 0;
int stateRed = 0;
int stateProgress = 0;


/**
 * Store HTML blocks in flash memory
 */
#define STRING_BUFFER_SIZE 128
#define HTML_HEADER 0
#define HTML_FOOTER 1
#define HTML_LOGO1 2
#define HTML_LOGO2 3
#define HTML_LOGO3 4
#define HTML_LOGO4 5
#define HTML_LOGO5 6
#define HTML_LOGO6 7
#define HTML_LOGO7 8

PROGMEM prog_char html_header[] = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n<html>\n<head>\n  <title>Ibuildings Traffic Light</title>\n  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n  <style type=\"text/css\">\n#logo { \n  margin-top: 10px;\n  margin-left: 25px;\n}\n#centered {\n  background-color: #FFFFFF;\n  position: fixed;\n  top: 50%;\n  left: 50%;\n  margin-top: -250px;\n  margin-left: -200px;\n  width: 400px;\n  height: 500px;\n\n  border-radius: 10px; \n  -moz-border-radius: 10px; \n  -webkit-border-radius: 10px; \n  border: 5px solid #A50013;\n}\nbody {\n  background-color: #F4F4F4;\n}\ninput {\n  margin-left: 25px;\n}\n\n#disclaimer {\n  position: absolute;\n  bottom: 10px;\n  margin-left: 90px;\n  font-size: 10px;\n}\n#lights {\n  margin-left: 160px;\n}\n.green {\n  background-image: -moz-radial-gradient(45px 45px 45deg, circle cover, greenyellow 0%, darkgreen 100%);\n  background-image: -webkit-radial-gradient(45px 45px, circle cover, greenyellow, darkgreen);\n  background-image: radial-gradient(45px 45px 45deg, circle cover, greenyellow 0%, darkgreen 100%);\n}\n.red {\n  background-image: -moz-radial-gradient(45px 45px 45deg, circle cover, red 0%, darkred 100%);\n  background-image: -webkit-radial-gradient(45px 45px, circle cover, red, darkred);\n  background-image: radial-gradient(45px 45px 45deg, circle cover, red 0%, darkred 100%);\n}\n.yellow {\n  background-image: -moz-radial-gradient(45px 45px 45deg, circle cover, yellow 0%, orange 100%);\n  background-image: -webkit-radial-gradient(45px 45px, circle cover, yellow, orange);\n  background-image: radial-gradient(45px 45px 45deg, circle cover, yellow 0%, orange 100%);\n}\n.gray {\n  background-image: -moz-radial-gradient(45px 45px 45deg, circle cover, lightgray 0%, darkgray 100%);\n  background-image: -webkit-radial-gradient(45px 45px, circle cover, lightgray, darkgray);\n  background-image: radial-gradient(45px 45px 45deg, circle cover, lightgray 0%, darkgray 100%);\n}\n.circle {\n  margin-left: 8px;\n  margin-top: 5px;\n  margin-bottom: 5px;\n  border-radius: 50%;\n  width: 75px;\n  height: 75px;\n}\n  </style>\n</head>\n<body>\n\n<div id=\"centered\">\n";
PROGMEM prog_char html_footer[] = "<div id=\"disclaimer\">\nCreated by: <a href=\"http://www.dirkengels.com\" target=\"_blank\">Dirk Engels</a>\nUsed by: <a href=\"http://www.ibuildings.nl\" target=\"_blank\">Ibuildings</a>\n</div>\n\n</div>\n\n</body>\n</html>";
PROGMEM prog_char html_logo1[] = "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";
PROGMEM prog_char html_logo2[] = "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";
PROGMEM prog_char html_logo3[] = "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";
PROGMEM prog_char html_logo4[] = "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";
PROGMEM prog_char html_logo5[] = "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";
PROGMEM prog_char html_logo6[] = "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";
PROGMEM prog_char html_logo7[] = "aCP9q31XI8SSOvqOL4hWPKyzErLol5ZpDLLYwhCEhKUjwAEVtQ6FRq1q5eS6tTJSeMumRLPXtJX1ZKF5IyN2cD9EEEPztBcwEc/Irn6GRzY53A65R99q9GqEhJzt6WPITcs0/KuTUwhTTiAUkdUN2DujDWDT0T9pXlYa1lEnITTzDDyR5YQrJGfEgjjnfBBCr2jj9pI/6rbxPcMPGuwBHbxCLrwaSzk9dV4yr9UdaAtWXXKS6WmynripIQVqJJx5PKJHp3R6XULtvGanqfKzL7Fa+CcdaSpSMISRgkbt++CCBUftsYXa6nwTeNfQzVDI9AGstb5kE/WSVDdda4Lf1Qlp00uRqQNKS31U23toGXFnOPHdGbuW8Z1vSGiXAim0pTcxjrpJ2XK2ikbSUpTv8AJxgHnBBCz5ntmmAOw8wttDQwSUVA9zblzgDvtqiw+0U7SutXFJGUbeqDypoSxl8y7PAFARtbxjzx1aEPi4bjqN19kkqcpMuJTssmzsNqO1tdYrfvVy4cIIILE48WFvK10lVRtFHXS29oPy3+Wgsvu1KQmt6G1ORVMKYInJh5DgTtYU2+VjI5g7OPbHfo3OTl33LN3fU3GkPysr9T22GWyE7IVtFRJJySeUEEXZ72EdY8NkvN0Stdza+w+WY6/XYKF12gyc/pRWKyrLc5T6zNdW4n75ClpBQfNwPs9MTi6ZB65NQ7eoBqMzT25GkKn23pfG2HCUo5gjcPnMEEVYxpsOvLf7USeeQNc6+rDLb5aN/ErAlK5HSnUC2C6p9ikTSm2HF/GKVlKiCB58/pjJaSalVi6ZqdpkxJyUumUp6nWloCidpOyBkE7xvgggXFeyaNrTofIlO+qQz4bUyyNu5paQeolrL/AFrE6azzt3aly0xMSlNp79G61S3JKV6tU0VJ2PK37hzxvi+wN0EEP4Y4uhJO9ytB6WRMhrhGwWaGi3fr4lcjjAYII2K5dcR9CCCIsogggiKIgggiKIgggiKIgggiKIgggiKIgggiKL//2Q==";

PGM_P html_blocks[] PROGMEM = { html_header, html_footer, html_logo1, html_logo2, html_logo3, html_logo4, html_logo5, html_logo6, html_logo7 };


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
  
  // Loop leds 3x3 times
  Serial.println("Testing all the lights");
  for(int i = 0; i<13; i++) {
    next();
  }
  
  // Switch off power/progress led
  digitalWrite(7, LOW);
  Serial.println("Setup complete!");
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
        if ((firstLine) && (c != '\n')) {
          requestFirstLine += c;
        }

        // If you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so the reply can be sent
        if (c == '\n' && currentLineIsBlank) {
          // Switch leds according get request params
          params(requestFirstLine.substring(0,50));
          
          // Send standard header response
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println();

          // HTML Block: Header
          Serial.println("- Sending header");
          output(client,(char*)pgm_read_word(&(html_blocks[HTML_HEADER])));

          // HTML Block: Logo
          logo(client);
          
          // HTML Block: Body
          body(client);
          
          // HTML Block: Footer
          Serial.println("- Sending footer");
          output(client,(char*)pgm_read_word(&(html_blocks[HTML_FOOTER])));


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

  Serial.print("- Switching leds ");
  Serial.print(prev);
  Serial.print(" => ");
  Serial.println(current);

  digitalWrite(prev, LOW);
  digitalWrite(current, HIGH);
  delay(250); 
}


/**
 * Params
 * - Switch leds according params
 */
void params(String requestFirstLine) {
  // Print request params
  Serial.print("- Request data:");
  Serial.println(requestFirstLine);

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
 * Logo
 */
void logo(Client client) {
  // Debug
  Serial.println("- Sending logo");

  // HTML Logo
  client.println("<a href=\"http://www.ibuildings.nl/\" target=\"_blank\">");
  client.print("<img id=\"logo\" src=\"data:image/gif;base64,");

  // Read encoded image from flash memory in several parts
  output(client,(char*)pgm_read_word(&(html_blocks[HTML_LOGO1])));
  output(client,(char*)pgm_read_word(&(html_blocks[HTML_LOGO2])));
  output(client,(char*)pgm_read_word(&(html_blocks[HTML_LOGO3])));
  output(client,(char*)pgm_read_word(&(html_blocks[HTML_LOGO4])));
  output(client,(char*)pgm_read_word(&(html_blocks[HTML_LOGO5])));
  output(client,(char*)pgm_read_word(&(html_blocks[HTML_LOGO6])));
  output(client,(char*)pgm_read_word(&(html_blocks[HTML_LOGO7])));

  client.println("\" alt=\"Ibuildings Logo\" width=\"350\" height=\"85\" border=\"0\" />");
  client.println("</a>");
}


/**
 * Body
 */
void body(Client client) {
  // Debug
  Serial.println("- Sending body");

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
 * Output
 * - content split by buffer size
 */
void output(Client client, char *realword) {
  int total = 0;
  int start = 0;
  char buffer[STRING_BUFFER_SIZE];
  int realLen = strlen_P(realword);

  memset(buffer,0,STRING_BUFFER_SIZE);

  while (total <= realLen) {
    // print content
    strncpy_P(buffer, realword+start, STRING_BUFFER_SIZE-1);
    client.print(buffer);

    // more content to print?
    total = start + STRING_BUFFER_SIZE-1;
    start = start + STRING_BUFFER_SIZE-1;

  }
}
