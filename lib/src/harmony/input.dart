part of harmony;



/// Get Input of Gampads, Mouse and Keyboard
class Input {
  /// Mouse position x
  static int get mouseX => _inputManager.mouseX;
  /// Mouse position y
  static int get mouseY => _inputManager.mouseY;
  /// Mouse position x delta since last tick.
  static int get mouseDx => _inputManager.mouseDeltaX;
  /// Mouse position y delta since last tick.
  static int get mouseDy => _inputManager.mouseDeltaY;
  /// Mouse position x clamped to canvas
  static int get mouseClampX => _inputManager.mouseClampX;
  /// Mouse position y clamped to canvas
  static int get mouseClampY => _inputManager.mouseClampY;
  /// Mouse wheel delta x since last tick
  static int get wheelDx => _inputManager.mouseWheelDeltaX;
  /// Mouse wheel delta y since last tick
  static int get wheelDy => _inputManager.mouseWheelDeltaY;
  static bool get mouseWithinCanvas => _inputManager.withinCanvas;

  /// Is mouse button down?
  static bool buttonDown(int buttonId) {
    return _inputManager.isButtonPressed(buttonId);
  }

  /// Is keyboard key down?
  static bool keyDown(int keyId) {
    return _inputManager.isKeyPressed(keyId);
  }

  /*
  static bool buttonPressed(int buttonId) {
    return _inputDevice.buttonPressed(buttonId);
  }

  static bool buttonUp(int buttonId) {
    return _inputDevice.buttonUp(buttonId);
  }
  static bool buttonReleased(int buttonId) {
    return _inputDevice.buttonReleased(buttonId);
  }
  static double buttonTimePressed(int buttonId) {
    return _inputDevice.buttonTimePressed(buttonId);
  }
  static double buttonTimeReleased(int buttonId) {
    return _inputDevice.buttonTimeReleased(buttonId);
  }

  static bool keyPressed(int keyId) {
    return _inputDevice.keyPressed(keyId);
  }

  static bool keyUp(int keyId) {
    return _inputDevice.keyUp(keyId);
  }
  static bool keyReleased(int keyId) {
    return _inputDevice.keyReleased(keyId);
  }
  static double keyTimePressed(int keyId) {
    return _inputDevice.keyTimePressed(keyId);
  }
  static double keyTimeReleased(int keyId) {
    return _inputDevice.keyTimeReleased(keyId);
  }*/

  /// Gets Gampad by index
  /// returns null if gamepad for specific index is not pluged in
  static GamePad getGamePad(int idx) {
    return _inputManager.getGamePad(idx);
  }

  /*
  static bool gamepadDigitalPressed(int buttonId) {
    return _inputDevice.gamepadDigitalPressed(buttonId);
  }
  static bool gamepadDigitalDown(int buttonId) {
    return _inputDevice.gamepadDigitalDown(buttonId);
  }
  static bool gamepadDigitalUp(int buttonId) {
    return _inputDevice.gamepadDigitalUp(buttonId);
  }
  static bool gamepadDigitalReleased(int buttonId) {
    return _inputDevice.gamepadDigitalReleased(buttonId);
  }
  static double gamepadDigitalTimePressed(int buttonId) {
    return _inputDevice.gamepadDigitalTimePressed(buttonId);
  }
  static double gamepadDigitalTimeReleased(int buttonId) {
    return _inputDevice.gamepadDigitalTimeReleased(buttonId);
  }

  static double gamepadAnalogLastUpdateTime(int buttonId) {
    return _inputDevice.gamepadAnalogLastUpdateTime(buttonId);

  }
  static int gamepadAnalogLastUpdateFrame(int buttonId) {
    return _inputDevice.gamepadAnalogLastUpdateFrame(buttonId);
  }
  static double gamepadAnalogValue(int buttonId) {
    return _inputDevice.gamepadAnalogValue(buttonId);
  }*/

}

class GamePad {
  final List<num> _buttons = new List.filled(16, 0.0);
  final List<num> _axes = new List.filled(16, 0.0);

  /// Get the button state of specified [id]
  /// Returns a number between -1.0 and 1.0
  num getButton(int id) {
  	return _buttons[id];
  }
  /// Get the axis state of specified [id]
  /// Returns a number between -1.0 and 1.0
  num getAxis(int id) {
  	return _axes[id];
  }
  int get maxButtonId => 16;
  int get maxAxiesId => 16;
  bool get xButtonA => false;
  bool get xButtonB => false;
  bool get xButtonX => false;
  bool get xButtonY => false;
  bool get xButtonRB => false;
  bool get xButtonLB => false;
  bool get xStart => false;
  bool get xBack => false;
  double get xButtonLT => 0.0;
  double get xButtonLR => 0.0;
  double get xAnalogLeftAxisX => 0.0;
  double get xAnalogLeftAxisY => 0.0;
  double get xAnalogRightAxisX => 0.0;
  double get xAnalogRightAxisY => 0.0;
  bool get xDigitalAxisX => false;
  bool get xDigitalAxisY => false;
}



