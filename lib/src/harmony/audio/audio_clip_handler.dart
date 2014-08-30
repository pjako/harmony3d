part of harmony;

@HandlesAsset('wav') @HandlesAsset('ogg') @HandlesAsset('mp3')
class AudioClipHandler extends AssetHandler {
	AudioClipHandler() {
  }
  List<Shader> _cache = [];
  Asset _getFree() {
    if(_cache.isEmpty) {
      return new Shader();
    }
    return _cache.removeLast();
  }

  Asset create() => new AudioClip();

  Asset load(String src, Loader loader) {
  	final clip = new AudioClip();
  	clip._buffer = new audio.AudioBuffer(_audioDevice);
  	clip._buffer.uploadFromUrl(src).then((_) {
  		this.loadingDone(clip);
  	});
    return clip;
  }
  bool unload(Asset asset) {
    var shader = asset as Shader;
    _cache.add(shader);
    return true;
  }
  Future save(Asset asset, String src, Loader loader) {
  }
}