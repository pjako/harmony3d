part of harmony;


/// The GameTimer is managed by the harmony3d Engine
/// After the GameTimer calls the callback (when its not periodic) or if it gets canceled
/// the GameTimer gets reused to reduce GC
class GameTimer {
  double _callTime;
  bool periodic;

  double _timeToFireRemaining = 0.0;
  /// Time until timer fires.
  double get timeToFire => _timeToFireRemaining;

  TimerCallback _callback;

  /// creates a game timer which which calls [_callback] after specified time
  /// [_calltime] in seconds.
  /// if [periodic] is true this gets called periodic after [_callTime]
  GameTimer(this._callTime, this._callback, this.periodic) {
    _timeToFireRemaining = _callTime;
    _engineManager._timers.add(this);
  }
  /*
  void setTimer(double callTime_, TimerCallback callback_, bool periodic_) {
    _callTime = callTime_;
    _callback = callback_;
    periodic = periodic_;
  }*/

  void _update(double dt) {
    if (_isDead) {
      // Dead.
      return;
    }
    _timeToFireRemaining -= dt;
    if (_timeToFireRemaining <= 0.0) {
      if (_callback != null) {
        _callback(this);
      }
    }
  }

  /// cancles the timer
  void cancel() {
    _timeToFireRemaining = -1.0;
    periodic = false;
  }

  bool get _isDead {
    bool expired = _timeToFireRemaining <= 0.0;
    if (expired && periodic) {
      _timeToFireRemaining = _callTime;
      return false;
    } if (expired) {
      return true;
    } else {
      return false;
    }
  }



}