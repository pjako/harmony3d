part of game_core;

typedef void LoopUpdate();
typedef void LoopRender();

class TimeDevice {
  //final GameLoop _loop;
  //TimeManager(this._loop);
  double get deltaTime => 0.0;
  double get realTimeSinceStartup => 0.0;
  LoopUpdate update;
  LoopRender render;
  void start() {

  }
  void stop() {

  }

}