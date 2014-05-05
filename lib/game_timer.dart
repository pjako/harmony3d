

typedef void GameTimerCallback();
class GameTimerSubscription {
  double _time;
  GameTimerCallback _callback;

  GameTimerSubscription._internal();
  void cancel() {
    _callback = null;

  }

  void then(GameTimerCallback callback) {
    _callback = callback;
  }
}

List<GameTimerSubscription> _pool = [];
void _cacheGameSubscription(GameTimerSubscription gs) {
  gs._time = null;
  gs._callback = null;
  _pool.add(gs);
}
GameTimerSubscription _getGameSubscription() {
  if(_pool.isNotEmpty) return _pool.removeLast();
  return new GameTimerSubscription._internal();
}


class GameTimerManager {
  double _currenTime = 0.0;
  final List<GameTimerSubscription> _subscriptions = [];
  void update(double dt) {
    _currenTime += dt;

  }

  GameTimerSubscription setTimer(double duration) {

  }
}