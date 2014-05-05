part of game_core;

class InputDevice {
  int get mouseLastFrameUpdate => -1;
  double get mouseLastUpdateTime => 0.0;
  int get mouseX => 0;
  int get mouseY => 0;
  int get mouseDx => 0;
  int get mouseDy => 0;
  int get mouseClampX => 0;
  int get mouseClampY => 0;
  int get wheelDx => 0;
  int get wheelDy => 0;
  bool get mouseWithinCanvas => true;

  double get mouseXaxis => 0.0;
  double get mouseYaxis => 0.0;


  bool buttonPressed(int buttonId) {
    return false;
  }
  bool buttonDown(int buttonId) {
    return false;
  }
  bool buttonUp(int buttonId) {
    return true;
  }
  bool buttonReleased(int buttonId) {
    return false;
  }
  double buttonTimePressed(int buttonId) {
    return 0.0;
  }
  double buttonTimeReleased(int buttonId) {
    return 0.0;
  }


  bool keyPressed(int keyId) {
    return false;
  }
  bool keyDown(int keyId) {
    return false;
  }
  bool keyUp(int keyId) {
    return true;
  }
  bool keyReleased(int keyId) {
    return false;
  }
  double keyTimePressed(int keyId) {
    return 0.0;
  }
  double keyTimeReleased(int keyId) {
    return 0.0;
  }
  
  dynamic getGamePad(int pad) {
    return null;
  }

  bool gamepadDigitalPressed(int keyId) {
    return false;
  }
  bool gamepadDigitalDown(int keyId) {
    return false;
  }
  bool gamepadDigitalUp(int keyId) {
    return true;
  }
  bool gamepadDigitalReleased(int keyId) {
    return false;
  }
  double gamepadDigitalTimePressed(int keyId) {
    return 0.0;
  }
  double gamepadDigitalTimeReleased(int keyId) {
    return 0.0;
  }
  double gamepadAnalogLastUpdateTime(int buttonId) {
    return 0.0;
  }
  int gamepadAnalogLastUpdateFrame(int buttonId) {
    return 0;
  }
  double gamepadAnalogValue(int buttonId) {
    return 0.0;
  }

}