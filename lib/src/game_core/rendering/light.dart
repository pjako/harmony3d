part of game_core;


class Enum {
  const Enum();

  static Enum decode(int value) {}
  static int encode(int value) {}
}

class LightType extends Enum {
  final int _value;
  const LightType(this._value);

  static const point = const LightType(0);
  static const spot = const LightType(1);
  static const directional = const LightType(2);
  static const ambient = const LightType(3);
}

class Light extends Component {
  final LightParameters _parameters = new LightParameters();
  LightType _lightType;
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
  double range;
  double intensity;
  Vector3 color;
  bool shadows;
  Sphere sphere;

  void _init() {
    if(_lightType == LightType.directional) {
      gameObject.scene._globalDirectionalLights.add(this);
    }

  }


  void transformChanged() {

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
    if(transformChanged == false) return;
    //transformChanged = false;
  }




}