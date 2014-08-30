part of harmony;
class MeshRenderer extends Renderer {
  final List<RenderJob> _jobs = [];

  /// Lightmap index, used to define which lightmap texture in the scene to use
  @Serialize(SerializeType.int, customName: 'lightmapIndexies')
  int _lightmapIndex;
  /// Offset and size of the light tile in the lightmap
  @Serialize(SerializeType.vec4, customName: 'lightmapTilingOffsets')
 	Vector4 _lightmapTiling;
  /// Reference to the Lightmap, this gets set when the scene loads
  Texture _lightMap;
  void _preInit() {
  	// sets the renderer of the gameobject to this
  	// TODO: should we test if there is a renderer already?
    gameObject._renderer = this;
  }

  void _init() {
  	if(_material != null && _mesh != null) {
  		_testLoad(null);
  	}
  }


  void _testLoad(_) {
    if(_isReadyToRender == true) return;
    if(_lightMap != null) {
      _isReadyToRender = _material.isLoaded && _mesh.isLoaded && _lightMap.isLoaded;
    } else {
      _isReadyToRender = _material.isLoaded && _mesh.isLoaded;
    }
    if(_isReadyToRender) {
      RenderManager._prepareRenderer(this);
      _bounds.copyFrom(_mesh._internalBounds);


    }
  }

  /// Used internaly to set the lightmap
  void _addLightmap(Texture lightMap) {
    //_parameters.lightmap = lightMap._parameters;
    _lightMap = lightMap;
    if(_lightMap.isLoaded) {
      _testLoad(null);
      return;
    }
    _lightMap.notifyOnLoad().then(_testLoad);
  }
}