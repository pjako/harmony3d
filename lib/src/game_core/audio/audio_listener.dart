part of game_core;



typedef void AudioSourceCallback(AudioSource audio);


class Audio {
  static void playMusic(AudioClip clip) {
    _audioDevice.playMusic(clip);
  }
  static void fadeInMusic(AudioClip clip, double delay, double fadeDuration) {
    _audioDevice.crossFadeMusicLinear(clip, delay, fadeDuration);
  }
}


class AudioListener extends Component {
  final Listener _listener = new Listener(_audioDevice, '');


  void _init() {
    print('LISTENER!');
  }

  void update() {
    _listener.setPosition(
        gameObject.transform._worldMatrix[12],
        gameObject.transform._worldMatrix[13],
        gameObject.transform._worldMatrix[14]);
  }

  bool _pause;
  bool get pause => _pause;
  void set pause(bool p) {
    _pause = p;
  }
  double _volume;
  double get volume => _volume;
  void set volume(double v) {
    if(v > 1.0) {
      _volume = 1.0;
      return;
    }
    if(v < 0.0) {
      _volume = 0.0;
      return;
    }
    _volume = v;
  }
}