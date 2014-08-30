part of harmony;


/// Allocate new Component
typedef Component componentConstructor();


/// Stores unused Components
class ComponentPool {
  final List<Component> _freeList = new List<Component>();
  final dynamic _constructor;

  /// Construct an empty component pool
  ComponentPool(this._constructor) {
  }

  /// Get the next free component or contruct a new instance of Component.
  Component getFreeComponent() {
    if (_freeList.length > 0) {
      return _freeList.removeLast();
    }
    return _constructor();
  }

  /// Add a component to the component pool's free list.
  void add(Component component) {
    _freeList.add(component);
  }
}