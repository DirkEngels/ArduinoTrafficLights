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
PROGMEM prog_char html_logo2[] = "IhjCCztWoJNxbjgEsUAILUA8ArQsZn1KiPt+wb0i1W07eDLS3FjjsY49Zhn2WY4X9CY5w/oZDnEiK95vjiWRYJYHG3gyQCHkQ5h6KmBflIAg9CTZoADcYGCl20CACgEYk9+DibxygC7ykrny+KcCORrKB5YwAOY9Zhy/UUIEUkuR1/GghAF4omRj+ZoYm2lv2+CGPGojwGyPhHwD8NxIAikuIISGib4xIqqENBkdtchS+nkWSCErvhL55wTIE4498tKBBKVoHuH5TCXYJY29qIIw8HLAcSVznHu9wG/pOokc+joRI76NheU4SjrH9MZE/BF4QiUdA5EFqJPFI22/4gBJOPu830RPJ9JYzBXtExpEoHIkwvuYbA/AxHy9YzgsIMw9jhjIeLsFjL+1mk2AGcpjF/rLSb26ATN8BUXiQ5IckAUBJfiBxJLZYDgQ2dBJrUhGbVvQNHUziDHL6RhEIXc4C1lGSLSynA4Y55XIu8AlzmWwk8myQL0/mR98A8kiCRMkyMgiACBBGkYwUiSMFOMRmHtGSITnEcqCALX44NCSe1CYoJ1oSbXgQoyJZhkV1VJIeLOcDm6rEyyAABmcA66QplR09J2BPmOLTJOtIwG8UwNGQ4PSfAQzoQAt6UJGYYTlxKOpR+ZHUkGzzN0wliVOXA9WQyEOaHwTjN6z3myFsah43QBoBhEANbIV1fWMtq6hOosrfIAAdjXmrMgHKTOMV8FR3/U1eq/lApFbxk8sJ/uxIBvubwkYLk74ZACXmERhuiPQ3l3BVPJ5A0wYl4BPAUqFN+mSSedLOfTK8XZJOMs7fNGAeIhHt/5Y5QNM603Ei0adviKDX1vL1tUqNrUloe1F2QWOVv7FAD1oAX99QIJcl0YctalDcTOpyhelTaWajC780FSsOyyFBP/sXrJ3K1aeVTJ5ISLGcB7TVJHvtKz/+KtH1PhV4HkTaAd6EEmiogUUNAqlyJ8Dckji3fXcjsDANTJJ9iIOWv8lTdpfjotHGtbRFPO1urvYbPbB2iq6FKGwB62HCPg4ViH3ZA1pR1MPkYx2CkGIA14jSXTZXwM+N8TELjKLHFdJwzhgJ/hOWkwB5+PiRQJ6kkNllVf8+LsPo9etSm1zbktwjDiGu3hXCARMMLWd3d/Syi8EM43rKOCTk0DIArJClkUDjt74BwqYQvJxNlOQO3O2pd3+6HFbgyxfFRYAksCsSfcyCsb7R8TV9k009q7epHyaJIsiZAFT0gQxlEMQs3nFSfljDYyX5RYMQ3WUA85LRMITumEUSj/QspwFW+IQtKkEEIlcPGoZpRYMeUMbAfKMLHuRpJCFs0Aa1gBWZsMZIcBvADcQBFa3ggwgs6tKSaJjDAJCtSNgLANtu2NoAeMFL5mEBFbSiYB+rxxMMV1B+XNaFA572YXQwQd8QYBTKc2e9/nsggkAHQN7dDTIYE/oyO244BB0HwAAq/u8949rJI1F29WzB6pWM4jcQIEIc+KCFCjRIAshu9nJZCO0+Srvf7kUx7ghgS3zlgw8xD0CaUy5nMHKjv74BA7vCITm+BWC1nczzhm0u2FyLBBo5ogAQGGYLbugjXSpoXgD+pnQWM12sYXa0xgdeA37DTGYnmQcQzD4FBxqQ6wSdVGTDpfBWrQMKYG+QAzahn5rfuu04H0ze+UaAB9SAD9Z4TEi4IWmkCWAN+jifs78M+EaT9dGDuYei7mffO6yjqPeYhxrUargOkOIeP/+NywXKbn5kQ3IBEMLj8rHf1vsmAmsgB7Y8/s/km/d5JPqQBOmmfgRthCQf1gADGq9IAiojRdEkGYUB5j//lYaESLzIf/4RiRJpZcIMRwAEVsAHvOBmLHEP3yAJV0AEUHAHvtAY86B/vBBQ6KALEshQJCEPn9AFDKgHbdN/3JAJZUAEAkiABugYviCB3GAY9pCC+rcNJiEPLrh/0kME5GQAhvcyEVBZIjEPwgAJZdAEQsAEzAINsYcSeDQP5rCES1hU3OISX/UxxWYS/CKF/dIYtiE+uccuJ3GF/ZJcogEyX2gwFlRsJ6V6YCQS9iBGAEAB0MANoxAHTyACDZCDADADFBMtiIGGKrEYRfGE0BKIgEEKFoV4IyEP/sIQBzj2GwXAf0FBFimQCqowiZRIibtgGKkgiZVIiaHgF4L4iUaRD0lwHycIRqVkDaAUeUJBFlxxFvyQFjcBirJIFPdgSL9hiI9jAcshAFzGH7BoFjzxi7M4jEFBbxHAC/lQSuzCCPxGAUkHFEDCFUgQjLBIjNYYE7ZQXAMwA4lgC8IgDLOgB47nG5QwhS3RCzyQjuq4juyYBobBjvDIjtc4jy2RD1oQc74BBUdIj/zYj/wwD6MzQQjAB+bojwb5ib8gBN72Mh";
PROGMEM prog_char html_logo3[] = "JABgF1kBA5jP1iDqQQB0ywAxi5LJSwDL9SZdcID3PwBiJpCfkQDW6gDvyACaYQEoYgkm5wCyMB/pIi2Qn1kA/g8AbjkA+gUAqPsQhu8AaPwA5glA+P8AZusAjp0C+AMJLwACzqsAhoIAqNMQg/+QaykA/FYJRuYAdNiQ12gAaW0JT30AliMAfK8BiWsAqPkQ6GIAam8Bj3AAi3cA/Y8AbecBiWcJUhEQx4UA+DsQtskAayUJARyRLwAAdKgAFi8Aj7kAsT0A38QAVsEBIu4ANogAax8Esa4ARhkAGNkA/KMAHScA9eEAb9YgM8kAYpwAVZWAQ4gAYrUAX5UA8oYARoAAJz8BhSwAJukAGREBIr4ANpgAaukA+lkAFnkAZwAA/1gANGYAdFgA35wAkcYAdY8Jn5sAR1/vAYRSADaZABmjCbKIAC6VAME8AM95cBPiAYogAC8HAY0pABaMAGWCAohUkUpsAB7hASjokN9SAFk8kPMLAI9VCTmgkL+eAFUZAPzTABz1APpRkSNhAI+RAJKEAPtlEEe5APnQAC9ECboHAPcrCe7ZABqZAPbhAEeLEChfAYeFEKKNAO9RAY6YABpUAPLgoHPtAOUaid/DAOGHAL+RAGUjCbKTABYxAM5xkSmgACGaAMISEKHGCf+ZAKGVANgeGR99kS+bmf/OCYKJACGRCgMMABKBAD6aCZPlAFGUCSDTqeGRAGEhoDWAACcjoS3YkFKMCatEkDSuCb+VCjveAP/nhAAysKAjIgA95RChgQpojwGF/QqFwwDvywCxnAATiQCojho+CAAcSQD3PgBEaaBRhgCEuaD0VgB1FgB1E6pSIxDjGQASzwB4S5pSrRpfw5AbeADEVApmJQC7XglyejAV4ACMXJoBPgCsjAmRJqBIDACe+Jp86KCU1Jm2fgBDSAozUqpHWQA4ixAl6QiYJSChwAC7UQDXA5DamAAougPemwC2GAAu/JqRgQDPkAB6JaDynQCZ15nvkwDaWKBikgKFJqnyEBD8UQCRhQDLYqFLj6pY8ZmWQKB8qgDJQ6rLIwEg06DfwQofxgA39wEho6EiCqDBigqfewAmFgDDhg1Zr8sAKGMBLkOgwVew/00Ai9EAwr0Aj3AAudoAxzcKH84KPwgAJwEAwxAAdG2gnjgALneQ+GwAE+8ANByg9SSrPPkA/YsAjKYAoL27BB8bCOCZmSGRIwcBMxi7EaOwEc67EgK7J7QLIoAAr5gAU0UJO7EAMTsATd8K1pGxKlcBMc0A7pIAUYgAFYkA75YAlOuwLFObR1EC2ykAIY4ATjcA/62gn8YAr+GgMbmg9O8AX7IAo3caG9gAMTwAF7UKsR+RGu+7qwG7uyO7u0W7u2e7u46xEBAQA7";

PGM_P html_blocks[] PROGMEM = { html_header, html_footer, html_logo1, html_logo2, html_logo3 };


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
