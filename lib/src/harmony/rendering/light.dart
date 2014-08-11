part of harmony;

class LightType {
  final int _value;
  const LightType(this._value);

  static const point = const LightType(0);
  static const spot = const LightType(1);
  static const directional = const LightType(2);
  static const ambient = const LightType(3);
}

class Light extends Component {




  //final LightParameters _parameters = new LightParameters();
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


  void updateWorldExtents() {/*
  	var world;
    var worldExtents = this.worldExtents;
    var light = this.light;

    var m0 = world[0];
    var m1 = world[1];
    var m2 = world[2];
    var m3 = world[3];
    var m4 = world[4];
    var m5 = world[5];
    var m6 = world[6];
    var m7 = world[7];
    var m8 = world[8];

    var ct0 = world[9];
    var ct1 = world[10];
    var ct2 = world[11];

    switch(light.lightType) {
    	case(LightType.spot) {

    	}
    }

    if (light.spot) {
      var minX, minY, minZ, maxX, maxY, maxZ, pX, pY, pZ;
      minX = ct0;
      minY = ct1;
      minZ = ct2;
      maxX = ct0;
      maxY = ct1;
      maxZ = ct2;

      //var transform = md.m33MulM43(light.frustum, world);
      //var p0 = md.m43TransformPoint(transform, md.v3Build(-1, -1, 1));
      //var p1 = md.m43TransformPoint(transform, md.v3Build(1, -1, 1));
      //var p2 = md.m43TransformPoint(transform, md.v3Build(-1, 1, 1));
      //var p3 = md.m43TransformPoint(transform, md.v3Build(1, 1, 1));
      var f = light.frustum;
      var f0 = f[0];
      var f1 = f[1];
      var f2 = f[2];
      var f3 = f[3];
      var f4 = f[4];
      var f5 = f[5];
      var f6 = f[6];
      var f7 = f[7];
      var f8 = f[8];

      ct0 += (m0 * f6 + m3 * f7 + m6 * f8);
      ct1 += (m1 * f6 + m4 * f7 + m7 * f8);
      ct2 += (m2 * f6 + m5 * f7 + m8 * f8);

      var abs = Math.abs;
      var d0 = (abs(m0 * f0 + m3 * f1 + m6 * f2) + abs(m0 * f3 + m3 * f4 + m6 * f5));
      var d1 = (abs(m1 * f0 + m4 * f1 + m7 * f2) + abs(m1 * f3 + m4 * f4 + m7 * f5));
      var d2 = (abs(m2 * f0 + m5 * f1 + m8 * f2) + abs(m2 * f3 + m5 * f4 + m8 * f5));
      pX = (ct0 - d0);
      pY = (ct1 - d1);
      pZ = (ct2 - d2);
      if (minX > pX)
      {
          minX = pX;
      }
      if (minY > pY)
      {
          minY = pY;
      }
      if (minZ > pZ)
      {
          minZ = pZ;
      }

      pX = (ct0 + d0);
      pY = (ct1 + d1);
      pZ = (ct2 + d2);
      if (maxX < pX)
      {
          maxX = pX;
      }
      if (maxY < pY)
      {
          maxY = pY;
      }
      if (maxZ < pZ)
      {
          maxZ = pZ;
      }

      worldExtents[0] = minX;
      worldExtents[1] = minY;
      worldExtents[2] = minZ;
      worldExtents[3] = maxX;
      worldExtents[4] = maxY;
      worldExtents[5] = maxZ;
    } else {
        var center = light.center;
        var halfExtents = light.halfExtents;

        if (center)
        {
            var c0 = center[0];
            var c1 = center[1];
            var c2 = center[2];
            ct0 += (m0 * c0 + m3 * c1 + m6 * c2);
            ct1 += (m1 * c0 + m4 * c1 + m7 * c2);
            ct2 += (m2 * c0 + m5 * c1 + m8 * c2);
        }

        var h0 = halfExtents[0];
        var h1 = halfExtents[1];
        var h2 = halfExtents[2];
        var ht0 = ((m0 < 0 ? -m0 : m0) * h0 + (m3 < 0 ? -m3 : m3) * h1 + (m6 < 0 ? -m6 : m6) * h2);
        var ht1 = ((m1 < 0 ? -m1 : m1) * h0 + (m4 < 0 ? -m4 : m4) * h1 + (m7 < 0 ? -m7 : m7) * h2);
        var ht2 = ((m2 < 0 ? -m2 : m2) * h0 + (m5 < 0 ? -m5 : m5) * h1 + (m8 < 0 ? -m8 : m8) * h2);

        worldExtents[0] = (ct0 - ht0);
        worldExtents[1] = (ct1 - ht1);
        worldExtents[2] = (ct2 - ht2);
        worldExtents[3] = (ct0 + ht0);
        worldExtents[4] = (ct1 + ht1);
        worldExtents[5] = (ct2 + ht2);
    }*/
  }




}