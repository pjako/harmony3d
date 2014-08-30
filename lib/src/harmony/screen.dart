part of harmony;

class Screen {
	/// Height of the canvas
  static int get height => _graphicsDevice.realHeight;
  /// Width of the canvas
  static int get width => _graphicsDevice.realWidth;
  /// Is mouse locked?
  static bool get mouseLocked => _dmlWindow.mouseIslocked;
  /// Is the canvas fullscreen?
  static bool get fullscreen => _dmlWindow.isFullscreen;
}