part of harmony;

class CustomMaterial extends Material {
  bool get isLoaded => true;
}


class _SubMaterial {
  dml.ShaderProgram program;
  final Map<String, dynamic> _uniform = {};
  final Map<String, Texture> _textures = {};

  void reset() {
    program = null;
    _uniform.clear();
    _textures.clear();
  }
}

class Material extends Asset {
  final Map<String, dynamic> _uniforms = {};
  final Map<String, Texture> _textures = {};
  int renderQueue = 0;
  int passCount = 0;
  Shader _shader;
  Shader get shader => _shader;
  void set shader(Shader val) {
    _shader = val;
    //_parameters.shaderParameters = _shader._parameters;
    _renderManager._updateMaterial(this);
  }


  void setConstant(String name, dynamic value) {
    _uniforms[name] = value;
  }

  void setTexture(String name, Texture texture) {
    var oldTex = _textures[name];
    if(oldTex != null) oldTex.removeDepenency(this);
    _textures[name] = texture;
    if(texture == null) return;
    texture.dependsOnThis(true);
  }
}


@HandlesAsset('mat')
class MaterialHandler extends AssetHandler {
  List<Material> _cache = [];
  Material _getFree() {
    if(_cache.isEmpty) {
      return new Material();
    }
    return _cache.removeLast();
  }

  Asset create() => _getFree();

  Asset load(String src, Loader loader) {
    var mat = _getFree();

    loader.getText(src).then((str) {
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
          //mat._parameters.textures[key] = tex._parameters;
          tex.dependsOnThis(this);
          mat._textures[key] = tex;
        });
      }

      if(uniforms != null) {
        uniforms.forEach((String key, dynamic data) {
          if(data is List) {
            mat._uniforms[key] = new Float32List.fromList(data);
            return;
          }
          if(data is num) {
            mat._uniforms[key] = data;
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
          //print('mat loaded! ${mat.assetId}');
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
  Future save(Asset asset, String src, var saveDevice) {
  }
}