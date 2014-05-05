part of game_core;

abstract class Update {
  
  void update();
}

abstract class LateUpdate {

  void lateUpdate();
}
abstract class Behaviour extends Component {

}
abstract class ScriptBehaviour extends Behaviour{
  
  
  /// update, can occur more then once per frame after a physic upate
  void update() {

  }
  /// updates after normal update, before the rendering.
  void lateUpdate() {

  }

  /// is called when
  void init() {

  }
}