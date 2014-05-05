part of game_core;

typedef Component componentConstructor();

class ComponentPool {
  final List<Component> _freeList = new List<Component>();
  dynamic _constructor;

  /**
   * Construct an empty component pool
   */
  ComponentPool(this._constructor) {
  }

  /** 
   * Get the next free component or contruct a new instance of Component.
   */
  Component getFreeComponent() {
    if (_freeList.length > 0) {
      return _freeList.removeLast();
    }
    return _constructor();
  }

  /**
   * Add a component to the component pool's free list.
   */
  void add(Component component) {

    component._free();

    _freeList.add(component);
  }
}


class ReflectionComponentPool extends ComponentPool {

  ReflectionComponentPool(ClassMirror mirror) :
    super(() => mirror.newInstance(emptySymbol,emptyList).reflectee) {
  }

}
