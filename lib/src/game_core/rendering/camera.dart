part of game_core;
const double ANG2RAD = 3.14159265358979323846/180.0;

class FrustumPoints {
  final Vector3 p0 = new Vector3.zero(),
                p1 = new Vector3.zero(),
                p2 = new Vector3.zero(),
                p3 = new Vector3.zero(),
                p4 = new Vector3.zero(),
                p5 = new Vector3.zero(),
                p6 = new Vector3.zero(),
                p7 = new Vector3.zero();
  FrustumPoints();
}


class Camera extends Component {
  static Camera _current;
  static Camera get current => _current;
  final Frustum _frustum = new Frustum();

  final Vector4 backgroundColor = new Vector4(1.0,1.0,1.0,1.0);
  final Matrix4 _projectionMatrix = new Matrix4.zero();
  final Matrix4 _viewProjectionMatrix = new Matrix4.zero();
  final Matrix4 _viewMatrix = new Matrix4.zero();
  Float32x4List _simdProjectionMatrix;
  Float32x4List _simdViewProjectionMatrix;

  double _zNear = 1.01;
  double get zNear => _zNear;
  double _zFar = 1000.0;
  double get zFar => _zFar;
  void set zFar(double val) {
    _zFar = val;
  }
  double _aspectRatio = 1.7777778;
  double get aspectRatio => _aspectRatio;
  double _fov = 0.45;
  double get fov => _fov;

  double _viewOffsetX = 0.0, _viewOffsetY = 0.0;
  double _recipViewWindowX = 1.0 / 1.0;
  double _recipViewWindowY = 1.0 / 1.0;


  bool _isPerspective = true;
  bool _active;
  bool get active => _active;
  void set active(bool val) {
    _active = val;
    _current = this;
  }

  Camera() {
    _aspectRatio = Screen.width / Screen.height;
    _simdProjectionMatrix = new Float32x4List.view(_projectionMatrix.storage.buffer);
    _simdViewProjectionMatrix = new Float32x4List.view(_viewProjectionMatrix.storage.buffer);

  }

  void _init() {
    /*if(params != null) {
      _zNear = params[0];
      _zFar = params[1];
      _aspectRatio = params[2];
      _fov = params[3];
    }*/
    backgroundColor.setValues(0.3, 0.3, 0.3, 1.0);
    gameObject._camera = this;
    _updateProjection();
    if(_current == null) {
      _current = this;
    }
    //RenderManager._current._registerCamera(this);

  }

  bool _free() {
    if(_current == null) {
      _current = null;
    }
    return true;
  }

  bool getViewportPointToRay(Vector2 point, Ray result) {
    var mat = _internalViewProjection;
    bool test = pickRay(_internalViewProjection, 0, Screen.width, 0, Screen.height, point.x, point.y, result.origin, result.direction);
    result.direction.sub(result.origin);
    return test;
  }




  Matrix4 get _internalViewProjection {
    return _updateViewProjection();
  }

  Matrix4 _updateViewProjection() {
    //_viewMatrix = transform._worldMat;


    transform._updateWorldMatrix();
    var viewMat = _viewMatrix;//transform._worldMat;//setViewMatrixFromPosRot(transform._position,transform._rotation,_viewMatrix);
    transform._worldMat.copyInto(viewMat).invert();
    //transform.position
    //viewMat.storage[12] = -viewMat.storage[12];
    //viewMat.storage[13] = -viewMat.storage[13];
    //viewMat.storage[14] = -viewMat.storage[14];

    if(EngineConfig.useSimd) {
      var viewMat = transform._worldMatrix4;
      var projMat = _simdProjectionMatrix;
      Matrix44SIMDOperations.multiply(_simdViewProjectionMatrix, 0, projMat, 0, viewMat, 0);
    } else {
      calcVP(_viewProjectionMatrix.storage,viewMat.storage,_projectionMatrix.storage);
      //mul44(_viewProjectionMatrix.storage,_projectionMatrix.storage,viewMat.storage);
      //print('[ ${_viewProjectionMatrix.storage[12]}, ${_viewProjectionMatrix.storage[13]}, ${_viewProjectionMatrix.storage[14]} ]');
      //var projMat = _projectionMatrix;
      //projMat.copyInto(_viewProjectionMatrix);
      //viewMat.multiply(_viewProjectionMatrix);
      //_viewProjectionMatrix.multiply(viewMat);
    }
    return _viewProjectionMatrix;

  }

