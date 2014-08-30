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