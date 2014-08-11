part of harmony;


class HandlesAsset {
  final String handledAsset;
  const HandlesAsset(this.handledAsset);
}


typedef Future<String> GetText(String src);
typedef Future<ByteBuffer> GetBinary(String src);

class Loader {
	final GetText _getText;
	final GetBinary _getBin;

	Loader(this._getText,this._getBin);




	Future<String> getText(String src) {
		return _getText(src);
	}
	Future<ByteBuffer> getBinary(String src) {
		return _getBin(src);
	}
}




class ResourceManager {
	final Map< String, Asset> _loadedAssets = < String, Asset>{};
  final Map _localCachedAssets = {};
  Loader _resourceLoader;



  ResourceManager() {
  	final getText = _ioDevice.httpRequestTextFile;
  	final getBin = _ioDevice.httpRequestBinaryFile;
  	_resourceLoader = new Loader((src) => getText(src),(src) => getBin(src));
  }

  Future init() {

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


class Resources {
  static void saveAsString(String src, String value) {
    //_localFileHandler.saveString(src, value);
  }
  static void saveAsBinary(String src, ByteBuffer buffer) {
    //_localFileHandler.saveBinary(src, buffer);
  }

  static Future<String> getText(String src) {
  	return _resourceManager._resourceLoader.getText(src);
  }
  static Future<ByteBuffer> getBinary(String src) {
  	return _resourceManager._resourceLoader.getBinary(src);
  }

  /// Loads the requestet Asset (as webrequest or local) and returns it even when it is not loaded yet.
  static Asset load(String src) {
    return _resourceManager._loadAsset(src);
  }

  /// Loads the requestet Asset and returns a Future that will complete when the requestet asset is loaded with all of its dependencies.
  static Future<Asset> loadAsync(String src) {
    return _resourceManager._loadAsset(src).notifyOnLoad();
  }
}



@mist.MistReflect(includeSubclasses: true)
class AssetHandler {
  Asset create() {

  }
  Asset load(String src, Loader loader) {

  }
  Future<Asset> save(Asset asset, String src, var saveDevice) {

  }
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
  void loadingDone(Asset asset) {
    asset._loadingDone();
  }

}



class Asset {
  AssetHandler _assetHandler;
  String _assetId;
  String get assetId => _assetId;
  final Set<dynamic> _dependentList = new Set<dynamic>();
  void dependsOnThis(dynamic requireThis) {
    _dependentList.add(requireThis);
  }
  void removeDepenency(dynamic notRequireThis) {
    _dependentList.remove(notRequireThis);
  }


  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  final List<Completer<Asset>> _notifyList = new List<Completer<Asset>>();

  void _loadingDone() {
    _isLoaded = true;
    _notifyList.forEach((var comp) {
      comp.complete(this);
    });
    _notifyList.clear();
  }

  Future<Asset> notifyOnLoad() {
    if(_isLoaded == true) {
      return new Future.value(this);
    }
    var comp = new Completer<Asset>();
    _notifyList.add(comp);
    return comp.future;
  }
}