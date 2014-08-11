part of harmony.browser;

/// Needs to be replaced with Harmony implementation
class TempFileLoader implements FileLoader {
	Future<ByteBuffer> loadBinaryFile(String src) {
		return HttpRequest.request(src, responseType: 'arraybuffer').then((req) => req.response);
	}
	Future<String> loadTextFile(String src) {
		return HttpRequest.getString(src);
	}
}




@HandlesAsset('png')
class HtmlTextureHandler extends TextureHandler {
  List<Texture> _cache = [];


  Asset create() => super.create();

  Asset load(String src, LoaderDevice loader) {
    var texture = create();
    var type = src.substring(src.lastIndexOf('.'));

    loader.loadFileAsBinary(src).then((bin) {
      String mime;
      switch(type) {
        case('png'):
          mime = 'image/png';
        break;
        default:
          mime = 'image/jpeg';
      }

      var url = Url.createObjectUrlFromBlob(new Blob([bin],mime,'native'));
      var img = new ImageElement(src: url);
      img.onLoad.first.then((_) {
        setTextureInitData(texture, img, bin);
        loadingDone(texture);
      });
    });

    return texture;
  }


  bool unload(Asset asset) {
    return super.unload(asset);
  }
  Future save(Asset asset, String src, LoaderDevice loader) {
  }
}