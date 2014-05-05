part of game_core;

class Screen {
  static int get height => _screenDevice.height;
  static int get width => _screenDevice.width;
  static bool get mouseLocked => _screenDevice.mouseLocked;
  static bool get fullscreen => _screenDevice.fullscreen;
}