  Matrix4 _updateProjection() {
    setPerspectiveMatrix(_projectionMatrix,_fov, _aspectRatio, _zNear, _zFar);
    return _projectionMatrix;
  }

  Matrix4 get projectionMatrix {
    return makePerspectiveMatrix(_fov, _aspectRatio, _zNear, _zFar);
  }

  Matrix4 get viewMatrix {
    return gameObject.transform._getWorldTransform().clone();
  }

  static final FrustumPoints _frustumPoints = new FrustumPoints();

  Aabb3 getWorldFrustumBounds(Aabb3 out, double farClip) {
    var frustumPoints = getFrustumPoints(_frustumPoints,farClip);
    double minX = frustumPoints.p0.storage[0];
    double minY = frustumPoints.p0.storage[1];
    double minZ = frustumPoints.p0.storage[2];
    double maxX = minX;
    double maxY = minY;
    double maxZ = minZ;
    compare(Vector3 comparePoint) {
      double pX = comparePoint.storage[0];
      double pY = comparePoint.storage[1];
      double pZ = comparePoint.storage[2];
      if (minX > pX) {
        minX = pX;
      } else if (maxX < pX) {
        maxX = pX;
      }
      if (minY > pY) {
        minY = pY;
      } else if (maxY < pY) {
        maxY = pY;
      }
      if (minZ > pZ) {
        minZ = pZ;
      } else if (maxZ < pZ) {
        maxZ = pZ;
      }
    }

    compare(frustumPoints.p1);
    compare(frustumPoints.p2);
    compare(frustumPoints.p3);
    compare(frustumPoints.p4);
    compare(frustumPoints.p5);
    compare(frustumPoints.p6);
    compare(frustumPoints.p7);

    out.min.storage[0] = minX;
    out.min.storage[1] = minY;
    out.min.storage[2] = minZ;

    out.max.storage[0] = maxX;
    out.max.storage[1] = maxY;
    out.max.storage[2] = maxZ;

    return out;
  }

  void _prepareForRendering() {
    _updateViewProjection();
  }

  Aabb3 getBounds(Aabb3 out) {

  }
  Aabb3 get bounds => getBounds(new Aabb3());



  Aabb3 getWorldBounds(Aabb3 out) {

  }
  Aabb3 get worldBounds => getWorldBounds(new Aabb3());





  void _frustumBoundCalculation() {
    var mvp = _viewProjectionMatrix;
    _FrustumPlanes frustumPlanes = new _FrustumPlanes();
    double mvp0 = mvp[0];
    double mvp1 = mvp[1];
    double mvp2 = mvp[2];
    double mvp3 = mvp[3];
    double mvp4 = mvp[4];
    double mvp5 = mvp[5];
    double mvp6 = mvp[6];
    double mvp7 = mvp[7];
    double mvp8 = mvp[8];
    double mvp9 = mvp[9];
    double mvp10 = mvp[10];
    double mvp11 = mvp[11];
    double mvp12 = mvp[12];
    double mvp13 = mvp[13];
    double mvp14 = mvp[14];
    double mvp15 = mvp[15];
    frustumPlanes.right.setFromComponents(mvp3-mvp0, mvp7-mvp4, mvp11-mvp8, mvp15-mvp12);
    frustumPlanes.left.setFromComponents(mvp3+mvp0, mvp7+mvp4, mvp11+mvp8, mvp15+mvp12);

    frustumPlanes.bottom.setFromComponents(mvp3+mvp1, mvp7+mvp5, mvp11+mvp9, mvp15+mvp13);
    frustumPlanes.top.setFromComponents(mvp3-mvp1, mvp7-mvp5, mvp11-mvp9, mvp15-mvp13);

    frustumPlanes.far.setFromComponents(mvp3-mvp2, mvp7-mvp6, mvp11-mvp10, mvp15-mvp14);
    frustumPlanes.near.setFromComponents(mvp3+mvp2, mvp7+mvp6, mvp11+mvp10, mvp15+mvp14);


    //Debug.drawCross(frustumPlanes.far., Debug._debugColor);

  }

