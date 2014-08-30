part of harmony;

/// Manages all assets
class _ResourceManager {
	final Map< String, Asset> _loadedAssets = < String, Asset>{};
  final Map _localCachedAssets = {};
  Loader _resourceLoader;



  ResourceManager() {
  	final getText = _ioDevice.httpRequestTextFile;
  	final getBin = _ioDevice.httpRequestBinaryFile;
  	_resourceLoader = new Loader((src) => getText(src),(src) => getBin(src));
  }


  Asset _loadAsset(String src) {
    var asset = _loadedAssets[src];
    if(asset != null) return asset;
    var cached = _localCachedAssets[src];
    AssetHandler handler = _getAssetHandler(src);
    if(cached != null) {
      //return handler._load( src, _localFileHandler);
    	throw 'not implemented';
    }
    /*if(_webRequestHandler == null) {
      return handler._load( src, _localFileHandler);
    }*/
    return handler._load( src, _resourceLoader);
  }



	final Map< String, AssetHandler> _assetHandlers = < String, AssetHandler>{};

	AssetHandler _findAssetHandlerClass(String ext) {
		for(var clazz in mist.getAllSubclassesInfoOf(AssetHandler)) {
			//print('Handler: ${clazz.name} metaCount: ${clazz.metadataCount}');
			for(int i=clazz.metadataCount-1;i>=0;i--) {
				final meta = clazz.getMetaData(i);
				if(meta is HandlesAsset) {
					if(meta.handledAsset == ext) {
						return clazz.newInstance([]);
					}
				}
			}
		}
		return null;
	}


	AssetHandler _getAssetHandler(String src) {
	  String ext = src.substring(src.lastIndexOf('.')+1);
	  var handler = _assetHandlers[ext];
	  if(handler == null) {
	  	final cl = _findAssetHandlerClass(ext);
	  	if(cl == null) throw 'unhandled asset type: $ext';
	    if(cl is! AssetHandler) throw 'Handler $handler should be subtype of AssetHandler';
	    _registerAssetHandler(cl, ext);
	    return _getAssetHandler(src);
	  }
	  return handler;
	}

	void _registerAssetHandler(AssetHandler assetHandler, String fileExtension) {
    _assetHandlers[fileExtension] = assetHandler;
  }

}