class Keyboard {
  static const int WIN_KEY_FF_LINUX = 0;
  static const int MAC_ENTER = 3;
  static const int BACKSPACE = 8;
  static const int TAB = 9;
  /** NUM_CENTER is also NUMLOCK for FF and Safari on Mac. */
  static const int NUM_CENTER = 12;
  static const int ENTER = 13;
  static const int SHIFT = 16;
  static const int CTRL = 17;
  static const int ALT = 18;
  static const int PAUSE = 19;
  static const int CAPS_LOCK = 20;
  static const int ESC = 27;
  static const int SPACE = 32;
  static const int PAGE_UP = 33;
  static const int PAGE_DOWN = 34;
  static const int END = 35;
  static const int HOME = 36;
  static const int LEFT = 37;
  static const int UP = 38;
  static const int RIGHT = 39;
  static const int DOWN = 40;
  static const int NUM_NORTH_EAST = 33;
  static const int NUM_SOUTH_EAST = 34;
  static const int NUM_SOUTH_WEST = 35;
  static const int NUM_NORTH_WEST = 36;
  static const int NUM_WEST = 37;
  static const int NUM_NORTH = 38;
  static const int NUM_EAST = 39;
  static const int NUM_SOUTH = 40;
  static const int PRINT_SCREEN = 44;
  static const int INSERT = 45;
  static const int NUM_INSERT = 45;
  static const int DELETE = 46;
  static const int NUM_DELETE = 46;
  static const int ZERO = 48;
  static const int ONE = 49;
  static const int TWO = 50;
  static const int THREE = 51;
  static const int FOUR = 52;
  static const int FIVE = 53;
  static const int SIX = 54;
  static const int SEVEN = 55;
  static const int EIGHT = 56;
  static const int NINE = 57;
  static const int FF_SEMICOLON = 59;
  static const int FF_EQUALS = 61;
  /**
   * CAUTION: The question mark is for US-keyboard layouts. It varies
   * for other locales and keyboard layouts.
   */
  static const int QUESTION_MARK = 63;
  static const int A = 65;
  static const int B = 66;
  static const int C = 67;
  static const int D = 68;
  static const int E = 69;
  static const int F = 70;
  static const int G = 71;
  static const int H = 72;
  static const int I = 73;
  static const int J = 74;
  static const int K = 75;
  static const int L = 76;
  static const int M = 77;
  static const int N = 78;
  static const int O = 79;
  static const int P = 80;
  static const int Q = 81;
  static const int R = 82;
  static const int S = 83;
  static const int T = 84;
  static const int U = 85;
  static const int V = 86;
  static const int W = 87;
  static const int X = 88;
  static const int Y = 89;
  static const int Z = 90;
  static const int META = 91;
  static const int WIN_KEY_LEFT = 91;
  static const int WIN_KEY_RIGHT = 92;
  static const int CONTEXT_MENU = 93;
  static const int NUM_ZERO = 96;
  static const int NUM_ONE = 97;
  static const int NUM_TWO = 98;
  static const int NUM_THREE = 99;
  static const int NUM_FOUR = 100;
  static const int NUM_FIVE = 101;
  static const int NUM_SIX = 102;
  static const int NUM_SEVEN = 103;
  static const int NUM_EIGHT = 104;
  static const int NUM_NINE = 105;
  static const int NUM_MULTIPLY = 106;
  static const int NUM_PLUS = 107;
  static const int NUM_MINUS = 109;
  static const int NUM_PERIOD = 110;
  static const int NUM_DIVISION = 111;
  static const int F1 = 112;
  static const int F2 = 113;
  static const int F3 = 114;
  static const int F4 = 115;
  static const int F5 = 116;
  static const int F6 = 117;
  static const int F7 = 118;
  static const int F8 = 119;
  static const int F9 = 120;
  static const int F10 = 121;
  static const int F11 = 122;
  static const int F12 = 123;
  static const int NUMLOCK = 144;
  static const int SCROLL_LOCK = 145;

  // OS-specific media keys like volume controls and browser controls.
  static const int FIRST_MEDIA_KEY = 166;
  static const int LAST_MEDIA_KEY = 183;

  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int SEMICOLON = 186;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int DASH = 189;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int EQUALS = 187;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int COMMA = 188;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int PERIOD = 190;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int SLASH = 191;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int APOSTROPHE = 192;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int TILDE = 192;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int SINGLE_QUOTE = 222;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int OPEN_SQUARE_BRACKET = 219;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int BACKSLASH = 220;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int CLOSE_SQUARE_BRACKET = 221;
  static const int WIN_KEY = 224;
  static const int MAC_FF_META = 224;
  static const int WIN_IME = 229;
}