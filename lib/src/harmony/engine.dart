part of harmony;

class Terrain extends Component {

}


DMLWindow _dmlWindow;

// Devices
EngineConfig _config;
//RenderDevice _renderDevice;
dml.GraphicsDevice _graphicsDevice;

//PhysicsDevice _physicsDevice;
Physics2DDevice _physicsDevice2d;
Physics3DDevice _physicsDevice3d;
audio.AudioDevice _audioDevice;
TimeDevice _timeDevice;
ScreenDevice _screenDevice;
InputDevice _inputDevice;
IoDevice _ioDevice;

_EngineManager _engineManager;
InputManager _inputManager;
RenderManager _renderManager;
ResourceManager _resourceManager;

// Managers
//final RenderManager _renderManager = new RenderManager();
final ComponentManager _componentManager = new ComponentManager();

bool _isInitialized = false;
Future initHarmony(EngineConfig config) {
  //Completer<bool> completer = new Completer<bool>();
  if(_isInitialized) {
    //completer.complete(true);
    return new Future.value();
  }





  _dmlWindow = config.dmlWindow;
  _inputManager = new InputManager._internal(_dmlWindow);
  _graphicsDevice = config.graphicsDevice;
  _physicsDevice3d = config.physicsDevice3d;
  _physicsDevice2d = config.physicsDevice2d;
  _screenDevice = config.screenDevice;
  _inputDevice = config.inputDevice;
  _audioDevice = config.audioDevice;
  _timeDevice = config.timeDevice;
  _ioDevice = config.ioDevice;
  _renderManager = new RenderManager(_graphicsDevice);
  Scene._current = new Scene(100000);


  return _ioDevice.init().then((_) {
    _isInitialized = true;
    _resourceManager = new ResourceManager();
    _engineManager = new _EngineManager();
    //completer.complete(true);
  });

  /*initializeRessourceManagment(config.localFileHandler, config.webRequestHandler).then((_) {

  });
  return completer.future;*/
}



class HarmonyDebugDrawDevice implements DebugDrawDevice {
  void drawLine(Vector3 start, Vector3 end, Vector4 color) {
    Debug.drawLine(start, end, color, depthEnabled: false);
  }
  void drawPoint(Vector3 start, Vector4 color) {
    Debug.drawCross(start, color, depthEnabled: false);
  }
  void drawCircle(Vector3 point, double radius, Vector4 color) {
    Debug.drawCircle(point, new Vector3(0.0,1.0,0.0), radius, color, depthEnabled: false);
  }
}
