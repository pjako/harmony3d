part of harmony;


/// Asset is a container class for Assettypes in harmony3D
/// Ranges from Shaders, Meshes to Audiodata
class Asset {
  AssetHandler _assetHandler;
  String _assetId;
  /// Unique AssetID, currently this is the relativ path to the asset
  String get assetId => _assetId;
  final Set<dynamic> _dependentList = new Set<dynamic>();

  /// If certain object depends on this. (important for asset managment)
  void dependsOnThis(dynamic requireThis) {
    _dependentList.add(requireThis);
  }
  /// Removes dependency on to this object
  void removeDepenency(dynamic notRequireThis) {
    _dependentList.remove(notRequireThis);
  }


  bool _isLoaded = false;
  /// is tha asset fully loaded?
  bool get isLoaded => _isLoaded;
  final List<Completer<Asset>> _notifyList = new List<Completer<Asset>>();

  void _loadingDone() {
    _isLoaded = true;
    _notifyList.forEach((var comp) {
      comp.complete(this);
    });
    _notifyList.clear();
  }

  /// Returns a future that completes when the asset is fully loaded
  Future<Asset> notifyOnLoad() {
    if(_isLoaded == true) {
      return new Future.value(this);
    }
    var comp = new Completer<Asset>();
    _notifyList.add(comp);
    return comp.future;
  }
}