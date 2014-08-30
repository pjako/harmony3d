part of harmony;




typedef void AudioSourceCallback(AudioSource audio);



/// Audio Listener
/// A Microphone like Audiorecorder
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
  /// Changes the sound volume
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