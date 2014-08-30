part of harmony;

/// Resources allows access to Assets
class Resources {
  static void saveAsString(String src, String value) {
    //_localFileHandler.saveString(src, value);
  }
  static void saveAsBinary(String src, ByteBuffer buffer) {
    //_localFileHandler.saveBinary(src, buffer);
  }

  /// Gets text data from specified path [src]
  static Future<String> getText(String src) {
  	return _resourceManager._resourceLoader.getText(src);
  }
  /// Gets binary data from specified path [src]
  static Future<ByteBuffer> getBinary(String src) {
  	return _resourceManager._resourceLoader.getBinary(src);
  }

  /// Loads the requestet Asset (as webrequest or local) and returns it even when it is not fully loaded yet.
  static Asset load(String src) {
    return _resourceManager._loadAsset(src);
  }

  /// Loads the requestet Asset and returns a Future that will complete when the requestet asset is loaded with all of its dependencies.
  static Future<Asset> loadAsync(String src) {
    return _resourceManager._loadAsset(src).notifyOnLoad();
  }
}