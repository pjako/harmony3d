part of harmony;


class Physics2DMode {
  final int _i;
  const Physics2DMode(this._i);

  static const Physics2DMode xy = const Physics2DMode(0);
  static const Physics2DMode xz = const Physics2DMode(0);

}

class EngineConfig {
  bool useSimd = false;
  DMLWindow dmlWindow;
  ProjectConfig config;
  Physics2DMode physics2dMode = Physics2DMode.xy;
  dml.GraphicsDevice graphicsDevice;
  Physics3DDevice physicsDevice3d;
  Physics2DDevice physicsDevice2d;
  audio.AudioDevice audioDevice;
  TimeDevice timeDevice;
  ScreenDevice screenDevice;
  InputDevice inputDevice;
  IoDevice ioDevice;
  //LocalFileHandler localFileHandler;
  //LoaderDevice webRequestHandler;
  EngineConfig();

}


class ProjectConfig {
  ProjectConfig();

  List<String> scenes;
  int initSceneNum;



  ProjectConfig.fromJson(String json) {

  }
}