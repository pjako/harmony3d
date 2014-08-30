part of harmony;


class Physics2DMode {
  final int _i;
  const Physics2DMode(this._i);

  static const Physics2DMode xy = const Physics2DMode(0);
  static const Physics2DMode xz = const Physics2DMode(0);

}

class EngineConfig {

	/// Use SIMD in the Engine (only gives better performance if WebGL is available)
  bool useSimd = false;
  /// DMLWindow is needed for platformspecific windowmanagment (Canvas in in Browsers)
  DMLWindow dmlWindow;
  /// Initializes Harmony3D with a Project
  ProjectConfig config;
  /// Configures with Axes the 2D Physik Engine should use
  Physics2DMode physics2dMode = Physics2DMode.xy;
  /// GraphicsDevice needed to Render Objects
  dml.GraphicsDevice graphicsDevice;
  /// Physics Engine for 3D Physic
  Physics3DDevice physicsDevice3d;
  /// Physics Engine for 2D Physic
  Physics2DDevice physicsDevice2d;
  /// Audio Device for 3D Audio and Music
  audio.AudioDevice audioDevice;
  //TimeDevice timeDevice;
  //ScreenDevice screenDevice;
  //InputDevice inputDevice;
  /// Needed for reading/writing from a Filesystem
  IoDevice ioDevice;
  //LocalFileHandler localFileHandler;
  //LoaderDevice webRequestHandler;
  EngineConfig();

}
/// Configurates the Engine what
/// Assets gets loaded and which scene starts
class ProjectConfig {
  ProjectConfig();

  List<String> scenes;
  int initSceneNum;



  ProjectConfig.fromJson(String json) {

  }
}