part of harmony;

abstract class ScreenDevice {
  ScreenDevice() {
  }
  
  void onResize() {
    _renderManager._onResize();
    
  }
  
  
  int get height => 0;
  int get width => 0;
  bool get mouseLocked => false;
  bool get fullscreen => true;
}