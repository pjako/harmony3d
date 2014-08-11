part of harmony;

class Screen {
  static int get height => _graphicsDevice.realHeight;
  static int get width => _graphicsDevice.realWidth;
  static bool get mouseLocked => _dmlWindow.mouseIslocked;
  static bool get fullscreen => _dmlWindow.isFullscreen;
}