part of game_core;

var _shaderHandler;

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

  Asset load(String src, LoaderDevice loader) {
    var mesh = create();

    loader.loadFileAsString(src).then((string) {
      mesh._fromJson(JSON.decode(string));

      this.loadingDone(mesh);
    });

    return mesh;
  }
  bool unload(Asset asset) {
    var shader = asset as Shader;
    _cache.add(shader);
    return true;
  }
  Future save(Asset asset, String src, LoaderDevice loader) {
  }
}

class Shader extends Asset {
  final ShaderParameters _parameters = new ShaderParameters();
  final List<ShaderProperty> _properties = new List<ShaderProperty>();
  final List<Subshader> _subshaders = new List<Subshader>();

  Shader() {
    //_parameters._shader = this;
  }

  Shader.fromGLSL(String vs, String fs, RenderPass pass, String name ) {
    _subshaders.add(new Subshader()
    ..pass = pass
    ..vertexSource = vs
    ..fragmentSource = fs
    ..name = name);
    _shaderHandler.loadingDone(this);
  }

  /// Compiles the shader, its optinal and done for shader testing
  void compile() {
    for(var ss in _subshaders) {
      _renderDevice.compileShader(ss);
    }
  }

  //String _assetId;
  Map _shaderData;

  void _init(RenderManager manager) {
    //if(_link != null) return;
    //manager.registerShader(this);
  }
  void _fromJson(Map obj) {
    var properties = obj['properties'];
    if(properties != null) {
      for(Map prop in properties) {
        _properties.add(new ShaderProperty(
            prop['tagName'],
            prop['varName'],
            prop['type'],
            prop['defaultValue'])
        );
      }
    }
    var subShaders = obj['subshaders'];
    if(subShaders != null) {
      for(var subShader in subShaders) {
        _subshaders.add(new Subshader()
        ..pass = RenderPass.parse(subShader['renderpass'])
        ..vertexSource = subShader['vs']
        ..fragmentSource = subShader['fs']);
      }
    }
  }
}