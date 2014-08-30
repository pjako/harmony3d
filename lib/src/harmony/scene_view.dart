part of harmony;

/// SceneView
/// Contains all logic for calculating visible components and gameobjects towards a camera.
class SceneView {
  final Set<GameObject> _needsSpartialMapBoundsUpdateList = new Set<GameObject>();
  /// contains all static object in the Scene
  final AabbTree<GameObject> _staticSpatialMap = new AabbTree<GameObject>();
  /// Contains all dynamic of the Scene
  final AabbTree<GameObject> _dynamicSpatialMap = new AabbTree<GameObject>();
  final _FrustumPlanes _frustumPlanes = new _FrustumPlanes();
  final List<Renderer> _visibleRenderers = new List<Renderer>();
  /// Contains all visible light to the current sceneview
  final List<Light> _visibleLights = new List<Light>();
  final List<Light> _globalDirectionalLights = new List<Light>();
  final List<GameObject> _visibleGameObjects = new List<GameObject>();
  final List<GameObject> _queryVisibleNodes = new List<GameObject>();
  final Aabb3 _viewBounds = new Aabb3();
  final Aabb3 _tempBounds = new Aabb3();
  double _maxDistance = 0.0;


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
    _visibleLights.clear();
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
              _visibleLights.add(light);

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

  void _updateViewBounds() {
    Aabb3 staticRootBounds = _staticSpatialMap.rootBounds;
    Aabb3 dynamicRootBounds = _staticSpatialMap.rootBounds;
    Aabb3 sceneBounds = _viewBounds;
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

        _viewBounds.min.storage[0] = (minStaticX < minDynamicX ? minStaticX : minDynamicX);
        _viewBounds.min.storage[1] = (minStaticY < minDynamicY ? minStaticY : minDynamicY);
        _viewBounds.min.storage[2] = (minStaticZ < minDynamicZ ? minStaticZ : minDynamicZ);
        _viewBounds.max.storage[0] = (maxStaticX > maxDynamicX ? maxStaticX : maxDynamicX);
        _viewBounds.max.storage[1] = (maxStaticY > maxDynamicY ? maxStaticY : maxDynamicY);
        _viewBounds.max.storage[2] = (maxStaticZ > maxDynamicZ ? maxStaticZ : maxDynamicZ);

      } else {
        _viewBounds.copyFrom(staticRootBounds);
      }
    } else {
      if(dynamicRootBounds != null) {
        _viewBounds.copyFrom(dynamicRootBounds);
      } else {
        _viewBounds.min.storage[0] = 0.0;
        _viewBounds.min.storage[1] = 0.0;
        _viewBounds.min.storage[2] = 0.0;
        _viewBounds.max.storage[0] = 0.0;
        _viewBounds.max.storage[1] = 0.0;
        _viewBounds.max.storage[2] = 0.0;
      }
    }
  }


}