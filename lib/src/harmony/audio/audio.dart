part of harmony;

/// Audio
/// A simple music controller
class Audio {
  /// Plays a music clip
  static void playMusic(AudioClip clip) {
    _audioDevice.playMusic(clip._buffer);
  }
}