  FrustumPoints getFrustumPoints(FrustumPoints frustumPoints, [double farClip]) {
    if(farClip == null) {
      farClip = _zFar;//this.farPlane;
    }


    var viewOffsetX = _viewOffsetX;
    var viewOffsetY = _viewOffsetY;

    var viewWindowX = 1.0 / _recipViewWindowX;
    var viewWindowY = 1.0 / (_recipViewWindowY * _aspectRatio);


    // this is 4x3 but we only have Pos + quaternion...
    //var transform = this.matrix;

    //var farClip  = farPlane || this.farPlane;

    var nearClip = _zNear;

    //var frustumPoints = [];
    Quaternion quat = transform.localRotation;
    Vector3 pos = transform.position;

    if (!_isPerspective) {
    } else {

      var nearTr = frustumPoints.p0;
      var nearTl = frustumPoints.p1;
      var nearBl = frustumPoints.p2;
      var nearBr = frustumPoints.p3;
      var farTl = frustumPoints.p4;
      var farTr = frustumPoints.p5;
      var farBl = frustumPoints.p6;
      var farBr = frustumPoints.p7;

      var far = zFar * 0.5;

      double nearZ =  - nearClip;
      double farZ = - farClip;

      var near = zNear;

      double viewWindowXNear = near * viewWindowX;

      double nearTlX = viewWindowXNear;
      double nearTrX = - viewWindowXNear;
      double nearBlX = - viewWindowXNear;
      double nearBrX = viewWindowXNear;


      double viewWindowYNear = near * viewWindowY;


      double nearTlY = viewWindowYNear;
      double nearTrY = viewWindowYNear;
      double nearBlY = - viewWindowYNear;
      double nearBrY = - viewWindowYNear;


      double viewWindowXFar = far * viewWindowX;

      double farTlX = viewWindowXFar;
      double farTrX = - viewWindowXFar;
      double farBlX = - viewWindowXFar;
      double farBrX = viewWindowXFar;


      double viewWindowYFar = far * viewWindowY;

      double farTlY = viewWindowYFar;
      double farTrY = viewWindowYFar;
      double farBlY = - viewWindowYFar;
      double farBrY = - viewWindowYFar;


      nearTr.setValues(nearTlX, nearTlY, nearZ);
      nearTl.setValues(nearTrX, nearTrY, nearZ);

      nearBl.setValues(nearBlX, nearBlY, nearZ);
      nearBr.setValues(nearBrX, nearBrY, nearZ);

      transform.transformPointToWorld(nearTr);
      transform.transformPointToWorld(nearTl);
      transform.transformPointToWorld(nearBl);
      transform.transformPointToWorld(nearBr);

      Debug.drawLine(nearTr, nearTl, Debug._debugColor);
      Debug.drawLine(nearBl, nearBr, Debug._debugColor);
      Debug.drawLine(nearTl, nearBl, Debug._debugColor);
      Debug.drawLine(nearTr, nearBr, Debug._debugColor);

      farTl.setValues(farTlX, farTlY, farZ);
      farTr.setValues(farTrX, farTrY, farZ);

      farBl.setValues(farBlX, farBlY, farZ);
      farBr.setValues(farBrX, farBrY, farZ);

      transform.transformPointToWorld(farTl);
      transform.transformPointToWorld(farTr);
      transform.transformPointToWorld(farBl);
      transform.transformPointToWorld(farBr);

      //Debug.drawLine(farTl, new Vector3.zero(), new Vector4(1.0,1.0,0.0,1.0));
      //Debug.drawLine(nearTl, new Vector3.zero(), new Vector4(1.0,1.0,0.0,1.0));

      Debug.drawLine(farTl, farTr, Debug._debugColor);
      Debug.drawLine(farBl, farBr, Debug._debugColor);

      Debug.drawLine(nearTr, farTl, Debug._debugColor);
      Debug.drawLine(nearBl, farBl, Debug._debugColor);
      Debug.drawLine(nearTl, farTr, Debug._debugColor);
      Debug.drawLine(nearBr, farBr, Debug._debugColor);

    }

    return frustumPoints;
  }

  _FrustumPlanes _getPlanes(_FrustumPlanes planes) {
   var m = _internalViewProjection;
   var m0 = m.storage[0];
   var m1 = m.storage[1];
   var m2 = m.storage[2];
   var m3 = m.storage[3];
   var m4 = m.storage[4];
   var m5 = m.storage[5];
   var m6 = m.storage[6];
   var m7 = m.storage[7];
   var m8 = m.storage[8];
   var m9 = m.storage[9];
   var m10 = m.storage[10];
   var m11 = m.storage[11];
   var m12 = m.storage[12];
   var m13 = m.storage[13];
   var m14 = m.storage[14];
   var m15 = m.storage[15];

   // Negate 'constant' here to avoid doing it on the isVisible functions
   _normalizePlane((m3 + m0), (m7 + m4), (m11 + m8), -(m15 + m12), planes.left); // left
   _normalizePlane((m3 - m0), (m7 - m4), (m11 - m8), -(m15 - m12), planes.right); // right
   _normalizePlane((m3 - m1), (m7 - m5), (m11 - m9), -(m15 - m13), planes.top); // top
   _normalizePlane((m3 + m1), (m7 + m5), (m11 + m9), -(m15 + m13), planes.bottom); // bottom
   _normalizePlane((m3 - m2), (m7 - m6), (m11 - m10), -(m15 - m14), planes.far); // far
   _normalizePlane((m3 + m2), (m7 + m6), (m11 + m10), -(m15 + m14), planes.near);  // near

   return planes;
  }

