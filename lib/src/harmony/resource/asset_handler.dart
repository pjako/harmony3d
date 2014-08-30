part of harmony;

/// Is needed to mark an AssetHandler which asset type it handles via metadata
class HandlesAsset {
	/// Specifiy asset type by extension f.e. 'mp3' 'mesh' 'ogg'
  final String handledAsset;
  const HandlesAsset(this.handledAsset);
}

/// AssetHandler handles the lifetime of specific AssetType
/// Assethandler have to be marked with metadata which Assettype they handle
/// This is done by specifing a extension.
/// For example:
/// @HandlesAsset('wav') @HandlesAsset('mp3') @HandlesAsset('acc')
/// MyAudioHandler extends AssetHandler { }
@mist.MistReflect(includeSubclasses: true)
class AssetHandler {

	/// Creates specified Asset
  Asset create() {
  }
  /// Loads Asset, depenending on the loader from local or a webserver
  Asset load(String src, Loader loader) {

  }

  /// Stores [asset] locally at path [src] with [saveDevice]
  Future<Asset> store(Asset asset, String src, var saveDevice) {

  }

  /// Unloads [asset] gets called by _unload
  bool unload(Asset asset) {}
  bool _unload(Asset asset, bool ignoreDependencies) {
    if(ignoreDependencies == false) {
      if(asset._dependentList.length > 0) return false;
    }
    if(unload(asset) == false) return false;
    asset._assetId = null;
    asset._dependentList.clear();
    asset._isLoaded = false;
    return true;
  }

  Asset _load(String src, Loader loader) {
    var asset = load(src,loader);
    asset._assetHandler = this;
    asset._assetId = src;
    return asset;
  }

  /// If the [asset] is fully loaded, this has to be called
  void loadingDone(Asset asset) {
    asset._loadingDone();
  }

}