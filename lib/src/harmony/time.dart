part of harmony;

typedef bool TimerCallback(GameTimer gameTimer);

class Time {
	/// Time passed since the last Frame
  static double get deltaTime => _engineManager._actualDeltaTime;
  /// Current Frame
  static int get frameCount => _engineManager._frameCounter;
  //static int get timeSinceSceneLoad => _timeDevice.timeSinceSceneLoad;
  /// Current game time
  static double get gameTime => _engineManager._gameTime;
  /// Time since Engine started
  static double get realTimeSinceStartup => _engineManager._time;
  //static createTimer(double time, bool periodic, TimerCallback callback);

  static GameTimer createTimer(double time, TimerCallback callback, {bool periodic: false}) {
    return new GameTimer(time,callback,periodic);
  }

}
