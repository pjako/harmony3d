part of harmony;
/// Component
///
/// The baseclass to all components
///
/// Default Messages:
/// void update()
/// void fixUpdated()
/// void lateUpdate()
///
@mist.MistReflect(includeSubclasses: true)
class Component extends UniqueObject {
  @mist.Ignore()
  ComponentSystem _system;
  final List<Asset> _componentAssets = [];
  //String get type => _system.componentName;


  /// Calls Resources.load() with [src] and returns the requested asset.
  /// Automatically adds a dependency for this Object on the returned asset.
  /// Deletes the dependency when component gets destroyed
  Asset loadResource(String src) {
    var asset = Resources.load(src);
    asset.dependsOnThis(this);
    _componentAssets.add(asset);
    return asset;
  }

  /// Calls Resources.load() with [src] and returns a future
  /// Automatically adds a dependency for this Object on the returned asset.
  /// Deletes the dependency when component gets destroyed
  Future<Asset> loadResourceAsync(String src) {
    var asset = Resources.load(src);
    asset.dependsOnThis(this);
    _componentAssets.add(asset);
    return asset.notifyOnLoad();
  }

  bool _enabled = true;

  // Won't receive update calls if set to false.
  void set enabled(bool val) {
    if(_enabled == val) return;
    if(val == true) {
      _enabled = true;
      _start();
    }
    _enabled = false;
  }

  // Is this component enabled?
  bool get enabled => _enabled;

  GameObject _owner;
  /// gameObject that owns this component
  GameObject get gameObject => _owner;
  /// scene this component is a port of
  Scene get scene => _owner._scene;
  /// Transform component
  Transform get transform => _owner._transform;
  /// Renderer component
  Renderer get renderer => _owner._renderer;
  /// AudioSource component
  AudioSource get audio => _owner._audio;
  /// Collider2D component
  Collider2D get collider2d => _owner._collider2d;
  /// Camera component
  Camera get camera => _owner._camera;
  /// Collider component
  Collider get collider => _owner._collider;
  /// Light component
  Light get light => _owner._light;
  /// RigidBody Component
  RigidBody get rigidBody => _owner._rigidBody;
  /// RigidBody2D Component
  Rigidbody2D get rigidbody2d => _owner._rigidbody2d;


  void _start() {
    start();
  }
  /// gets fired when component is enabled
  void start() {

  }

  /// gets called when this component is enabled
  void awake() {

  }

  void _preInit() {

  }


  void _init() {
    if(this.gameObject.scene != null) {
      if(_enabled == true  && gameObject.enabled == true) {
        _system._addLiveComponent(this);
      }
    }

    /// only fire init if its defined in specific component
    if(_system.hasInit) {
      var t = this as dynamic;
      t.init();
    }
  }

  Component() {
  }

  /// destroys this component, every non engine pointer to this component must be removed
  void destroy() {
    if(_owner == null) {
      print('[Warning] Component has already been destroyed!');
      return;
    }
    _owner.destroyComponent(this);
  }


  /// gets called when this component gets destroyed
  void onDestroy() {

  }


  /// checks all dependencies of the component
  /// dependencies are always other components attached to the component
  bool _checkDependencies() {
    var dependencies = _system._dependencies;
    for(var component in dependencies) {
      if(_owner.getComponent(component) == null) {
        throw 'Failed component dependency test. Component: ${_system.componentName} requires'
            'at least component of type ${component}';
        return false;
      }
    }
    return true;
  }
}