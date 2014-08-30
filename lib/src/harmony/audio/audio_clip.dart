part of harmony;




/// Contains AudioData
class AudioClip extends Asset {
	audio.AudioBuffer _buffer;
	AudioClip() : _buffer = _audioDevice.createAudioBuffer() {
	}

}