part of game_core;


var _componentMirror = reflectClass(new Component().runtimeType);

class ContainsComponents {
  final _i;
  const ContainsComponents(this._i);
}

const ContainsComponents containsComponents = const ContainsComponents(0);




/**
 * Manages all Components
 */
class ComponentManager {
  //static final ComponentManager _current = new ComponentManager();


  final Map<String, ComponentSystem> _systems = {};
  final List<ComponentSystem> _updateComponentSystems = new List<ComponentSystem>();
  final List<ComponentSystem> _lateUpdateComponentSystems = new List<ComponentSystem>();

  ComponentManager() {
  }
  /**
   * Creates a component of the specified type and attaaches it to the given
   * game object
   */
  Component createComponent(String type) {
    var sys = getSystemForType(type);
    var comp = sys.createComponent();
    comp._system = sys;
    return comp;
  }

  /**
   * Destroys the given component.
   */
  void destroyComponent(Component component) {
    getSystemForType(component.type).deleteComponent(component);
  }

  /**
   * Returns the component system for the specified type.
   * Throws an ArgumentError if the type is not registered.
   */
  ComponentSystem getSystemForType(String type) {
    var s = _systems[type];
    if(s == null) {
      var classSymbol = new Symbol(type);
      var classMirror = searchClassMirrorSimple(classSymbol, test: (t) {
        return classMirrorIsSuperClassOf(t,_componentMirror);
      });
      if(classMirror == null) throw new ArgumentError('Unknown type: $type');
      var sys = new ComponentSystem(type,classMirror);
      if(sys == null) throw new ArgumentError('$type is no Subclass of Component');
      registerComponentSystem(type,sys);
      if(sys.needsUpdate) {
        _updateComponentSystems.add(sys);
      }
      if(sys.needsLateUpdate) {
        _lateUpdateComponentSystems.add(sys);
      }
      _systems[type] = sys;
      return sys;


      /*
      {
        var lib = currentMirrorSystem().findLibrary(const Symbol('game_core'));
        var c = lib.declarations[classSymbol];
        if(c != null && c is ClassMirror) {
          var sys = new ComponentSystem(type,c);
          if(sys == null) throw new ArgumentError('$type is no Subclass of Component');
          registerComponentSystem(type,sys);
          if(sys.needsUpdate) {
            _updateComponentSystems.add(sys);
          }
          if(sys.needsLateUpdate) {
            _lateUpdateComponentSystems.add(sys);
          }
          _systems[type] = sys;
          return sys;
        }
      }
      var libs = currentMirrorSystem().libraries.values.toList(growable: false);

      for(int i= libs.length-1; 0 <= i; i--) {
        var lib = libs[i];
        var c = lib.declarations[classSymbol];
        if(c != null && c is ClassMirror) {
          var sys = new ComponentSystem(type,c);
          if(sys == null) throw new ArgumentError('$type is no Subclass of Component');
          registerComponentSystem(type,sys);
          if(sys.needsUpdate) {
            _updateComponentSystems.add(sys);
          }
          if(sys.needsLateUpdate) {
            _lateUpdateComponentSystems.add(sys);
          }
          _systems[type] = sys;
          return sys;
        }
      }
      */
      /*
      for(var lib in currentMirrorSystem().libraries.values) {
        bool test = false;
        for(var meta in lib.metadata) {
          if(meta.reflectee is ContainsComponents) {
            test = true;
            break;
          }
        }
        if(test == false) continue;
        var c = lib.declarations[classSymbol];
        if(c != null && c is ClassMirror) {
          var sys = new ComponentSystem(type,c);
          if(sys == null) throw new ArgumentError('$type is no Subclass of Component');
          registerComponentSystem(type,sys);
          if(sys.needsUpdate) {
            _updateComponentSystems.add(sys);
          }
          if(sys.needsLateUpdate) {
            _lateUpdateComponentSystems.add(sys);
          }
          return sys;
        }
      }
      throw new ArgumentError('Unknown type: $type');*/

    }
    return s;
  }

  /**
   * Register a component [system] with [typeName].
   */
  void registerComponentSystem(String typeName, ComponentSystem system) {
    _systems[typeName] = system;
  }

  /**
   * Goes through the list of component systems and issues update signals.
   */
  void updateComponents() {
    for (var system in _updateComponentSystems) {
      system.updateComponents(); //Have fun!
    }
  }
  void lateUpdateComponents() {
    for (var system in _lateUpdateComponentSystems) {
      system.lateUpdateComponents(); //Have fun!
    }
  }
}