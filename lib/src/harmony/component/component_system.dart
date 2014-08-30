part of harmony;


/// How to serialize the Value, which Type and optinal an custom name
class Serialize {
  final SerializeType type;
  final String customName;
  const Serialize(SerializeType this.type, {String this.customName});
}
/// Used to define dependency of an Component as Metadata
class DependsOn {
  final Type type;
  const DependsOn(this.type);
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
  static const halfFloat = const SerializeType(19);
  static const halfVec2 = const SerializeType(20);
  static const halfVec3 = const SerializeType(21);
  static const halfVec4 = const SerializeType(22);
  static const asset = const SerializeType(23);
  static const component = const SerializeType(24);
}


/*Uint8List*/ decodeUint8(var base64String) {
	if(base64String is! String) return base64String;
  return new Uint8List.view(base64decoder.decode(base64String));
}

/*Uint16List*/ decodeUint16(var base64String) {
	if(base64String is! String) return base64String;
  return new Uint16List.view(base64decoder.decode(base64String));
}
/*Uint32List*/ decodeUint32(var base64String) {
	if(base64String is! String) return base64String;
  return new Uint32List.view(base64decoder.decode(base64String));
}

/*Uint8List*/ decodeInt8(var base64String) {
	if(base64String is! String) return base64String;
  return new Uint8List.view(base64decoder.decode(base64String));
}

/*Uint16List*/ decodeInt16(var base64String) {
	if(base64String is! String) return base64String;
  return new Uint16List.view(base64decoder.decode(base64String));
}
/*Uint32List*/ decodeInt32(var base64String) {
	if(base64String is! String) return base64String;
  return new Uint32List.view(base64decoder.decode(base64String));
}
/*Int64List*/ decodeInt64(var base64String) {
	if(base64String is! String) return base64String;
  return new Int64List.view(base64decoder.decode(base64String));
}

/*Float32List*/ decodeFloat32(var base64String) {
	if(base64String is! String) return base64String;
  return new Float32List.view(base64decoder.decode(base64String));
}

/// Componentsystem Manages certain component type
/// It resets and stores them when they are destroyed
/// also does serializing/deserialzing with information from Metadata
class ComponentSystem {
	/// Name of the Component (The classname)
  String get componentName => _info.name;
  mist.ClassInfo _info;
  /// Component to store unused Components
  final ComponentPool _pool;
  /// Default Values for each field of the Component
  final Map<mist.FieldInfo,dynamic> _defaultValues = {};
  /// Serialize Info for each field, digested from Metadata
  final Map<mist.FieldInfo,Serialize> _serialize = {};
  /// Dependencies for other Component Types
  final List<Type> _dependencies = [];
  /// Currently active Components in this Scene
  final List<Component> _liveComponents = [];
  /// Type of this Component
  Type get componentType => _info.type;


  /// Does this Componenttype inplement the init call?
  bool _hasInit = false;
  bool get hasInit => _hasInit;


  static final _emptyList = [];


  Component createComponent() => _pool.getFreeComponent();


  ComponentSystem(mist.ClassInfo info, [var pool]) : this._info = info,
      _pool = pool != null ? pool : new ComponentPool(() => info.newInstance(_emptyList)) {
    _createDefaultValues();
    _setDepenendices();
    _readFields();

  }




  /// Get Method of ComponentType by name
  mist.MethodInfo getMethod(String name) {
    for(final method in _info.methods) {
      if(method.methodName == name) return method;
    }
    return null;
  }

  /// Digest dependency Metadata of a component
  void _setDepenendices() {
    _dependencies.clear();
    final count = _info.metadataCount;
    for(int i=0; i < count; i++) {
      final meta = _info.getMetaData(i);
      if(meta is DependsOn) {
        _dependencies.add(meta.type);
      }

    }
  }

  /// Digst all fields with serialize metadata
  void _readFields() {
    _serialize.clear();
    final fields = _info.fields;
    for(final field in fields) {
      final metaCount = field.metadataCount;
      for(int i=0; metaCount > i; i++) {
        final meta = field.getMetaData(i);
        if(meta is Serialize) {
          _serialize[field] = meta;
        }
      }
    }
  }
  /// Stores default Values for Components Fields
  void _createDefaultValues() {
    _defaultValues.clear();
    _hasInit = false;
    final comp = _pool.getFreeComponent();
    for(final field in _info.fields) {
      final value = field.getField(comp);
      if(field.fieldName == 'init') {
        _hasInit = true;
      }
      if(value == null || value is num || value is String) {
        _defaultValues[field] = value;
      }
    }
    _pool.add(comp);
  }

  /// Add Component [comp] to livecomponents
  void _addLiveComponent(Component comp) {
    if(_liveComponents.contains(comp)) return;
    _liveComponents.add(comp);
  }
  /// Remove given Component from livecomponents
  void _removeLiveComponent(Component comp) {
    _liveComponents.remove(comp);
  }

