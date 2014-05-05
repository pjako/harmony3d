part of game_core;

typedef bool TimerCallback();

class Time {
  static double get deltaTime => _timeDevice.deltaTime;
  static int get frameCount => _timeDevice.frameCount;
  static int get timeSinceSceneLoad => _timeDevice.timeSinceSceneLoad;
  static double get gameTime => 0.0;
  static double get realTimeSinceStartup => _timeDevice.realTimeSinceStartup;
  //static createTimer(double time, bool periodic, TimerCallback callback);

}
