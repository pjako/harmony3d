part of harmony;

class Terrain extends Component {

}


DMLWindow _dmlWindow;

// Devices
EngineConfig _config;
dml.GraphicsDevice _graphicsDevice;
Physics2DDevice _physicsDevice2d;
Physics3DDevice _physicsDevice3d;
audio.AudioDevice _audioDevice;
IoDevice _ioDevice;

_EngineManager _engineManager;
_InputManager _inputManager;
RenderManager _renderManager;
_ResourceManager _resourceManager;

// Managers
//final RenderManager _renderManager = new RenderManager();
final ComponentManager _componentManager = new ComponentManager();

bool _isInitialized = false;


/// Initializes the Harmony3D Engine with the Configuration object [config]
/// Returns a future that completes when the engine is initialized
Future initHarmony(EngineConfig config) {
  if(_isInitialized) {
    return new Future.value();
  }





  _dmlWindow = config.dmlWindow;
  _inputManager = new _InputManager._internal(_dmlWindow);
  _graphicsDevice = config.graphicsDevice;
  _physicsDevice3d = config.physicsDevice3d;
  _physicsDevice2d = config.physicsDevice2d;
  _audioDevice = config.audioDevice;
  _ioDevice = config.ioDevice;
  _renderManager = new RenderManager(_graphicsDevice);
  Scene._current = new Scene(100000);


  return _ioDevice.init().then((_) {
    _isInitialized = true;
    _resourceManager = new _ResourceManager();
    _engineManager = new _EngineManager();
  });
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
