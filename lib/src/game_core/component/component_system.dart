part of game_core;
const methodLateUpdate = const Symbol('lateUpdade');
const methodUpdate = const Symbol('updade');
const emptySymbol = const Symbol('');
final emptyList = [];
class Serialize {
  final SerializeType type;
  final String customName;
  const Serialize(SerializeType this.type, {String this.customName});
}

class Dependencies {
  final List<String> _dep;
  const Dependencies(this._dep);
}
class SerializeType { 
  final _i;
  const SerializeType(this._i);
  static const int8 = const SerializeType(0);
  static const int16 = const SerializeType(1);
  static const int32 = const SerializeType(2);
  static const uInt8 = const SerializeType(3);
  static const uInt16 = const SerializeType(4);
  static const uInt32 = const SerializeType(5);
  static const float16 = const SerializeType(6);
  static const float32 = const SerializeType(7);
  static const double = const SerializeType(8);
  static const int = const SerializeType(9);
  static const object = const SerializeType(10);
  static const vec2 = const SerializeType(11);
  static const vec3 = const SerializeType(12);
  static const vec4 = const SerializeType(13);
  static const matrix4 = const SerializeType(13);
  static const matrix3 = const SerializeType(14);
  static const matrix34 = const SerializeType(15);
  static const string = const SerializeType(16);
  static const quat = const SerializeType(17);
  static const bool = const SerializeType(18);
}


Uint8List decodeUint8(String base64String) {
  return new Uint8List.view(base64decoder.decode(base64String));
}

Uint16List decodeUint16(String base64String) {
  return new Uint16List.view(base64decoder.decode(base64String));
}
Uint32List decodeUint32(String base64String) {
  return new Uint32List.view(base64decoder.decode(base64String));
}

Uint8List decodeInt8(String base64String) {
  return new Uint8List.view(base64decoder.decode(base64String));
}

Uint16List decodeInt16(String base64String) {
  return new Uint16List.view(base64decoder.decode(base64String));
}
Uint32List decodeInt32(String base64String) {
  return new Uint32List.view(base64decoder.decode(base64String));
}
Int64List decodeInt64(String base64String) {
  return new Int64List.view(base64decoder.decode(base64String));
}

Float32List decodeFloat32(String base64String) {
  return new Float32List.view(base64decoder.decode(base64String));
}






abstract class ComponentSystem {
  final String componentName;
  List<String> get dependencies;

  Map decodeComponents(List<Component> components, Map<String,dynamic> componentsData, Map<int, dynamic> objects);
  Map encodeComponents(List<Component> components, Map<int, dynamic> objects);
  bool get needsUpdate;
  bool get needsLateUpdate;
  bool get useInit;
  bool get useFree;
  void deleteComponent(Component comp);
  Component createComponent();


  void updateComponents();
  void lateUpdateComponents();


  factory ComponentSystem(String type, ClassMirror mirror) {

    for(var meta in mirror.metadata) {
      if(meta.reflectee is ComponentSystem) {

        return meta.reflectee;
      }
    }
    return new MirrorComponentSystem(type,mirror);
  }

  /*
  static MirrorComponentSystem _getCustomSystem(Symbol symbol) {
    for(var lib in currentMirrorSystem().libraries.values) {
      var c = lib.declarations[symbol];//.classes[classSymbol];
      if(c != null) {
        var sys = (c as ClassMirror).newInstance(emptySymbol, emptyList);
        if(sys is! MirrorComponentSystem) {
          throw '$symbol does not implement the ComponentSystem interface';
        }
        return sys;
      }
    }
    return null;
  }*/
}


class MirrorComponentSystem implements ComponentSystem {
  final String componentName;
  final ComponentPool componentPool;
  final Map<Symbol,dynamic> _defaultValues = {};
  final Map<Symbol,dynamic> _seralizeHelper = {};
  final Map<String,SerializeType> _serializeMap = {};
  final Map<String,Symbol> _valueNameSymbol = {};
  final Set<Symbol> _notSaveAsBase64 = new Set<Symbol>();
  final ClassMirror _mirror;
  final List<Component> _liveComponents = new List<Component>();

