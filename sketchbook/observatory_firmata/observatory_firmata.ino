#include <EEPROM.h>

#include <ConfigurableFirmata.h>

#include <DigitalInputFirmata.h>
DigitalInputFirmata digitalInput;

#include <DigitalOutputFirmata.h>
DigitalOutputFirmata digitalOutput;

#include <AnalogInputFirmata.h>
AnalogInputFirmata analogInput;

#include <FirmataExt.h>
FirmataExt firmataExt;

#include <FirmataReporting.h>
FirmataReporting reporting;

// Lattepanda setup

#define RELAY_PINS_STOREP 0
#define RELAY_PINS_STOREN 1

// 3 digital, 3 analog
#define PLUG_3PINS 3
byte const PLUG_3PIN_D[PLUG_3PINS] = {9, 10, 11};
byte const PLUG_3PIN_A[PLUG_3PINS] = {0, 1, 2};

// Max 8 pins
#define RELAY_PINS 4
#define IS_PIN_RELAY(pin) ((pin == 6)||(pin == 18)||(pin == 19)||(pin == 20))
byte const RELAY_PIN[RELAY_PINS] = {6, 18, 19, 20}; // 14, 16, 18 20 on the rail contacts
byte relayState = 0x00;

void systemResetCallback()
{
  // Default configuration
  for (byte i = 0; i < TOTAL_PINS; i++)
    if (IS_PIN_RELAY(i))
      Firmata.setPinMode(i, OUTPUT);
    else if (IS_PIN_ANALOG(i))
      Firmata.setPinMode(i, PIN_MODE_ANALOG);
    else if (IS_PIN_DIGITAL(i))
      Firmata.setPinMode(i, INPUT);

  // Read relay state, and complement as checksum, else 0xFF
  {
    byte relayStateP = EEPROM.read(RELAY_PINS_STOREP);
    if (relayStateP = ~EEPROM.read(RELAY_PINS_STOREN))
      relayState = relayStateP;
  }

  // Setup relay pins from persistent storage
  for (int i = 0; i < RELAY_PINS; i++)
    digitalWrite(RELAY_PIN[i], (relayState >> i) & 0x01);
  
  firmataExt.reset();
}

void digitalWriteCallback(byte port, int value)
{
  byte newRelayState = relayState;

  for (int i = 0; i < RELAY_PINS; i++)
    if (port == RELAY_PIN[i])
      newRelayState = (newRelayState & ~(1 << i)) | (value << i);

  if (newRelayState != relayState)
  {
    EEPROM.write(0, newRelayState);
    EEPROM.write(1, ~newRelayState);
    relayState = newRelayState;
  }
  
  byte pin, lastPin, pinValue, mask = 1, pinWriteMask = 0;

  if (port < TOTAL_PORTS) {
    // create a mask of the pins on this port that are writable.
    lastPin = port * 8 + 8;
    if (lastPin > TOTAL_PINS) lastPin = TOTAL_PINS;
    for (pin = port * 8; pin < lastPin; pin++) {
      // do not disturb non-digital pins (eg, Rx & Tx)
      if (IS_PIN_DIGITAL(pin)) {
        // do not touch pins in PWM, ANALOG, SERVO or other modes
        if (Firmata.getPinMode(pin) == OUTPUT || Firmata.getPinMode(pin) == INPUT) {
          pinValue = ((byte)value & mask) ? 1 : 0;
          if (Firmata.getPinMode(pin) == OUTPUT) {
            pinWriteMask |= mask;
          } else if (Firmata.getPinMode(pin) == INPUT && pinValue == 1 && Firmata.getPinState(pin) != 1) {
            // only handle INPUT here for backwards compatibility
#if ARDUINO > 100
            pinMode(pin, INPUT_PULLUP);
#else
            // only write to the INPUT pin to enable pullups if Arduino v1.0.0 or earlier
            pinWriteMask |= mask;
#endif
          }
          Firmata.setPinState(pin, pinValue);
        }
      }
      mask = mask << 1;
    }
    writePort(port, (byte)value, pinWriteMask);
  }
}

void initTransport()
{
  //Serial1.begin(57600);
  //Firmata.begin(Serial1);
  Firmata.begin(57600);
}

void initFirmata()
{
  Firmata.setFirmwareVersion(FIRMATA_FIRMWARE_MAJOR_VERSION, FIRMATA_FIRMWARE_MINOR_VERSION);
  
  firmataExt.addFeature(digitalInput);
  firmataExt.addFeature(digitalOutput);
  firmataExt.addFeature(analogInput);
  firmataExt.addFeature(reporting);
  
  Firmata.attach(SYSTEM_RESET, systemResetCallback);
  Firmata.attach(DIGITAL_MESSAGE, digitalWriteCallback);
}

void setup()
{
  initFirmata();
  initTransport();
  Firmata.parse(SYSTEM_RESET);
}

void loop()
{
  digitalInput.report();
  
  while (Firmata.available())
  {
    Firmata.processInput();
  }
  
  if (reporting.elapsed())
  {
    analogInput.report();
  }
}
