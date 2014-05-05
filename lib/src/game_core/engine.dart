part of game_core;




// Devices
EngineConfig _config;
RenderDevice _renderDevice;
//PhysicsDevice _physicsDevice;
Physics2DDevice _physicsDevice2d;
Physics3DDevice _physicsDevice3d;
AudioDevice _audioDevice;
TimeDevice _timeDevice;
ScreenDevice _screenDevice;
InputDevice _inputDevice;

// Managers
final RenderManager _renderManager = new RenderManager();
final ComponentManager _componentManager = new ComponentManager();



class Engine {
  static bool _isInitialized = false;

  static void start() {
    _timeDevice.start();
  }

  static void pause() {
    _timeDevice.stop();
  }


  static void _update() {
    if(_physicsDevice2d != null) {
      _physicsDevice2d.step(Time.deltaTime);
    }
    //_physicsDevice2d.step(Time.deltaTime);
    //_debugDraw.update(dt);
    //_physicsManager.update(dt);
    _renderDevice.update(Time.deltaTime);
    _componentManager.updateComponents();

  }

  static void _render() {
    _componentManager.lateUpdateComponents();
    if(Scene.current == null) return;
    if(Camera.current == null) return;
    if(_physicsDevice2d != null) {
      _physicsDevice2d.debugDraw();
    }
    Scene.current._render();
    _renderManager._render(Scene.current);
  }

  static Future initEngine({
    EngineConfig config,
    RenderDevice renderDevice,
    Physics3DDevice physicsDevice3d,
    Physics2DDevice physicsDevice2d,
    AudioDevice audioDevice,
    TimeDevice timeDevice,
    ScreenDevice screenDevice,
    InputDevice inputDevice,
    LocalFileHandler localFileHandler,
    LoaderDevice webRequestHandler} ) {

    if(_isInitialized) return new Future.value(null);
    print('Initialize harmony3d...');
    _config = config;
    if(_config == null) {
      _config = new EngineConfig();
    }

    _renderDevice = renderDevice;
    _physicsDevice3d = physicsDevice3d;
    _physicsDevice2d = physicsDevice2d;
    _screenDevice = screenDevice;
    _inputDevice = inputDevice;
    _audioDevice = audioDevice;
    _timeDevice = timeDevice;
    if(physicsDevice2d != null) {
      //physicsDevice2d.setDebugDrawer(new HarmonyDebugDrawDevice());
    }

    return initializeRessourceManagment(localFileHandler, webRequestHandler).then(_asyncInit);

  }
  static _asyncInit(_) {
    if(_isInitialized == true) return null;
    _isInitialized = true;

    _timeDevice.render = Engine._render;
    _timeDevice.update = Engine._update;
    return null;
  }

  Engine._();
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
