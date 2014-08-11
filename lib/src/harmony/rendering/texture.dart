part of harmony;

@HandlesAsset('jpg') @HandlesAsset('png')
class TextureHandler extends AssetHandler {
  List<Texture2D> _cache = [];
  Asset _getFree() {
    if(_cache.isEmpty) {
      return new Texture2D();
    }
    return _cache.removeLast();
  }

  Asset create() => _getFree();

  Asset load(String src, Loader loader) {
    var texture = new Texture2D();
    texture._texture = new dml.Texture2D(_graphicsDevice);
    texture._texture.uploadImageFromUrl(src).then((bin) {
    	texture._texture.generateMipmap();
      this.loadingDone(texture);
      //print('texture loaded! $src ${texture._texture.width} ${texture._texture.height}');
    });

    return texture;
  }

  bool unload(Asset asset) {
    var texture = asset as Texture;
    texture._parameters.initData = null;
    texture._parameters.customData = null;
    _cache.add(texture);
    return true;
  }
  Future save(Asset asset, String src, Loader loader) {
  }
}

class Texture2D extends Texture {
  dml.Texture2D _texture;
  //dml.Texture2D get glTexture => _texture;
  dml.SamplerState _sampler;
  //dml.SamplerState get glSampler => _sampler;

  int get width => _texture.width;
  int get height => _texture.height;
  dml.TextureMagFilter get magFilter => _sampler.magFilter;
  void set magFilter(dml.TextureMagFilter filter) {
    _sampler.magFilter = filter;
  }


  dml.TextureMinFilter get minFilter => _sampler.minFilter;
  void set minFilter(dml.TextureMinFilter filter) {
    _sampler.minFilter = filter;
  }

  dml.TextureAddressMode get wrapMode => _sampler.addressU;
  void set wrapMode(dml.TextureAddressMode mode) {
    _sampler.addressU = mode;
    _sampler.addressV = mode;
    //dml.TextureMagFilter.Linear
    //dml.TextureMinFilter.
    //_sampler.magFilter
    //_sampler.minFilter
    //_sampler.maxAnisotropy
  }

  set maxAnisotropy(double value) {
    _sampler.maxAnisotropy = value;
  }
  double get maxAnisotropy => _sampler.maxAnisotropy;

  Texture2D() {
  }

}


class Texture extends Asset {
  int get width => 0;
  int get height => 0;
  /// The magnification filter to use.
  ///
  /// If the [Texture] does not contain mipmaps, such as non-power of
  /// two textures, then the only valid values are Texture.Linear and
  /// Texture.Point.
  dml.TextureMagFilter get magFilter => null;
  void set magFilter(dml.TextureMagFilter filter) {}

  /// The minification filter to use.
  dml.TextureMinFilter get minFilter => null;
  void set minFilter(dml.TextureMinFilter filter) {}

  /// The maximum anisotropy.
  ///
  /// Anisotropic filtering is only available through an extension to Webdml.
  /// The maximum acceptable value is dependent on the graphics hardware, and
  /// can be queried within [GraphicsDeviceCapabilities]. When setting the value
  /// the anisotropy level will be capped to the range 1 <
  /// [GraphicsDeviceCapabilities.maxAnisotropyLevel]
  ///
  /// Throws [ArgumentError] if [value] is not a positive number.
  ///
  set maxAnisotropy(double value) {
  }
  double get maxAnisotropy => 0.0;

  /// The texture-address mode for the uv-coordinate.
  dml.TextureAddressMode get wrapMode => null;
  void set wrapMode(dml.TextureAddressMode mode) {
  }

}