  /// Destroys Component (dont call this directly!)
  void destroyComponent(Component component) {
    _removeLiveComponent(component);
    reset(component);
    _pool.add(component);
  }

  /// Resets the Component to the default values and removes all non default
  /// Depenendcies on assets
  Component reset(Component component) {
    //print('reset Component');
    final fields = _info.fields;
    _defaultValues.forEach((field,value) {
      var currentValue = field.getField(component);
      if(currentValue is Asset) {
        if(value == null) {
          //automatically remove dependency
          currentValue.removeDepenency(this);
          if(!field.isFinal) {
            field.setField(component, null);
          }
          return;
        }
      }
      if(value == null) {
        if(!field.isFinal) {
          //TODO: consider to pool unused class instances.
          field.setField(component, null);
        }
        return;
      }
      if(value is String || value is num) {
        if(!field.isFinal) {
          field.setField(component, value);
        }
        return;
      }

      if(currentValue == null) {
        if(value.runtimeType == Vector2) {
          currentValue = new Vector2.copy(value);
        } else if(value.runtimeType == Vector3) {
          currentValue = new Vector3.copy(value);
        } else if(value.runtimeType == Vector4) {
          currentValue = new Vector4.copy(value);
        } else if(value.runtimeType == Aabb3) {
          currentValue = new Aabb3.copy(value);
        } else if(value.runtimeType == Quaternion) {
          currentValue = new Quaternion.copy(value);
        } else if(value.runtimeType == Matrix4) {
          currentValue = new Matrix4.copy(value);
        }
        /*
        switch(value.runtimeType) {
          case(Vector2):
            currentValue = new Vector2.copy(value);
            break;
          case(Vector3):
            currentValue = new Vector3.copy(value);
            break;
          case(Vector4):
            currentValue = new Vector4.copy(value);
            break;
          case(Aabb3):
            currentValue = new Aabb3.copy(value);
            break;
          case(Quaternion):
            currentValue = new Quaternion.copy(value);
            break;
        }*/
        field.setField(component, currentValue);
        return;
      }
      final currentValueType = currentValue.runtimeType;
      if(value.runtimeType == Vector2) {
        (currentValue as Vector2).setFrom(value);
      } else if(value.runtimeType == Vector3) {
        (currentValue as Vector3).setFrom(value);
      } else if(value.runtimeType == Vector4) {
        (currentValue as Vector4).setFrom(value);
      } else if(value.runtimeType == Aabb3) {
        (currentValue as Aabb3).copyFrom(value);
      } else if(value.runtimeType == Quaternion) {
        (currentValue as Quaternion).copyFrom(value);
      } else if(value.runtimeType == Matrix4) {
        (currentValue as Matrix4).setFrom(value);
      }
      /*switch(currentValueType) {
        case(Vector2):
          (currentValue as Vector2).setFrom(value);
          break;
        case(Vector3):
          (currentValue as Vector3).setFrom(value);
          break;
        case(Vector4):
          (currentValue as Vector4).setFrom(value);
          break;
        case(Aabb3):
          (currentValue as Aabb3).copyFrom(value);
          break;
        case(Quaternion):
          (currentValue as Quaternion).copyFrom(value);
          break;
      }*/
    });
    return component;
  }

  /// Encodes given List of Components
  Map encode(List<Component> components) {
    final length = components.length;
    final map = {};

    getDataInt(mist.FieldInfo field, List<Component> components) {
      final l = [];
      for(int i=0; i < length; i++) {
        final int data = field.getField(components[i]);
        if(data == null) {
          l.add(0);
        } else {
          l.add(data);
        }
      }
      return l;
    }
    getDataDouble(mist.FieldInfo field, List<Component> components) {
      final l = [];
      for(int i=0; i < length; i++) {
        final double data = field.getField(components[i]);
        if(data == null) {
          l.add(0.0);
        } else {
          l.add(data);
        }
      }
      return l;
    }
    getDataString(mist.FieldInfo field, List<Component> components) {
      final l = [];
      for(int i=0; i < length; i++) {
        final String data = field.getField(components[i]);
        if(data == null) {
          l.add('');
        } else {
          l.add(data);
        }
      }
      return l;
    }

    _serialize.forEach((field, seralize) {
      var list;
      switch(seralize.type) {/*

        case(SerializeType.float32):
          list = encodeFloat32(getDataDouble(field,components));
        break;
        case(SerializeType.uInt8):
          list = encodeUint8(getDataInt(field,components));
        break;
        case(SerializeType.uInt16):
          list = encodeUint16(getDataInt(field,components));
        break;
        case(SerializeType.uInt32):
          list = encodeUint32(getDataInt(field,components));
        break;
        case(SerializeType.int16):
          list = encodeInt16(getDataInt(field,components));
        break;
        case(SerializeType.int32):
          list = encodeInt32(getDataInt(field,components));
        break;
        case(SerializeType.int):
          list = encodeInt64(getDataInt(field,components));
        break;
        case(SerializeType.object):
          list = encodeUint32(getDataInt(field,components));
        break;
        case(SerializeType.string):
          list = getDataString(field,components);*/
      }
      final fieldName = seralize.customName != null ? seralize.customName : field.fieldName;
      map[fieldName] = list;
    });
    return map;
  }