  Plane _normalizePlane(double x, double y, double z, double constant, Plane plane) {
    Vector3 normal = plane.normal;
    //double x = normal.x;
    //double y = normal.y;
    //double z = normal.z;
    //double constant = plane.constant;
    var lsq = ((x * x) + (y * y) + (z * z));
    if (lsq > 0.0) {
      var lr = 1.0 / sqrt(lsq);
      normal.storage[0] = (x * lr);
      normal.storage[1] = (y * lr);
      normal.storage[2] = (z * lr);
      plane.constant = (constant * lr);
      //normal.storage[3] = (constant * lr);
    } else {
      normal.storage[0] = 0.0;
      normal.storage[1] = 0.0;
      normal.storage[2] = 0.0;
      plane.constant = 0.0;
    }

    return plane;
  }

  void debugDrawFrustum() {
  }
}


Float32List calcVP(Float32List outVP, Float32List viewMatrix, Float32List perspectiveMatrix) {
  final lm00 = viewMatrix[0];
  final lm01 = viewMatrix[1];
  final lm02 = viewMatrix[2];
  final lm10 = viewMatrix[4];
  final lm11 = viewMatrix[5];
  final lm12 = viewMatrix[6];
  final lm20 = viewMatrix[8];
  final lm21 = viewMatrix[9];
  final lm22 = viewMatrix[10];
  final lm30 = viewMatrix[12];
  final lm31 = viewMatrix[13];
  final lm32 = viewMatrix[14];

  //00 02 11 12 22 23 32
  final a00 = perspectiveMatrix[0];
  final a02 = perspectiveMatrix[2];
  final a11 = perspectiveMatrix[5];
  final a12 = perspectiveMatrix[6];
  final a22 = perspectiveMatrix[10];
  final a23 = perspectiveMatrix[11];
  final a32 = perspectiveMatrix[14];

  outVP[0] = lm00*a00;
  outVP[1] = lm01*a11;
  outVP[2] = lm00*a02 + lm01*a12 + lm02*a22;
  outVP[3] = lm02*a23;


  outVP[4] = lm10*a00;
  outVP[5] = lm11*a11;
  outVP[6] = lm10*a02 + lm11*a12 + lm12*a22;
  outVP[7] = lm12*a23;

  outVP[8] = lm20*a00;
  outVP[9] = lm21*a11;
  outVP[10] = lm20*a02 + lm21*a12 + lm22*a22;
  outVP[11] = lm22*a23;

  outVP[12] = lm30*a00;
  outVP[13] = lm31*a11;
  outVP[14] = lm30*a02;// + lm31*a12 + lm32*a22 + a32;
  outVP[15] = lm32*a23;
}


void mul44(Float32List out, Float32List a, Float32List b) {
  var a00 = a[0], a01 = a[1], a02 = a[2], a03 = a[3],
      a10 = a[4], a11 = a[5], a12 = a[6], a13 = a[7],
      a20 = a[8], a21 = a[9], a22 = a[10], a23 = a[11],
      a30 = a[12], a31 = a[13], a32 = a[14], a33 = a[15];

  var b0  = b[0], b1 = b[1], b2 = b[2], b3 = b[3];
  out[0] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
  out[1] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
  out[2] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
  out[3] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

  b0 = b[4]; b1 = b[5]; b2 = b[6]; b3 = b[7];
  out[4] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
  out[5] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
  out[6] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
  out[7] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

  b0 = b[8]; b1 = b[9]; b2 = b[10]; b3 = b[11];
  out[8] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
  out[9] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
  out[10] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
  out[11] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

  b0 = b[12]; b1 = b[13]; b2 = b[14]; b3 = b[15];
  out[12] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
  out[13] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
  out[14] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
  out[15] = b0*a03 + b1*a13 + b2*a23 + b3*a33;
}

