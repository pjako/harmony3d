part of harmony;

var _shaderHandler;
@HandlesAsset('shader')
class ShaderHandler extends AssetHandler {
  ShaderHandler() {
    _shaderHandler= this;
  }
  List<Shader> _cache = [];
  Asset _getFree() {
    if(_cache.isEmpty) {
      return new Shader();
    }
    return _cache.removeLast();
  }

  Asset create() => _getFree();

  Asset load(String src, Loader loader) {
    var shader = create();

    loader.getText(src).then((string) {
      //shader._fromJson(JSON.decode(string));
      //shader._initData = string;
      //shader._initDataLoaded();
      _renderManager._initShader(shader, JSON.decode(string)).then((_) {
      	loadingDone(shader);
      });

      //shader._callbackWhenReady = () {this.loadingDone(shader);};
    });

    return shader;
  }
  bool unload(Asset asset) {
    var shader = asset as Shader;
    _cache.add(shader);
    return true;
  }
  Future save(Asset asset, String src, var loader) {
  }
}





class Shader extends Asset {
  dml.ShaderProgram _program;
  final Map<RenderPass,dml.ShaderProgram> _passes = {};
  final Map<String,dynamic> _defaultValues = {};
  var _initData;
  var _callbackWhenReady;
  //final ShaderParameters _parameters = new ShaderParameters();
  //final List<ShaderProperty> _properties = new List<ShaderProperty>();
  //final List<Subshader> _subshaders = new List<Subshader>();

  Shader() {
    //_parameters._shader = this;
  }

  Shader.fromGLSL(String vs, String fs, RenderPass pass, String name ) {
    final vs_ = new dml.VertexShader(_graphicsDevice)
    ..source = vs;
    final fs_ = new dml.FragmentShader(_graphicsDevice)
    ..source = fs;

    final program = new dml.ShaderProgram(_graphicsDevice)
    ..vertexShader = vs_
    ..fragmentShader = fs_;
    program.link(name);
    _passes[pass] = program;
  }

  void _initDataLoaded() {
    _renderManager._shaderNeedCompile.add(this);
  }

  void _initShader() {
    Map obj = JSON.decode(_initData);
    var properties = obj['properties'];
    if(properties != null) {
      for(Map prop in properties) {
        _defaultValues[prop['varName']] = prop['defaultValue'];
      }
    }
    var subShaders = obj['subshaders'];
    if(subShaders != null) {
      for(var subShader in subShaders) {
        final vs = new dml.VertexShader(_graphicsDevice)
        ..source = subShader['vs'];
        final fs = new dml.FragmentShader(_graphicsDevice)
        ..source = subShader['fs'];
        final pass = RenderPass.parse(subShader['renderpass']);
        final program = new dml.ShaderProgram(_graphicsDevice)
        ..vertexShader = vs
        ..fragmentShader = fs;
        program.link();
        _passes[pass] = program;

      }
    }

    _callbackWhenReady();
    _initData = null;
    _callbackWhenReady = null;
  }

  void _fromJson(var json) {

  }
}