  bool _useInit = false;
  bool _useFree = false;
  bool _needsUpdate = false;
  bool _needsLateUpdate = false;
  List<String> _dependencies;

  List<String> get dependencies => _dependencies;
  bool get needsUpdate => _needsUpdate;
  bool get needsLateUpdate => _needsLateUpdate;
  bool get useInit => _useInit;
  bool get useFree => _useFree;
  void deleteComponent(Component comp) {
    var refComp =  reflect(comp);
    _defaultValues.forEach((Symbol name, var value) {
      if(value == null) {
        refComp.setField(name, value);
        return;
      }
      if(value is String || value is num) {
        refComp.setField(name, value);
        return;
      }
      if(value is Vector3) {
        Vector3 ref = refComp.getField(name).reflectee;
        if(ref == null) {
          refComp.setField(name, new Vector3.copy(value));
          return;
        }
        value.copyInto(ref);
      }

    });


    componentPool.add(comp);
    _liveComponents.remove(comp);
  }


  void updateComponents() {
    for(dynamic comp in _liveComponents) {
      comp.update();
    }
  }
  void lateUpdateComponents() {
    for(dynamic comp in _liveComponents) {
      comp.lateUpdate();
    }
  }




  MirrorComponentSystem(String this.componentName, ClassMirror mirror) :
    _mirror = mirror,
    componentPool = new ReflectionComponentPool(mirror) {
    for(var meta in _mirror.metadata) {
      if(meta is Dependencies) {
        _dependencies = meta._dep;
        break;
      }
    }
    if(_dependencies == null) _dependencies = [];

    if(mirror.declarations[const Symbol('lateUpdate')] != null) _needsLateUpdate = true;
    if(mirror.declarations[const Symbol('update')] != null) _needsUpdate = true;
    if(mirror.declarations[const Symbol('init')] != null) _useInit = true;



    mirror.declarations.forEach((var key, DeclarationMirror value) {
      for(InstanceMirror meta in value.metadata) {
        if(meta.reflectee is Serialize) {
          var ca = meta.reflectee.customName;
          if(ca != null) {
            _serializeMap[ca] = (meta.reflectee as Serialize).type;
            _valueNameSymbol[ca] = key;
            return;
          }
          _serializeMap[MirrorSystem.getName(value.simpleName)] = (meta.reflectee as Serialize).type;
          _valueNameSymbol[ca] = key;
          return;
        }
      }
    });



    if(mirror.declarations[const Symbol('free')] != null) {
      _useFree = true;
      return;
    }
    var defaultComponent = mirror.newInstance(const Symbol(''), emptyList);
    mirror.declarations.forEach((var name, var variable) {
      if(variable is VariableMirror) {
        if(variable.isStatic) return;
        // FIXME: Wait till its implemented in dart2js
        //if(variable.isConst) return;
        var v = defaultComponent.getField(name).reflectee;
        if(v == null || v is Vector3 || v is num || v is String) {
          _defaultValues[name] = v;
        }
      }
    });
  }

  Component createComponent() {
    var component = componentPool.getFreeComponent();
    assert(component != null);
    addToLiveComponents(component);
    return component;
  }

  void addToLiveComponents(var component) {
    _liveComponents.add(component);
  }

