part of game_core;

class CustomMaterial extends Material {
  bool get isLoaded => true;
}

class Material extends Asset {
  final MaterialParameters _parameters = new MaterialParameters();
  final Map<String, Texture> _textures = {};
  int renderQueue = 0;
  int passCount = 0;
  Shader _shader;
  Shader get shader => _shader;
  void set shader(Shader val) {
    _shader = val;
    _parameters.shaderParameters = _shader._parameters;
    _renderManager._updateMaterial(this);
  }


  void setConstant(String name, dynamic value) {
    _parameters.uniforms[name] = value;
  }

  void setTexture(String name, Texture texture) {
    var oldTex = _textures[name];
    if(oldTex != null) oldTex.removeDepenency(this);
    _textures[name] = texture;
    if(texture == null) return;
    if(texture.isLoaded) {
      _parameters.textures[name] = texture._parameters;
    } else {
      _parameters.textures[name] = null;
      texture.notifyOnLoad().then((v) {
        if(_parameters.textures[name] != null) return;
        _parameters.textures[name] = texture._parameters;
      });
    }

    texture.dependsOnThis(true);
  }
}



class MaterialHandler extends AssetHandler {
  List<Material> _cache = [];
  Material _getFree() {
    if(_cache.isEmpty) {
      return new Material();
    }
    return _cache.removeLast();
  }

  Asset create() => _getFree();

  Asset load(String src, LoaderDevice loader) {
    var mat = _getFree();

    loader.loadFileAsString(src).then((str) {
      var map = JSON.decode(str);
      mat._shader = Resources.load(map['shader']);
      mat._shader.dependsOnThis(this);
      List waitForList = [];
      Map<String,String> textures = map['textures'];
      Map<String,dynamic> uniforms = map['uniforms'];

      if(textures != null) {
        textures.forEach((String key, String textureUrls) {
          Texture tex = Resources.load(textureUrls) as Texture;

          waitForList.add(tex.notifyOnLoad());
          mat._parameters.textures[key] = tex._parameters;
          tex.dependsOnThis(this);
          mat._textures[key] = tex._parameters;
        });
      }

      if(uniforms != null) {
        uniforms.forEach((String key, dynamic data) {
          if(data is List) {
            mat._parameters.uniforms[key] = new Float32List.fromList(data);
            return;
          }
          if(data is num) {
            mat._parameters.uniforms[key] = data;
            return;
          }
        });
      }
      if(!mat._shader.isLoaded) {
        waitForList.add(mat._shader.notifyOnLoad());
      }

      if(waitForList.isEmpty) {
        loadingDone(mat);
      } else {
        Future.wait(waitForList).then((val) {
          loadingDone(mat);
        });
      }

    });

    return mat;
  }
  bool unload(Asset asset) {
    var mat = asset as Material;
    mat._shader.removeDepenency(this);
    mat._shader = null;
    mat._parameters.customData = null;
    mat._parameters.shaderParameters = null;
    mat._parameters.textures.clear();
    mat._parameters.uniforms.clear();
    for(var tex in mat._textures) {
      tex.removeDepenency(this);
    }
    mat._textures.clear();
    _cache.add(mat);
    return true;
  }
  Future save(Asset asset, String src, LocalFileHandler saveDevice) {
  }
}