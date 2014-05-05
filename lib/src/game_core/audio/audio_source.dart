part of game_core;


class AudioSource extends Component {
  final Source _source = new Source(_audioDevice, '');
  @Serialize(SerializeType.object, customName: 'clip')
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


  AudioClip get clip => _currentClip;
  void set clip(AudioClip c) {
    _currentClip = c;
  }
  void play({bool looped: false}) {
    if(_currentClip == null) return;
    if(looped) {
      _source.playLooped(_currentClip);
      return;
    }
    _source.playOnce(_currentClip);
  }

  bool get pause => _source.pause;
  void set pause(bool b) {
    _source.pause = b;
  }

  double get volume => _source.volume;
  void set volume(double v) {
    _source.volume = v;
  }
}