  Map decodeComponents(List<Component> components, Map<String,dynamic> componentsData, Map<int, dynamic> objects) {
    int length = components.length;
    _serializeMap.forEach((var variableName, dynamic data) {
      //String variableName = variableSymbol;
      var rawData = componentsData[variableName];
      print(rawData);
      List list;
      if(rawData is String) {
        // base64
        var type = data;
        switch(type) {
          case(SerializeType.float32):
            list = decodeFloat32(rawData);
          break;
          case(SerializeType.uInt8):
            list = decodeUint8(rawData);
          break;
          case(SerializeType.uInt16):
            list = decodeUint16(rawData);
          break;
          case(SerializeType.uInt32):
            list = decodeUint32(rawData);
          break;
          case(SerializeType.int16):
            list = decodeInt16(rawData);
          break;
          case(SerializeType.int32):
            list = decodeInt32(rawData);
          break;
          case(SerializeType.int):
            list = decodeInt64(rawData);
          break;
          case(SerializeType.object):
            list = decodeUint32(rawData);
          for(int i=0; i < length; i++) {
            int objId = list[i];
            if(objId == 0) {
              reflect(components[i]).setField(_valueNameSymbol[variableName], null);
            } else {
              reflect(components[i]).setField(_valueNameSymbol[variableName], objects[objId]);
            }
            return;
          }
          break;

        }

      } else if(rawData is List<num>) {
        print('plling! $variableName');
        var type = data;
        switch(type) {
          case(SerializeType.object):
            list = rawData;
            for(int i=0; i < length; i++) {
              int objId = list[i];
              if(objId == 0) {
                reflect(components[i]).setField(_valueNameSymbol[variableName], null);
              } else {
                reflect(components[i]).setField(_valueNameSymbol[variableName], objects[objId]);
              }
            }
            return;
          case(SerializeType.double):
            list = rawData;
            for(int i=0; i < length; i++) {
              double value = list[i];
              reflect(components[i]).setField(_valueNameSymbol[variableName], value);
            }
            return;
          case(SerializeType.int):
            list = rawData;
            for(int i=0; i < length; i++) {
              int value = list[i];
              reflect(components[i]).setField(_valueNameSymbol[variableName], value);
            }
            return;
        }
        if(type == SerializeType.object) {

        } else {
          list = rawData;
        }

        list = rawData;
      } else if(rawData is List<String>) {
        list = rawData;
      }


      print(variableName);
      for(int i=0; i < length; i++) {
        reflect(components[i]).setField(_valueNameSymbol[variableName], objects[list[i]]);
      }

    });
  }


  Map encodeComponents(List<Component> components, Map<int, dynamic> objects) {
    /*
    _notSaveAsBase64.clear();
    int length = components.length;
    _seralizeHelper.forEach((Symbol k,f) {
      if(f is List) {
        f.clear();
      }
    });
    Uint32List instaceIds = new Uint32List(length);
    for(int i=0; i < length; i++) {
      var comp = components[i];
      instaceIds[i] = comp.instanceId;
      InstanceMirror reflection = reflect(comp);
      _seralizeHelper.forEach((Symbol k,f) {
        if(f is List) {
          var reflectee = reflection.getField(k).reflectee;
          if(reflectee == null && !_notSaveAsBase64.contains(k)) {
            _notSaveAsBase64.add(reflectee);
          }
          f.add(reflectee);
        }
      });
    }
    Map map = {};
    _seralizeHelper.forEach((Symbol k,f) {
      if(f is List) {
        var value;
        var val;
        for(int i=0;val == null; i++) val = f[i];
        if(val is Vector3) {
          if(_notSaveAsBase64.contains(k) || f.length < 3) {
            value = encodeVector3List(f);
          } else {
            value = encodeVector3AsBase64(f);
          }
        } else if(val is num) {
          if(_notSaveAsBase64.contains(k) || f.length < 3) {
            value = f;
          } else {
            var type = _encodeType[k];
            switch(type) {
              case(SerializeType.float32):
                value = encodeFloat32(f);
                break;
              case(SerializeType.uInt8):
                value = encodeUint8(f);
                break;
              case(SerializeType.uInt16):
                value = encodeUint8(f);
                break;
              case(SerializeType.uInt32):
                value = encodeUint8(f);
                break;
              case(SerializeType.int8):
                value = encodeFloat32(f);
                break;
              case(SerializeType.int16):
                value = encodeFloat32(f);
                break;
              case(SerializeType.int32):
                value = encodeFloat32(f);
                break;
              case(SerializeType.int):
                value = encodeFloat32(f);
                break;
              case(SerializeType.object):
                value = objects[];
                break;
              default:
                value = f;
            }
          }
        } else if(val is String) {
          value = f;
        }
        map[k.toString()] = value;
      }
    });
    return map;
    */
  }
}
