part of game_core;

class Component extends UniqueObject {
  ComponentSystem _system;
  String get type => _system.componentName;


  bool _enabled = true;

  // Won't receive update calls if set to false.
  void set enabled(bool val) {
    if(_enabled == val) return;
    if(val == true) {
      _enabled = true;
      _start();
    }
    _enabled = false;
    _stop();
  }
  bool get enabled => _enabled;

  GameObject _owner;


  GameObject get gameObject => _owner;
  Scene get scene => _owner._scene;
  Transform get transform => _owner._transform;
  Renderer get renderer => _owner._renderer;
  AudioSource get audio => _owner._audio;
  Collider2D get collider2d => _owner._collider2d;
  Camera get camera => _owner._camera;
  Collider get collider => _owner._collider;
  Light get light => _owner._light;
  RigidBody get rigidBody => _owner._rigidBody;
  Rigidbody2D get rigidbody2d => _owner._rigidbody2d;


  void _start() {
    start();
  }
  
  void start() {
    
  }
  
  void _stop() {

  }

  void _preInit() {

  }

  void _init() {
    if(_system.useInit) {
      var t = this as dynamic;
      t.init();
    }
  }

  Component() {
  }

  void _free() {
    _enabled = true;
    removeId(this);
  }


  /**
   * Checks that all the dependencies on other components are satisfied.
   */
  bool checkDependencies() {
    var dependencies = _system.dependencies;
    for(var component in dependencies) {
      if(_owner.getComponent(component) == null) {
        throw 'Failed component dependency test. Component: ${type} requires'
            'at least component of type ${component}';
        return false;
      }
    }
    return true;
  }
}