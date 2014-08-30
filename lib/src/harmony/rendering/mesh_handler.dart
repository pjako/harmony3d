part of harmony;
/// Handles loading of mesh assets
@HandlesAsset('mesh')
class MeshHandler extends AssetHandler {
  List<Mesh> _cache = [];
  Asset _getFree() {
    if(_cache.isEmpty) {
      return new Mesh();
    }
    return _cache.removeLast();
  }

  Asset create() => _getFree();

  Asset load(String src, Loader loader) {
    Mesh mesh = create();

    loader.getText(src).then((string) {
      mesh._fromJson(JSON.decode(string)).then((_) {
      	this.loadingDone(mesh);
      	//print('mesh ${mesh._name} loaded!');
      });


    });

    return mesh;
  }
  bool unload(Asset asset) {
    var mesh = asset as Mesh;
    _cache.add(asset);
    return true;
  }
  Future save(Asset asset, String src, var saveDevice) {
  }
}