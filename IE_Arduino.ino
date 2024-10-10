/**
   WIRING:
   -----------------------------------------------------------------------------------------
               MFRC522      Arduino       Arduino   Arduino    Arduino          Arduino
               Reader/PCD   Uno/101       Mega      Nano v3    Leonardo/Micro   Pro Micro
   Signal      Pin          Pin           Pin       Pin        Pin              Pin
   -----------------------------------------------------------------------------------------
   RST/Reset   RST          Take an unused digital pin for each sensor
   SPI SS      SDA(SS)      Take an uned digital pin, same for all sensors
   SPI MOSI    MOSI         11 / ICSP-4   51        D11        ICSP-4           16
   SPI MISO    MISO         12 / ICSP-1   50        D12        ICSP-1           14
   SPI SCK     SCK          13 / ICSP-3   52        D13        ICSP-3           15

*/

#include <SPI.h>
#include <MFRC522.h>
#define SS_PIN          9        // Any unused digital pin
#define NR_OF_READERS   3         // How many readers do you have?

MFRC522 mfrc522[NR_OF_READERS];   // Create MFRC522 instances.

boolean makeContact = true;
int numRows;
int buttonPin = 4;   // pinFortheButton
int buttonState = 0;
int lastButtonState = 0;

String tags[][2] = {
  {"D9 BF 5C B3", "fish"},
  {"99 3A 59 B3", "fish"},
  {"99 30 59 B3", "fish"},
  {"49 D4 61 B3", "potato"},
  {"A9 FB 69 B3", "potato"},
  {"69 33 59 B3", "potato"},
  {"69 0A 42 C3", "potato"},
  {"69 3B 27 C3", "potato"},
  {"39 76 F8 C2", "potato"},
  {"89 A9 35 C2", "potato"},
  {"D9 E1 45 C2", "potato"},
  {"79 3C 68 B3", "apple"}, //stay
  {"59 10 6A B3", "apple"}, //stay
  {"79 CA EE A2", "apple"}, //stay
  {"F9 7C 27 A4", "apple"}, //stay
  {"19 9A 32 94", "apple"}, //stay
  {"57 14 84 5F", "apple"}, //stay
  {"1A 66 DE 3F", "water"},
  {"69 21 BA A3", "water"},
  {"CA 14 DF 3F", "water"},
  {"59 68 FE 98", "water"},
  {"39 B7 E1 C2", "water"},
  {"BA E7 F1 3F", "water"},
  {"69 42 07 98", "water"},
  {"79 23 5A C1", "carrot"},
  {"69 5C 68 B3", "carrot"},
  {"CA 3E 7B 25", "carrot"},
  {"79 A6 2C C3", "carrot"},
  {"39 30 59 B3", "carrot"},
  {"C9 55 69 B3", "carrot"},
  {"C9 55 69 B3", "carrot"},

};


byte RSTpins[] = {6, 7, 8};                               // Unique digital pin for each sensor

void setup() {
  pinMode(buttonPin, INPUT_PULLUP);    // declare pushbutton as input
  Serial.begin(9600); // Initialize serial communications with the PC
  SPI.begin();        // Init SPI bus
  numRows = sizeof(tags) / sizeof(tags[0]);
  Serial.println(numRows);
  if (makeContact) {
    establishContact(); //contact with processing via serial port
  }
  for (int i = 0; i < NR_OF_READERS; i++) pinMode(RSTpins[i], OUTPUT);
}

void loop() {
  for (uint8_t reader = 0; reader < NR_OF_READERS; reader++) {
    digitalWrite(RSTpins[reader], HIGH);                      // Turn on the sensor by setting the RST pin to HIGH
    //delay(40);                                                // Delay could be shortened/removed, test please
    mfrc522[reader].PCD_Init(SS_PIN, RSTpins[reader]);        // Init each MFRC522 card
    mfrc522[reader].PCD_SetRegisterBitMask(mfrc522[reader].RFCfgReg, (0x07 << 4));
    delay(80);                                                // Delay could be shortened/removed, test please
    if (mfrc522[reader].PICC_IsNewCardPresent() && mfrc522[reader].PICC_ReadCardSerial()) {
      mfrc522[reader].PICC_HaltA();                           // Stop reading
      mfrc522[reader].PCD_StopCrypto1();

      String content = "";
      byte letter;
      for (byte i = 0; i < mfrc522[reader].uid.size; i++)
      {
        content.concat(String(mfrc522[reader].uid.uidByte[i] < 0x10 ? " 0" : " "));
        content.concat(String(mfrc522[reader].uid.uidByte[i], HEX));
      }

      content.toUpperCase();
      boolean detected = false;
      for (byte i = 0; i < numRows; i = i + 1) {
        if (content.substring(1) == tags[i][0]) {
          Serial.println(tags[i][1]);
          detected = true;
        }
      }
      if (!detected) {
        for (byte i = 0; i < mfrc522[reader].uid.size; i++) {
          Serial.print(mfrc522[reader].uid.uidByte[i] < 0x10 ? " 0" : " ");
          Serial.print(mfrc522[reader].uid.uidByte[i], HEX);
        }
      }
      Serial.println();
    }

    digitalWrite(RSTpins[reader], LOW);  // Turn the sensor off by setting the RST pin to LOW
    //printIDs();
  }
  buttonState = digitalRead(buttonPin);
  // check if the button is pressed or released
  // by comparing the buttonState to its previous state
  if (buttonState != lastButtonState) {
    // change the state of the led when someone pressed the button
    if (buttonState == 0) {
      Serial.println("start");
    }
    // remember the current state of the button
    lastButtonState = buttonState;
  }
  // adding a small delay prevents reading the buttonState to fast
  // ( debouncing )
  delay(20);
}


void establishContact() {
  while (Serial.available() <= 0) {
    Serial.println("A");   // send a capital A
    delay(300);
  }
}
