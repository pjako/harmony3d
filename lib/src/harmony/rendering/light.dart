part of harmony;
class LightType {
  final int _value;
  const LightType(this._value);

  static const point = const LightType(0);
  static const spot = const LightType(1);
  static const directional = const LightType(2);
  static const ambient = const LightType(3);
}
/// A physical light. Spot-, Point- or Directionallight
class Light extends Component {
  //final LightParameters _parameters = new LightParameters();
  LightType _lightType;

  /// Lighttype of this light
  LightType get lightType => _lightType;
  void set lightType(LightType val) {
    if(_lightType == LightType.directional) {
      if(val == LightType.directional) return;
      gameObject.scene._globalDirectionalLights.remove(this);
    }
    _lightType = val;
    if(val == LightType.directional) {
      gameObject.scene._globalDirectionalLights.add(this);
    }
  }

  /// Range of this light
  double range;
  /// Intensity of this Light
  double intensity;
  /// Light color
  Vector3 color;
  /// Does this light cast shadows?
  bool shadows;

  Sphere sphere;

  void _init() {
    if(_lightType == LightType.directional) {
      gameObject.scene._globalDirectionalLights.add(this);
    }

  }

  bool containsAabb3(Aabb3 aabb3) {
  }
  bool intersectsFrustum(Frustum frustum) {
    switch(lightType) {
      case(LightType.point):
        return frustum.intersectsWithSphere(sphere);
    }
    return false;
  }



  bool _intersectsAabb3(Aabb3 other) {
    _updateBounds();
    switch(lightType) {
      case(LightType.point):
        return other.containsSphere(sphere);
    }
  }
  bool _intersectsFrustum(Frustum other) {
    _updateBounds();
    if(lightType == LightType.point) {
      return other.intersectsWithSphere(sphere);
    }
    switch(lightType) {
      case(LightType.point):
        return other.intersectsWithSphere(sphere);
    }
  }

  void _updateBounds() {
    //if(transformChanged == false) return;
    //transformChanged = false;
  }




}