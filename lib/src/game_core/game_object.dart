part of game_core;



class GameObject extends UniqueObject with AabbTreeNode {
  String _tag;
  String get tag => _tag;

  /// Defines which mode we in, physics 2D or 3D
  bool _physics3dMode = false;

  bool enabled = true;
  bool static = false;

  int _layer;
  static final Aabb3 _bounds = new Aabb3();
  static final Aabb3 _worldBounds = new Aabb3();
  // _scene._dynamicSpatialMap.update(this, bounds);

  void set layer(int l) {
    _layer = l;
  }
  int get layer => _layer;

  void set tag(String newTag) {
    //_scene.
  }

  Scene _scene;
  Scene get scene => _scene;
  GameObject _parent;
  GameObject get parent => _parent;
  Set<GameObject> _children;
  Set<GameObject> get children => _children;
  List<Component> _components;
  //List<Component> get components => _components;

  final List<Component> _componentsToInitialize = [];
  Set<GameObject> _childrenToRegister;


  String name;
  Transform get transform => _transform;
  Transform _transform;
  Camera get camera => _camera;
  Camera _camera;
  Collider2D _collider2d;
  Collider2D get collider2d => _collider2d;
  Collider _collider;
  Collider get collider => _collider;
  Renderer get renderer => _renderer;
  Renderer _renderer;
  AudioSource get audio => _audio;
  AudioSource _audio;
  Light get light => _light;
  Light _light;
  RigidBody _rigidBody;
  RigidBody get rigidBody => _rigidBody;
  Rigidbody2D _rigidbody2d;
  Rigidbody2D get rigidbody2d => _rigidbody2d;

  GameObject([this.name]) {
    _parent = null;
    _children = new Set<GameObject>();
    _childrenToRegister = new Set<GameObject>();
    //_data = new PropertyMap();
    _components = new List<Component>();
    addComponent('Transform');
    //_events = new EventListenerMap(this);
  }
  GameObject._transformless(this.name) {
    _parent = null;
    _children = new Set<GameObject>();
    _childrenToRegister = new Set<GameObject>();
    //_data = new PropertyMap();
    _components = new List<Component>();
    //_events = new EventListenerMap(this);
  }


  void updateBounds() {
    _doBoundsUpdate();
  }
  void _doBoundsUpdate() {
    _boundsNeedUpdate = true;
    _scene._needsSpartialMapBoundsUpdateList.add(this);
  }
  bool _boundsNeedUpdate = true;
  Aabb3 get _internalWorldBounds {
    
    if(!_boundsNeedUpdate) return _worldBounds;
    _boundsNeedUpdate = false;
    if(_renderer != null) {
      //transform.transformBounds(_renderer._internalBounds, _worldBounds);
      if(_renderer is SkinnedMeshRenderer) {
        transform.transformBounds(_renderer._internalBounds, _worldBounds);
        
      } else {
        // internal bounds currently are absolute when exporting from unity3d...
        _worldBounds.copyFrom(_renderer._internalBounds);
      }
      
    } else if(_light != null) {
      transform.transformBounds(_light._internalBounds, _worldBounds);
    } else if(_collider != null) {
      transform.transformBounds(_collider._internalBounds, _worldBounds);
    } else {
      transform.transformBounds(_bounds, _worldBounds);
    }
    return _worldBounds;




  }


  //final Aabb3 _bounds = new Aabb3();
  void _updateBounds() {
    /* Which bound to use, the hirachy is, depending if it exist:
     * 1. Renderer
     * 2. Light
     * 3. Collider
     * 4. base bounds = 0.0
     */
    if(_renderer != null) {


    } else if(_light != null) {

    } else if(_collider != null) {

    } else {
      _bounds.min.storage[0] = 0.0;
      _bounds.min.storage[1] = 0.0;
      _bounds.min.storage[2] = 0.0;
      _bounds.max.storage[0] = 0.0;
      _bounds.max.storage[1] = 0.0;
      _bounds.max.storage[2] = 0.0;
    }


  }

  /**
   * Returns the first component of the specified type.
   * Interfaces and base clases may be used, unless exactType is true.
   */
  Component getComponent(String type, [bool exactType = false]) {
    for(var component in _components) {
      // TODO: Replace by an actual type check.
      if(component.type == type) {
        return component;
      }
    }
    return null;
  }

