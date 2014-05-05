part of game_engine;


//TODO: Future Work, port Scene internals to use this for culling.
class SceneView {
  final _FrustumPlanes _frustumPlanes = new _FrustumPlanes();
  final List<Renderer> _visibleRenderers = new List<Renderer>();
  final List<Light> _visibleLight = new List<Light>();
  final List<Light> _globalDirectionalLights = new List<Light>();
  final List<GameObject> _visibleGameObjects = new List<GameObject>();
  final List<GameObject> _queryVisibleNodes = new List<GameObject>();



  void updateVisibleNodes(Scene scene, Camera camera) {
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



    queriedVisibleNodesCount =  scene._staticSpatialMap.getVisibleNodes(frustumPlanes, _queryVisibleNodes, 0);
    queriedVisibleNodesCount += scene._dynamicSpatialMap.getVisibleNodes(frustumPlanes, _queryVisibleNodes, queriedVisibleNodesCount);
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

}