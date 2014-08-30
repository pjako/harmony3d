part of harmony;


/// Audio Source
/// A Source of Audio in the 3D Space
class AudioSource extends Component {
  final audio.AudioSource _source = new audio.AudioSource(_audioDevice);
  @Serialize(SerializeType.asset, customName: 'clip')
  AudioClip _currentClip;
  @Serialize(SerializeType.double, customName: 'volume')
  double _volume = 1.0;
  @Serialize(SerializeType.bool, customName: 'mute')
  bool _mute = false;
  @Serialize(SerializeType.double, customName: 'minDistance')
  double _minDistance = 0.0;

  final Aabb3 _bounds = new Aabb3();


  void _init() {
    gameObject._audio = this;
    _bounds.min.setValues(-_minDistance, -_minDistance, -_minDistance);
    _bounds.max.setValues(_minDistance, _minDistance, _minDistance);
    _source.setPosition(
         gameObject.transform._worldMatrix[12],
         gameObject.transform._worldMatrix[13],
         gameObject.transform._worldMatrix[14]);
    //_source.playLooped(_currentClip);
  }


  /// Set the current [clip]
  AudioClip get clip => _currentClip;
  void set clip(AudioClip c) {
    _currentClip = c;
  }
  /// Play the current audio clip
  void play({bool looped: false}) {
    if(_currentClip == null) return;
    _source.loop = looped;
    _source.play(_currentClip._buffer);
  }

  /// Get the Pausestatus
  bool get pause => _source.pause;
  /// pause/unpause this audio source
  void set pause(bool b) {
    _source.pause = b;
  }

  /// Get the volumen
  double get volume => _source.volume;
  /// Set the volumen
  void set volume(double v) {
    _source.volume = v;
  }
}