  /// Sets the data of [components] with [componentsData] with a map
  /// with [objects] that some fields might need.
  void decode(List<Component> components, Map<String,dynamic> componentsData, Map<int, dynamic> objects) {
    final length = components.length;
    for(var name in componentsData.keys) {
    	//print(name);
    }


    _serialize.forEach((field, seralize) {
      final fieldName = seralize.customName != null ? seralize.customName : field.fieldName;
      var rawData = componentsData[fieldName];
      //print(rawData);
      //print('lookup $fieldName, exist? ${rawData != null}');
      //print(componentsData);
      List list;
      if(rawData is List) {
      	list = rawData;
      	//print(rawData);
      }
      final type = seralize.type;
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
      	case(SerializeType.vec2):
          decodeVector2(field,components,rawData);
      	return;
      	case(SerializeType.vec3):
          decodeVector3(field,components,rawData);
      	return;
      	case(SerializeType.vec4):
          decodeVector4(field,components,rawData);
      	return;
      	case(SerializeType.quat):
          decodeQuaternion(field,components,rawData);
      	return;
        case(SerializeType.object):
          list = decodeUint32(rawData);
	        for(int i=0; i < length; i++) {
	          int objId = list[i];
	          if(objId == 0) {
	            field.setField(components[i], null);
	          } else {
	            field.setField(components[i], objects[objId]);
	          }
	        }
       	return;
        case(SerializeType.asset):
          list = decodeUint32(rawData);
	        for(int i=0; i < length; i++) {
	          int objId = list[i];
	          if(objId == 0) {
	            field.setField(components[i], null);
	          } else {
	          	final Asset asset = objects[objId] as Asset;
	          	final comp = components[i];
	          	asset.dependsOnThis(comp);
	          	comp._componentAssets.add(asset);
	            field.setField(comp, asset);
	          }
	        }
	      return;
        default:
        	//TODO:try to guess the type..
        	break;
      }

      for(int i=0; i < length; i++) {
        field.setField(components[i], list[i]);
      }
    });
  }
}
void decodeVector2(final mist.FieldInfo field, List<Component> components, var rawData) {
	if(rawData is String) {
		rawData = decodeFloat32(rawData);
	}
	int r = 0;
	final length = components.length;
  for(int i=0; i < length; i++) {
  	final comp = components[i];
  	final value = field.getField(comp);
  	if(value == null) {
  		if(!field.isFinal) {
  			field.setField(comp, new Vector2(rawData[r],rawData[r+1]));
  		}
  	} else {
  		value[0] = rawData[r];
  		value[1] = rawData[r+1];
  	}
  	r += 2;
  }

}
void decodeVector3(final mist.FieldInfo field, List<Component> components, var rawData) {
	if(rawData is String) {
		rawData = decodeFloat32(rawData);
	}
	int r = 0;
	final length = components.length;
  for(int i=0; i < length; i++) {
  	final comp = components[i];
  	final value = field.getField(comp);
  	if(value == null) {
  		if(!field.isFinal) {
  			field.setField(comp, new Vector3(rawData[r],rawData[r+1],rawData[r+2]));
  		}
  	} else {
  		value[0] = rawData[r];
  		value[1] = rawData[r+1];
  		value[2] = rawData[r+2];
  	}
  	r += 3;
  }

}
void decodeVector4(final mist.FieldInfo field, List<Component> components, var rawData) {
	if(rawData is String) {
		rawData = decodeFloat32(rawData);
	}
	int r = 0;
	final length = components.length;
  for(int i=0; i < length; i++) {
  	final comp = components[i];
  	final value = field.getField(comp);
  	if(value == null) {
  		if(!field.isFinal) {
  			final vec4 = new Vector4(rawData[r],rawData[r+1],rawData[r+2],rawData[r+3]);

  			field.setField(comp, vec4);
  		}
  	} else {
  		value[0] = rawData[r];
  		value[1] = rawData[r+1];
  		value[2] = rawData[r+2];
  		value[3] = rawData[r+3];
  	}
  	r += 4;
  }

}

void decodeQuaternion(final mist.FieldInfo field, List<Component> components, var rawData) {
	if(rawData is String) {
		rawData = decodeFloat32(rawData);
	}
	int r = 0;
	final length = components.length;
  for(int i=0; i < length; i++) {
  	final comp = components[i];
  	final value = field.getField(comp);
  	if(value == null) {
  		if(!field.isFinal) {
  			field.setField(comp, new Quaternion(rawData[r],rawData[r+1],rawData[r+2],rawData[r+3]));
  		}
  	} else {
  		value[0] = rawData[r];
  		value[1] = rawData[r+1];
  		value[2] = rawData[r+2];
  		value[3] = rawData[r+3];
  	}
  	r += 4;
  }

}


