// Observatory control firmware
// Author: eric.dejouhanet@gmail.com

#include <EEPROM.h>

// Lattepanda setup

#define RELAY_PINS_STOREP 0
#define RELAY_PINS_STOREN 1

// 3 digital, 3 analog
#define PLUG_3PINS 3
byte const PLUG_3PIN_D[PLUG_3PINS] = {9, 10, 11};
byte const PLUG_3PIN_A[PLUG_3PINS] = {0, 1, 2};

// Max 8 pins
#define RELAY_PINS 5
#define IS_PIN_RELAY(pin) ((pin == 5)||(pin == 6)||(pin == 18)||(pin == 19)||(pin == 20))
byte const RELAY_PIN[RELAY_PINS] = {5, 6, 18, 19, 20}; // 12, 14, 16, 18, 20 on the rail contacts
byte relayState = 0x01;

void setup()
{
  //while (!Serial);
  Serial.begin(57600);
  
  // Read relay state, and complement as checksum, else 0xFF
  {
    byte relayStateP = EEPROM.read(RELAY_PINS_STOREP);
    if (relayStateP = ~EEPROM.read(RELAY_PINS_STOREN))
      relayState = relayStateP;
  }

  // Setup relay pins from persistent storage
  for (int i = 0; i < RELAY_PINS; i++)
  {
    pinMode(RELAY_PIN[i], OUTPUT);
    digitalWrite(RELAY_PIN[i], (relayState >> i) & 0x01);
  }
}

int controlRelay(byte relay, int value)
{
  if (0 <= relay && relay < RELAY_PINS)
  {
    byte newRelayState = relayState;

    newRelayState = (newRelayState & ~(1 << relay)) | (value << relay);

    if (newRelayState != relayState)
    {
      EEPROM.write(0, newRelayState);
      EEPROM.write(1, ~newRelayState);
    
      relayState = newRelayState;

      digitalWrite(RELAY_PIN[relay], value);
    }

    return 0;
  }
  else return 2;
}

#define CMD_LEN 8
byte ring[CMD_LEN+1] = "     R?;";
byte * const rend = &ring[CMD_LEN];
byte * wr = ring;
byte * rd = ring;

#define RLEN()  ((rd<=wr)?    (wr-rd) : ((rend-rd)+(wr-ring)))
#define RDAT(i) ((rd+i<rend)? rd[i]   : (ring)[i-(rend-rd)])
#define RINC(i) do { int ofs=(i); rd = &RDAT(ofs); } while (false)

int serveRelayCommand()
{
  if ('R' != RDAT(0))
    return 0;

  if (RLEN() < 2)
    return 0;
    
  if ('?' == RDAT(1))
  {
    Serial.print("=R");
    for (int i = 0; i < RELAY_PINS; i++)
      Serial.print((relayState >> i) & 0x01);
    Serial.println();
    return 2;
  }

  if (RLEN() < 3)
    return 0;
  
  byte const id = RDAT(1), val = RDAT(2);
  if (('0' <= id && id <= '9') && ('0' <= val && val <= '1'))
  {
    Serial.println(controlRelay(id - '0', val - '0') % 10);
    return 3;
  }

  Serial.print("!R[0..");
  Serial.print(RELAY_PINS);
  Serial.println("][0|1];");
  return 3;
}

void loop()
{
  //bool cmd_complete = false;
  
  if (Serial.available()) // ->LE BUG<- il est là regarde
  {
    *wr = Serial.read();
    if (';' == *wr || '\r' == *wr || '\n' == *wr)
      *wr = ';';
    wr++;
    if (wr == rd || *rd == ';')
      rd++;
    if (wr == rend)
      wr = ring;
    if (rd == rend)
      rd = ring;
    /*Serial.print("> [");
    Serial.write(ring, CMD_LEN);
    Serial.print("] R:");
    Serial.print(rd-ring);
    Serial.print(" W:");
    Serial.print(wr-ring);
    Serial.print(" L:");
    Serial.println(RLEN());*/
    RINC(serveRelayCommand());
  }

  //RINC(serveRelayCommand());
}
