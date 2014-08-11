part of harmony;


/**
 * Manages all Components (instead of the scene directly)
 */
class ComponentManager {
  //static final ComponentManager _current = new ComponentManager();

  final List<mist.ClassInfo> _classInfos = mist.getAllSubclassesInfoOf(Component);
  final Map<Type, ComponentSystem> _systems = {};
  final List<ComponentSystem> _updateComponentSystems = new List<ComponentSystem>();
  final List<ComponentSystem> _lateUpdateComponentSystems = new List<ComponentSystem>();
  final List<ComponentSystem> _fixedUpdateComponentSystems = new List<ComponentSystem>();

  ComponentManager() {
    //_systems[Transform] = new TransformSystem._internal();
  }

  void _setDefaultComponents() {

  }

  /**
   * Creates a component of the specified type and attaaches it to the given
   * game object
   */
  Component createComponent(Type type) {
    var sys = getSystemForType(type);
    var comp = sys.createComponent();
    comp._system = sys;
    return comp;
  }//_createComponentByString


  /**
   * Creates a component of the specified [type] and attaaches it to the given
   * game object
   */
  Component _createComponentByString(String type) {
  	if(!type.contains('.')) {
  		type = 'harmony.$type';
  	}
    var sys;// = getSystemForType(type);
    for(var system in _systems.values) {
    	if(system.componentName == type) {
    		sys = system;
    		break;
    	}
    }
    if(sys == null) {
    	var comp;
      for(int i=0; _classInfos.length > i; i++) {
        comp = _classInfos[i];
        if(comp.qualifiedName == type) {
        	sys = getSystemForType(comp.type);
        }
      }
    }
    if(sys == null) {
    	throw 'Component of type "$type" does not exist';
    }

    var comp = sys.createComponent();
    comp._system = sys;
    return comp;
  }//_createComponentByString

  /**
   * Returns the component system for the specified type.
   * Throws an ArgumentError if the type is not registered.
   */
  ComponentSystem getSystemForType(Type type) {
    var s = _systems[type];
    if(s == null) {
      mist.ClassInfo comp;
      for(int i=0; _classInfos.length > i; i++) {
        comp = _classInfos[i];
        if(comp.type == type) break;
      }
      final system = new ComponentSystem(comp);
      _digestComponentSystem(system);
      return system;
    }
    return s;
  }

  void _digestComponentSystem(ComponentSystem sys) {
    _systems[sys.componentType] = sys;
    if(sys.getMethod('fixedUpdate') != null) {
      _fixedUpdateComponentSystems.add(sys);
    }
    if(sys.getMethod('update') != null) {
      _updateComponentSystems.add(sys);
    }
    if(sys.getMethod('lateUpdate') != null) {
      _lateUpdateComponentSystems.add(sys);
    }
  }

  /**
   * Register a component [system] with [typeName].
   */
  void registerComponentSystem(Type type, ComponentSystem system) {
    _systems[type] = system;
  }

  void destroyComponent(Component comp) {
    final sysLive = comp._system._liveComponents;
    if(_loopingType == null) return;
    if(comp._system != _loopingType) return;
    final compIdx = sysLive.indexOf(comp);
    if(compIdx == -1) return;

    if(compIdx >= _loopIndex) {
      _loopIndex--;
    }
  }
  Type _loopingType;
  int _loopIndex;
  bool _needsIndexChange = false;


  void _loopOverLiveComps(List<dynamic> l, Type type, call) {
    _loopingType = type;
    for(int i=0; i < l.length; i++) {
      final dynamic comp = l[i];
      _loopIndex = i;
      call(comp);
      if(_needsIndexChange) {
        i = _loopIndex;
        _needsIndexChange = false;
      }
    }
    _loopIndex = null;
    _loopingType = null;
  }

  void updateComponents() {
    final call = (c) {c.update();};
    for (dynamic system in _updateComponentSystems) {
      _loopOverLiveComps(system._liveComponents,system.componentType,call);
    }
  }
  void lateUpdateComponents() {
    final call = (c) {c.lateUpdate();};
    for (dynamic system in _lateUpdateComponentSystems) {
      _loopOverLiveComps(system._liveComponents,system.componentType,call);
    }
  }
  void fixedUpdateComponents() {
    final call = (c) {c.fixedUpdate();};
    for (dynamic system in _fixedUpdateComponentSystems) {
      _loopOverLiveComps(system._liveComponents,system.componentType,call);
    }
  }
}