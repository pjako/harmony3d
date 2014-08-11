part of harmony;




typedef void AudioSourceCallback(AudioSource audio);

/********************************************************
 * Audio
 *
 * A simple music controller
 *
 ********************************************************/
class Audio {
  /// Plays a music clip
  static void playMusic(AudioClip clip) {
    _audioDevice.playMusic(clip._buffer);
  }
  /// Fade in a music clip with fadeduration
  static void fadeInMusic(AudioClip clip, double delay, double fadeDuration) {
    //_audioDevice.crossFadeMusicLinear(clip, delay, fadeDuration);
  }
  /*
  /** Get the music volume. */
  static num get musicVolume => _audioDevice.musicVolume;
  /** Set the music volume. */
  static void set musicVolume(num mv) {
    _audioDevice.musicVolume = mv;
  }

  /** Get the master volume. */
  static num get masterVolume => _audioDevice.masterVolume;
  /** Set the master volume. */
  static void set masterVolume(num mv) {
    _audioDevice.masterVolume = mv;
  }

  /** Get the sources volume */
  static num get sourceVolume => _audioDevice.sourceVolume;
  /** Set the sources volume */
  static void set sourceVolume(num mv) {
    _audioDevice.sourceVolume = mv;
  }*/

  /** Is the master volume muted? */
  //static bool get mute => _audioDevice.mute;

  /** Control the master mute */
  /*static void set mute(bool b) {
    _audioDevice.mute = b;
  }*/
}

/********************************************************
 * Audio Listener
 *
 * A Microphone like Audiorecorder
 *
 ********************************************************/
class AudioListener extends Component {


  void _init() {
  }

  void update() {
    _audioDevice.listener.setPosition(
        gameObject.transform._worldMatrix[12],
        gameObject.transform._worldMatrix[13],
        gameObject.transform._worldMatrix[14]);
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