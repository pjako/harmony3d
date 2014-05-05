part of game_core;



class SceneHandler extends AssetHandler {
  List<Scene> _cache = [];
  Scene _getFree() {
    if(_cache.isEmpty) {
      return new Scene._empty(10000000);
    }
    return _cache.removeLast();
  }

  Asset create() => _getFree();

  Asset load(String src, LoaderDevice loader) {
    var scene = create();
    loader.loadFileAsString(src).then((str) {
      _loadScene(scene, JSON.decode(str)).then((_) {
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
  Future save(Asset asset, String src, LoaderDevice loader) {
  }
}


class Scene extends Asset {


  static Scene current;


  String name;


  final Map<int, UniqueObject> _idMap = new Map<int, UniqueObject>();
  int _maxGameObjects;
  GameObject _root;
  GameObject get root => _root;
  //GUIDGen _guidGen;
  RenderManager _renderManager;

  final Set<GameObject> _needsSpartialMapBoundsUpdateList = new Set<GameObject>();
  final AabbTree<GameObject> _staticSpatialMap = new AabbTree<GameObject>();
  final AabbTree<GameObject> _dynamicSpatialMap = new AabbTree<GameObject>();
  final _FrustumPlanes _frustumPlanes = new _FrustumPlanes();
  final List<Renderer> _visibleRenderers = new List<Renderer>();
  final List<Light> _visibleLight = new List<Light>();
  final List<Light> _globalDirectionalLights = new List<Light>();
  final List<GameObject> _visibleGameObjects = new List<GameObject>();
  final List<GameObject> _queryVisibleNodes = new List<GameObject>();
  final Aabb3 _tempBounds = new Aabb3();
  double _maxDistance = 0.0;

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


/*
  int _generateInstanceID(UniqueObject object) {
    while(true) {
      int newId = _guidGen.generate();
      if(!_idMap.containsKey(newId)) {
        _idMap[newId] = object;
        object._instanceId = newId;
        return newId;
      }
    }
  }
*/
  void _updateSpartialMaps() {
    for(var go in _needsSpartialMapBoundsUpdateList) {
      if(go.static) {
        _staticSpatialMap.update(go, go._internalWorldBounds);
      } else {
        _dynamicSpatialMap.update(go, go._internalWorldBounds);
      }
    }
    _needsSpartialMapBoundsUpdateList.clear();
  }

  void _updateVisibleNodes(Camera camera) {
    //Aabb3 cameraBounds = camera.getWorldBounds(_tempBounds);


    camera._getPlanes(_frustumPlanes);
    // lrtbf = no areas, lrtb = areas used
    var frustumPlanes = _frustumPlanes.lrtbf;

    int queriedVisibleNodesCount;

    double maxDistance = 0.0;
    double near0 = _frustumPlanes.near.normal.storage[0];
    double near1 = _frustumPlanes.near.normal.storage[1];
    double near2 = _frustumPlanes.near.normal.storage[2];
    double offset = _frustumPlanes.near.constant;


    _queryVisibleNodes.clear();
    _visibleGameObjects.clear();
    _visibleRenderers.clear();
    _visibleLight.clear();
    _updateSpartialMaps();



    queriedVisibleNodesCount =  _staticSpatialMap.getVisibleNodes(frustumPlanes, _queryVisibleNodes, 0);

    queriedVisibleNodesCount += _dynamicSpatialMap.getVisibleNodes(frustumPlanes, _queryVisibleNodes, queriedVisibleNodesCount);
    //return;
    for(GameObject go in _queryVisibleNodes) {
      if(go.enabled) {
        var bounds = go._internalWorldBounds;
        double distance;
        distance = ((near0 * (near0 > 0.0 ? bounds.max.storage[0] : bounds.min.storage[0])) +
                    (near1 * (near1 > 0.0 ? bounds.max.storage[1] : bounds.min.storage[1])) +
                    (near2 * (near2 > 0.0 ? bounds.max.storage[2] : bounds.min.storage[2])) - offset);

        if (0 < distance) {
          _visibleGameObjects.add(go);
          var renderer = go.renderer;
          var light = go.light;
          if(renderer != null) {
            renderer._distance = distance;
            if(renderer.enabled) {
              if (maxDistance < distance) {
                maxDistance = distance;
              }
              _visibleRenderers.add(renderer);

            }
          }
          if(light != null) {
            if(light.enabled) {
              _visibleLight.add(light);

            }
          }

        }
      }
    }
    _maxDistance = (maxDistance + camera.zFar);
    if (_maxDistance < camera.zFar) {
      this._filterVisibleNodesForCameraBox(camera);
    }

  }

  final Aabb3 _cameraBounds = new Aabb3();
  void _filterVisibleNodesForCameraBox(Camera camera) {
    Aabb3 cameraBounds;
    cameraBounds = camera.getWorldFrustumBounds(_cameraBounds, _maxDistance);
    double minX = cameraBounds.min.storage[0];
    double minY = cameraBounds.min.storage[1];
    double minZ = cameraBounds.min.storage[2];

    double maxX = cameraBounds.max.storage[0];
    double maxY = cameraBounds.max.storage[1];
    double maxZ = cameraBounds.max.storage[2];
    throw 'Not implements yet';
    /*
    _visibleRenderers.forEach((renderer) {
      Aabb3 bounds = renderer._internalWorldBounds;
      if (bounds.min.storage[0] > minX ||
          bounds.min.storage[1] > minY ||
          bounds.min.storage[2] > minZ ||
          bounds.max.storage[3] < minX ||
          bounds.max.storage[4] < minY ||
          bounds.max.storage[5] < minZ)
      {
        _visibleRenderers.remove(renderer);
      }
    });
    _visibleLight.forEach((light) {
      Aabb3 bounds = light._internalWorldBounds;
      if (bounds.min.storage[0] > minX ||
          bounds.min.storage[1] > minY ||
          bounds.min.storage[2] > minZ ||
          bounds.max.storage[3] < minX ||
          bounds.max.storage[4] < minY ||
          bounds.max.storage[5] < minZ)
      {
        _visibleLight.remove(light);
      }

    });
    */
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
          child.checkDependencies();
          child._initializeComponents();
        }
      }
      go._childrenToRegister.clear();
    }

    go.checkDependencies();
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



    // Note: People may have callbacks (free()) set up. Those will trigger here.
    // Make sure that we still have a valid Game Object when we make this call.
    go._destroyAllComponents();

    /*if(go.id != null) {
      assert(_idMap[go.id] != null);
      _idMap[go.id] = null;
    }*/
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


  final Aabb3 _sceneBounds = new Aabb3();
  void _updateBounds() {
    Aabb3 staticRootBounds = _staticSpatialMap.rootBounds;
    Aabb3 dynamicRootBounds = _staticSpatialMap.rootBounds;
    Aabb3 sceneBounds = _sceneBounds;
    if(staticRootBounds != null) {
      if(dynamicRootBounds != null) {
        double minStaticX = staticRootBounds.min.storage[0];
        double minStaticY = staticRootBounds.min.storage[1];
        double minStaticZ = staticRootBounds.min.storage[2];
        double maxStaticX = staticRootBounds.max.storage[0];
        double maxStaticY = staticRootBounds.max.storage[1];
        double maxStaticZ = staticRootBounds.max.storage[2];

        double minDynamicX = dynamicRootBounds.min.storage[0];
        double minDynamicY = dynamicRootBounds.min.storage[1];
        double minDynamicZ = dynamicRootBounds.min.storage[2];
        double maxDynamicX = dynamicRootBounds.max.storage[0];
        double maxDynamicY = dynamicRootBounds.max.storage[1];
        double maxDynamicZ = dynamicRootBounds.max.storage[2];

        _sceneBounds.min.storage[0] = (minStaticX < minDynamicX ? minStaticX : minDynamicX);
        _sceneBounds.min.storage[1] = (minStaticY < minDynamicY ? minStaticY : minDynamicY);
        _sceneBounds.min.storage[2] = (minStaticZ < minDynamicZ ? minStaticZ : minDynamicZ);
        _sceneBounds.max.storage[0] = (maxStaticX > maxDynamicX ? maxStaticX : maxDynamicX);
        _sceneBounds.max.storage[1] = (maxStaticY > maxDynamicY ? maxStaticY : maxDynamicY);
        _sceneBounds.max.storage[2] = (maxStaticZ > maxDynamicZ ? maxStaticZ : maxDynamicZ);

      } else {
        _sceneBounds.copyFrom(staticRootBounds);
      }
    } else {
      if(dynamicRootBounds != null) {
        _sceneBounds.copyFrom(dynamicRootBounds);
      } else {
        _sceneBounds.min.storage[0] = 0.0;
        _sceneBounds.min.storage[1] = 0.0;
        _sceneBounds.min.storage[2] = 0.0;
        _sceneBounds.max.storage[0] = 0.0;
        _sceneBounds.max.storage[1] = 0.0;
        _sceneBounds.max.storage[2] = 0.0;
      }
    }
  }


}