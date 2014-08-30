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
/// Material defines the how the surface of an object gets shaded
/// Its basically an Shaderinstance with specific textures and uniforms.
/// Used by Mesh/Skinnedrenderer
class Material extends Asset {
	/// Store Uniform of
  final Map<String, dynamic> _uniforms = {};
  final Map<String, Texture> _textures = {};
  int renderQueue = 0;
  int passCount = 0;
  Shader _shader;

  /// Shader this Material uses
  Shader get shader => _shader;
  void set shader(Shader val) {
    _shader = val;
    //_parameters.shaderParameters = _shader._parameters;
    _renderManager._updateMaterial(this);
  }


  /// Sets a [value] for given constant [name]
  void setConstant(String name, dynamic value) {
    _uniforms[name] = value;
  }

  /// Sets a [texture] for specified [name]
  void setTexture(String name, Texture texture) {
    var oldTex = _textures[name];
    if(oldTex != null) oldTex.removeDepenency(this);
    _textures[name] = texture;
    if(texture == null) return;
    texture.dependsOnThis(true);
  }
}

/// Mangages Loading/Unloading of Materials
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
    //mat._parameters.customData = null;
    //mat._parameters.shaderParameters = null;
    mat._textures.clear();
    mat._uniforms.clear();
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