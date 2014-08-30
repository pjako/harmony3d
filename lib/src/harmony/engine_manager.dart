part of harmony;


/// Manage execution of the Engine
/// Also measures Time related stuff, basically the gameloop
/// of harmony3D
class _EngineManager {
  final Stopwatch _stopWatch = new Stopwatch();
  final List<GameTimer> _timers = [];
  double _gameTime = 0.0;
  bool _consoleBuild = false;
  static bool _pause = false;

  double _updateTimeStep = 0.015;
  double _maxAccumulatedTime = 0.03;
  double _renderInterpolationFactor = 0.0;
  double _accumulatedTime = 0.0;
  double _previousFrameTime;
  double _actualDeltaTime = 0.0;
  int _frameCounter = 0;
  double _frameTime;
  bool _interrupt;


  _EngineManager() {
    _dmlWindow.requestAnimationFrame(_frame);
    _stopWatch.start();
  }

  void start() {
    //_stopWatch.elapsedMicroseconds

  }

  set pause(bool p) {
    _pause = p;
  }
  get pause => _pause;


  double get _time => _stopWatch.elapsedMicroseconds / 1000000.0;



  var _frameStartTime;
  void _frame(_) {
    //_actualDeltaTime = (_stopWatch.elapsedMicroseconds - _frameStartTime) / 1000000.0;
    //_frameStartTime = _stopWatch.elapsedMicroseconds;
    /// Pulls all events that happen so far
    _dmlWindow.pullEvents();

    if (_previousFrameTime == null) {
      _frameTime = _time;
      _previousFrameTime = _frameTime;
      //_processInputEvents();
      _dmlWindow.requestAnimationFrame(_frame);
      return;
    }
    if (_interrupt == true) {
      _dmlWindow.cancelNexAnimationFrame();
      return;
    }
    _dmlWindow.requestAnimationFrame(_frame);
    _previousFrameTime = _frameTime;
    _frameTime = _time;
    double timeDelta = _frameTime - _previousFrameTime;
    _accumulatedTime += timeDelta;
    if (_accumulatedTime > _maxAccumulatedTime) {
      // If the animation frame callback was paused we may end up with
      // a huge time delta. Clamp it to something reasonable.
      _accumulatedTime = _maxAccumulatedTime;
    }

    _actualDeltaTime = _updateTimeStep;
    double cacheActualTime = 0.0;
    while (_accumulatedTime >= _updateTimeStep) {
      _frameCounter++;
      //_inputDevice.update(_gameTime, _frameCounter);
      //_processInputEvents();


      _gameTime += _updateTimeStep;
      _fixedUpdate();
      _accumulatedTime -= _updateTimeStep;

      cacheActualTime += _updateTimeStep;
    }
    _actualDeltaTime = cacheActualTime;
    _componentManager.updateComponents();
    _componentManager.lateUpdateComponents();

    if (!_consoleBuild) {
      _renderInterpolationFactor = _accumulatedTime/_updateTimeStep;
      _render();
    } else {

    }
  }

  void _processTimers() {
    int _timersLength = _timers.length;
    for (int i = 0; i < _timersLength; i++) {
      _timers[i]._update(Time.deltaTime);
    }
    for (int i = _timers.length-1; i >= 0; i--) {
      int lastElement = _timers.length-1;
      if (_timers[i]._isDead) {
        if (i != lastElement) {
          // Swap into i's place.
          _timers[i] = _timers[lastElement];
        }
        _timers.removeLast();
      }
    }
  }


  void _fixedUpdate() {
    if(_physicsDevice2d != null) {
      _physicsDevice2d.step(Time.deltaTime);
    }
    if(_physicsDevice3d != null) {
      _physicsDevice3d.update(Time.deltaTime);
    }
    _componentManager.fixedUpdateComponents();
  }


  void _render() {
    _renderManager._render();
  }



}