  /**
   * Returns all the components of the specified type.
   * Interfaces and base clases may be used, unless exactType is true.
   */
   List<Component> getComponents(String type) {
    var list = [];
    for(var component in _components) {
      // TODO: Replace by an actual type check.
      if(component.type == type) {
        list.add(component);
      }
    }
    return list;
  }

   /**
    * Returns a list of all the components attached to this game object.
    */
  List<Component> getAllComponents() {
    return new List.from(_components);
  }
  /**
   * Adds a component of the given type to this game object.
   */
  Component addComponent(String type) {
    var component = _componentManager.createComponent(type);
    component._owner = this;
    _components.add(component);
    component._preInit();
    // 2 cases, maybe we are already registered in the scene, in which case we
    // can initialize the component right away. Otherwise, lets wait for the
    // scene to notify us that we are added.
    if(scene != null) {
      component._init();
      component.checkDependencies();
      return component;
    } else {
      _componentsToInitialize.add(component);
      return component;
    }
  }
  /**
   * Destroys a component attached to this game object.
   * This component cannot be used on other game objects.
   * References to the destroyed component are now invalid and they will not
   * be set to null because the Component is part of an object pool.
   * */
  void destroyComponent(Component component) {
    if(!_components.contains(component)) {
      throw 'Trying to remove a component (${component.runtimeType}) from a '
          'game object that does not own it.';
    }

    component._free();
    component._owner = null;
    component.enabled = false;
    _components.remove(component);
    if(component._instanceId != null) {
      _scene._idMap.remove(component._instanceId);
      component._instanceId = null;
    }
    _componentManager.destroyComponent(component);
    checkDependencies();
  }

  /**
   * Adds a new child to this game object.
   * Reparenting and scene registration are managed automatically.
   * Returns the game object that was added (for chaining purpuses).
   */
  GameObject addChild(GameObject go) {
    if (go.scene != null) {
      // Make sure we are not adding game object from a different scene.
      assert(go.scene == scene);
    }

    // Already added.
    if (_children.contains(go) || _childrenToRegister.contains(go)) {
      return go;
    }

    if (scene == null ) {
      // We are not registred yet.
      if (_childrenToRegister == null) {
        _childrenToRegister = new Set();
      }
      if (!_childrenToRegister.contains(go)) {
        _childrenToRegister.add(go);
      }
    } else {
      if (go.parent != null) {
        scene._reparentGameObject(go, this);
      } else {
        scene._registerGameObject(go, this);
      }
    }
    return go;
  }

  /**
   * Checks that all the components' dependencies on other components
   * are satisfied.
   */
  bool checkDependencies() {
    for(var component in _components) {
      if(!component.checkDependencies()) return false;
    }
    return true;
  }

  /**
   * If there are components added but not yet initialized, this will initialize
   * them. Called by the scene when a game object is registered with it.
   * Do not manually call this.
   */
  void _initializeComponents() {
    if(_componentsToInitialize != null){
      for(var component in _componentsToInitialize) {
        component._init();
      }
    }
    _bounds.min.setZero();
    _bounds.max.setZero();
    if(static) {
      _scene._staticSpatialMap.add(this, _internalWorldBounds);
    } else {
      _scene._dynamicSpatialMap.add(this, _internalWorldBounds);
    }

  }

  /// Do not manually call this. Call Scene.destroyGameObject instead.
  void _destroyAllComponents() {
    // Destroy every component we have.
    while (_components.length > 0) {
      destroyComponent(_components[0]);
    }
    _componentsToInitialize.clear();
  }

  void destroy() {
    if(_scene != null) {
      _scene.destroyGameObject(this);
    }
    if(parent != null) {
      _parent._children.remove(this);
      _parent = null;
    }
    //Destroy it's children, recursively
    while(children.length > 0) children.first.destroy();

    _destroyAllComponents();
    removeId(this);

  }

  void drawBounds() {
    var bounds = _internalWorldBounds;
    Debug.drawAABB(bounds.min, bounds.max, Debug._debugColor, depthEnabled: false);
  }

  /**
   * Serialize.
   */
  String toJson() {
    //return SceneDescriptor.serializeGameObject(this);
  }

}




