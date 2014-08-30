part of harmony;




/// Digests all Input Events
class _InputManager {
  _InputManager._internal(DMLWindow dmlWindow) {
    dmlWindow.onGamepadAxis = _onGamepadAxis;
    dmlWindow.onGamepadButton = _onGamepadButton;
    dmlWindow.onGamepadConnect = _onGamepadConnect;
    dmlWindow.onGamepadDisconnect = _onGamepadDisconnect;
    dmlWindow.onKeyboardEvent = _onKeyboardEvent;
    dmlWindow.onMouseButton = _onMouseButton;
    dmlWindow.onMouseMove = _onMouseMove;
    dmlWindow.onMouseLockChange = _onMouseLockChange;
    dmlWindow.onMouseWheel = _onMouseWheel;
    dmlWindow.onTouchEvent = _onTouchEvent;
  }



  final List<bool> mouseButtons = new List<bool>.filled(3, false);
  int mouseDeltaX = 0;
  int mouseDeltaY = 0;
  int mouseClampX = 0;
  int mouseClampY = 0;
  int mouseX = 0;
  int mouseY = 0;
  bool withinCanvas;
  int mouseWheelDeltaX = 0;
  int mouseWheelDeltaY = 0;

  bool isButtonPressed(int buttinId) {
    final key = _keyStates[buttinId];
    if(key == null) return false;
    return key;
  }


  Map<int,DMLKeyboardEvent> _keyStates = {};

  bool isKeyPressed(int keyId) {
    final key = _keyStates[keyId];
    if(key == null) return false;
    return key.down;
  }

  GamePad getGamePad(int idx) {
    return _gamepads[idx];
  }
  List<GamePad> _gamepads = new List(20);


  void _onTouchEvent(DMLTouchEvent event) {
    //event.

  }
  void _onKeyboardEvent(DMLKeyboardEvent event) {
    _keyStates[event.buttonId] = event;

  }
  void _onMouseMove(DMLMouseMoveEvent event) {
    mouseDeltaX = event.dx;
    mouseDeltaY = event.dy;
    mouseClampX = event.clampX;
    mouseClampY = event.clampY;
    mouseX = event.x;
    mouseY = event.y;
    withinCanvas = event.withinCanvas;

  }
  void _onMouseWheel(DMLMouseWheelEvent event) {
    mouseWheelDeltaX = event.dx;
    mouseWheelDeltaY = event.dy;
  }
  void _onMouseButton(DMLMouseButtonEvent event) {
    if(event.buttonId > 2) return;
    mouseButtons[event.buttonId] = event.down;

  }
  void _onMouseLockChange(DMLWindow window) {

  }




  void _onGamepadAxis(DMLGamepadAxisEvent event) {
    _gamepads[event.gamepadIndex]._axes[event.axis] = event.value;
  }
  void _onGamepadButton(DMLGamepadButtonEvent event) {
    _gamepads[event.gamepadIndex]._buttons[event.button] = event.value;

  }
  void _onGamepadConnect(DMLGamepadConnectEvent event ) {
    _gamepads[event.gamepadIndex] = new GamePad();
  }
  void _onGamepadDisconnect(DMLGamepadDisconnectEvent event) {
    _gamepads[event.gamepadIndex] = null;
  }

}