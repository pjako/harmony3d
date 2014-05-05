part of game_core;

class TextureHandler extends AssetHandler {
  List<Texture> _cache = [];
  Asset _getFree() {
    if(_cache.isEmpty) {
      return new Texture();
    }
    return _cache.removeLast();
  }

  Asset create() => _getFree();

  Asset load(String src, LoaderDevice loader) {
    var texture = create();

    loader.loadFileAsBinary(src).then((bin) {
      setTextureInitData(texture, bin, bin);

      this.loadingDone(texture);
    });

    return texture;
  }

  void setTextureInitData(Texture texture, dynamic data, dynamic rawData) {
    texture._fromData( data, rawData);
  }


  bool unload(Asset asset) {
    var texture = asset as Texture;
    texture._parameters.initData = null;
    texture._parameters.customData = null;
    _cache.add(texture);
    return true;
  }
  Future save(Asset asset, String src, LoaderDevice loader) {
  }
}


class Texture extends Asset {
  dynamic _rawData;
  final TextureParameters _parameters = new TextureParameters();


  void _fromData(dynamic data, dynamic _rawData) {
    _parameters.initData = data;
  }
}