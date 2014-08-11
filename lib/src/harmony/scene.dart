part of harmony;


@HandlesAsset('scene')
class SceneHandler extends AssetHandler {
  List<Scene> _cache = [];
  Scene _getFree() {
    if(_cache.isEmpty) {
      return new Scene._empty(10000000);
    }
    return _cache.removeLast();
  }

  Asset create() => _getFree();

  Asset load(String src, Loader loader) {
    var scene = create();
    loader.getText(src).then((str) {
      _loadScene(scene, JSON.decode(str)).then((_) {
      	print('scene LOADED!');
        loadingDone(scene);
      });

    });
    return scene;
  }
  bool unload(Asset asset) {
    var scene = asset as Scene;
    _cache.add(scene);
    return true;
  }
  Future save(Asset asset, String src, Loader loader) {
  }
}

class Scene extends Asset with SceneView {


  ///
  /// The current active Scene
  ///
  static Scene get current => _current;
  static Scene _current;

  String name;
  List<Texture> _lightmaps;


  final Map<int, UniqueObject> _idMap = new Map<int, UniqueObject>();
  int _maxGameObjects;
  GameObject _root;
  GameObject get root => _root;
  //GUIDGen _guidGen;
  RenderManager _renderManager;

  void set renderManager(RenderManager manager) {
    _renderManager = manager;
  }
  RenderManager get renderManager => _renderManager;

  Scene(int this._maxGameObjects) {
    //_guidGen = new GUIDGen();
    _root = new GameObject('root');
    _registerGameObject(_root, null);
  }
  Scene._empty(int this._maxGameObjects);

  Scene.fromRoot( this._root, int this._maxGameObjects) {
    //_guidGen = new GUIDGen();
    _registerGameObject(_root, null);
  }

  // Renderpreperation and custom rendering happens here
  void _render() {
    if(Camera.current == null) return;
    _updateVisibleNodes(Camera.current);
  }

  /**
   * Registers a game object with the scene.
   * The second parameter indicates the parent of the game object.
   * Returns null unless 'initializeComponents' is set to false,
   * in wich case it returns a list of game objects that need to be initialized.
   * This mechanism is used internally calling this function recursively to
   * register children of the game object we are trying to register.
   * This ensures that components don't get initialized before all of the
   * children of their owner have been added.
   */
  Set<GameObject> _registerGameObject(GameObject go, GameObject parent,
                          [bool initializeComponents = true]) {
    if (parent != null) {
      // Can't have a parent from a different scene.
      assert(parent.scene == this);
    }

    /*if(go.id != null) {
      if (_idMap[go.id] != null) {
        throw 'Trying to register a second game object with the id "${go.id}" '
            'to this scene.';
      }

      _idMap[go.id] = go;
    }*/

    go._scene = this;
    go._parent = parent;

    if(go.name == _root) {
      return null;
    }

    if(parent != null && go != _root) {
      parent._children.add(go);
      assert(parent._children.contains(go));
    }

    // If the game object has children that need to be registred, do that
    // recursivey.
    if (go._childrenToRegister != null) {
      Set<GameObject> toInitialize = new Set.from(go._childrenToRegister);

      // First register all children recursively and collect a list of
      // game objects to initialize.
      for (var child in go._childrenToRegister) {
        toInitialize.addAll(_registerGameObject(child, go, false));
      }

      // If we are not the first call on the stack, return a list of game
      // objects that need to be initialized.
      if (!initializeComponents) {
        return toInitialize;
      } else {
        // Initialize everything at once.
        for (var child in toInitialize) {
          child._checkDependencies();
          child._initializeComponents();
        }
      }
      go._childrenToRegister.clear();
    }

    go._checkDependencies();
    go._initializeComponents();
    return null;
  }

  /// Registers a game object with the scene.
  void _reparentGameObject(GameObject go, GameObject parent) {
    assert(go != root);  // Cannot reparent root!

    assert(go.parent.children.contains(go));
    go.parent.children.remove(go);

    go._parent = parent;
    assert(!parent.children.contains(go));
    parent.children.add(go);

    //TODO: Reparenting has implications on the Transform. Do math!
  }

  /// Destroys a game object owned by this scene.
  void destroyGameObject(GameObject go) {
    // Never destroy root. That should never happen.
    assert(go != root);
    go._destroyAllComponents();

    if(go._instanceId != null) {
      _idMap.remove(go._instanceId);
      go._instanceId = null;
    }



    go._scene = null;
    _dynamicSpatialMap.remove(go);
  }


  /**
   * Returns the game object with the specified id if owned by this scene.
   */
  GameObject getGameObjectWithId(String id) {
    return _idMap[id];
  }


}