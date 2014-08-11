part of harmony;

var sl = [const Serialize(SerializeType.vec3, customName: 'positions')];


class Transform extends Component {
  static const int dirty = 1;
  /// Positon Rotation or Scale of transform or parent transform is not zero
  static const int nonZero = 2;
  static const int posRotScaleDirty = 4;

  int _transformFlag = 0;

  @mist.Ignore()
  final Float32List _cachedLocalMatrix;
  @mist.Ignore()
  final Float32x4List _cachedLocalMatrix4;

  @mist.Ignore()
  final Matrix4 _worldMat;
  @mist.Ignore()
  final Float32List _worldMatrix;
  @mist.Ignore()
  final Float32x4List _worldMatrix4;

  @mist.Ignore()
  final Float32List _posrotscale;
  @mist.Ignore()
  final Float32x4 _localPosition4;
  @mist.Ignore()
  final Float32x4 _localRotation4;
  @mist.Ignore()
  final Float32x4 _localScale4;

  @Serialize(SerializeType.vec3, customName: 'positions')
  final Vector3 _localPosition;
  @Serialize(SerializeType.quat, customName: 'rotations')
  final Quaternion _localRotation;
  @Serialize(SerializeType.vec3, customName: 'scales')
  final Vector3 _localScale;

  factory Transform() {
    final posrotscale = new Float32List(12);
    final localPosition_ = new Vector3.fromBuffer(posrotscale.buffer, 0);
    final localRotation_ = new Quaternion.fromBuffer(posrotscale.buffer, 4*4);
    final localScale_ = new Vector3.fromBuffer(posrotscale.buffer, 4*8);
    localScale_.setValues(1.0, 1.0, 1.0);
    localRotation_.w = 1.0;

    final worldTransform = new Float32List(16);
    final localTransform = new Float32List(16);
    //These value (in world- & localTransform)  should be never changed and math operation are optimized on this assumption
    // [3] = 0.0
    // [7] = 0.0
    // [11] = 0.0
    // [15] = 1.0
    worldTransform[15] = localTransform[15] = 1.0;


    // SIMD Stuff
    final simdprs = new Float32x4List.view(posrotscale.buffer);
    final lmat4 = new Float32x4List.view(localTransform.buffer);
    final wmat4 = new Float32x4List.view(worldTransform.buffer);
    final worldMat = new Matrix4.fromFloat32List(worldTransform);

    var trans = new Transform._internal(
        posrotscale,
        localPosition_,localRotation_,localScale_,
        simdprs[0],simdprs[1],simdprs[2],
        localTransform,lmat4,
        worldTransform,wmat4,worldMat);
    //

    return trans;

  }
  Transform._internal(
      this._posrotscale,
      this._localPosition, this._localRotation, this._localScale,
      this._localPosition4, this._localRotation4, this._localScale4,
      this._cachedLocalMatrix, this._cachedLocalMatrix4,
      this._worldMatrix, this._worldMatrix4, this._worldMat);
  @mist.Ignore()
  void _setDirty() {
    gameObject.children.forEach((g){
      g.transform._parentChanged();
    });
    _transformFlag = _transformFlag | dirty;
  }
  @mist.Ignore()
  void _parentChanged() {
    _setDirty();
    gameObject.children.forEach((e) {
      e.transform._parentChanged();
    });
  }

  @mist.Ignore()
  void _preInit() {
    if(gameObject._transform != null) {
      throw "Only one Transform per GameObject is allowed";
    }
    gameObject._transform = this;
  }
  @mist.Ignore()
  void _init() {
    _transformFlag = (dirty+posRotScaleDirty+nonZero);
    var parent = gameObject.parent;
    if(parent != null) {
      if(parent.transform._transformFlag & Transform.nonZero == 0) {
        return;
      }
    }
    if(_localPosition.x != 0.0) return;
    if(_localPosition.y != 0.0) return;
    if(_localPosition.z != 0.0) return;
    if(_localRotation.x != 0.0) return;
    if(_localRotation.y != 0.0) return;
    if(_localRotation.z != 0.0) return;
    if(_localRotation.w != 1.0) return;
    if(_localScale.x != 1.0) return;
    if(_localScale.y != 1.0) return;
    if(_localScale.z != 1.0) return;
    // This enables extra optimizations!
    _transformFlag -= Transform.nonZero;
  }
  @mist.Ignore()
  void onReset() {
    _localPosition.setZero();
    _localRotation.x = 0.0;
    _localRotation.y = 0.0;
    _localRotation.z = 0.0;
    _localRotation.w = 1.0;
    _localScale.x = 0.0;
    _localScale.y = 0.0;
    _localScale.z = 0.0;
  }


  /** Translates this transform by [delta]
   */
  @mist.Ignore()
  void translate(Vector3 delta) {
    _localPosition.add(delta);
    _setDirty();
  }

  @mist.Ignore()
  void scaleBy(double value) {
    _transformFlag |= (dirty+posRotScaleDirty);
    _localScale.setValues(value, value, value);
  }

  /**
   * Change the world translation
   */
  set position(Vector3 pos) {
    var parent = gameObject.parent;
    _transformFlag |= (dirty+posRotScaleDirty);
    if(parent != null) {
      Float32List parentMat = parent.transform._worldMatrix;
      _localPosition.storage[0] = pos.storage[0] - parentMat[12];
      _localPosition.storage[1] = pos.storage[1] - parentMat[13];
      _localPosition.storage[2] = pos.storage[2] - parentMat[14];
      return;
    }
    _localPosition.setFrom(pos);
    gameObject.children.forEach((g) {g.transform._parentChanged();});
  }
  /**
   * Change the world translation
   */
  set localPosition(Vector3 pos) {
    _transformFlag |= (dirty+posRotScaleDirty);
    _localPosition.setFrom(pos);
  }

  /**
   * Get the world translation
   */
  Vector3 get position {
    if(this._transformFlag & dirty != 0) _updateWorldMatrix();
    //_worldMat.multiply(arg)
    //return _worldMat.transform3(new Vector3.zero());
    return new Vector3(_worldMatrix[12],_worldMatrix[13],_worldMatrix[14]);
  }
  /*
  Vector3 get _internalPosition {
    _updatePosRotScale();
    return _position;
  }
  Quaternion get _internalRotation {
    _updatePosRotScale();
    return _rotation;
  }*/
  /*
  Vector3 get _internalScale {
    _updatePosRotScale();
    return _scale;
  }
  */


  @mist.Ignore()
  Vector3 getPosition(Vector3 out) {
    if(this._transformFlag & dirty != null) _updateWorldMatrix();
    return out.setValues(_worldMatrix[12],_worldMatrix[13],_worldMatrix[14]);
  }

  /**
   * Get the local translation
   */
  Vector3 get localPosition {
    return _localPosition.clone();
  }
  /**
   * Get the local translation
   */
  @mist.Ignore()
  Vector3 getLocalPosition(Vector3 out) {
    return _localPosition.copyInto(out);
  }

  /**
   * Get the world rotation
   */
  @mist.Ignore()
  Quaternion getRotation(Quaternion out) {
    if(this._transformFlag & dirty != 0) _updateWorldMatrix();
    return quaternionFromMatrix(_worldMat, out);
  }

  /**
   * Get the world rotation
   */
  Quaternion get rotation {
    if(this._transformFlag & dirty != 0) _updateWorldMatrix();
    return quaternionFromMatrix(_worldMat, new Quaternion.identity());
  }

  /**
   * Get the local rotation
   */
  @mist.Ignore()
  Quaternion getLocalRotation(Quaternion out) {
    _localRotation.copyTo(out);
    return out;
  }

  /**
   * Get the local rotation
   */
  Quaternion get localRotation => _localRotation.clone();

  /**
   * Set the world rotation
   */
  void set rotation(Quaternion rot) {
    throw new UnimplementedError();
  }
  /**
   * Set the world rotation
   */
  void set localRotation(Quaternion rot) {
    _transformFlag |= (dirty+posRotScaleDirty);
    _localRotation.copyFrom(rot);
  }
  @mist.Ignore()
  void rotateLocal(Quaternion delta) {
    _transformFlag |= (dirty+posRotScaleDirty);
    double fromX = _localRotation.storage[0];
    double fromY = _localRotation.storage[1];
    double fromZ = _localRotation.storage[2];
    double fromW = _localRotation.storage[3];
    double toX = delta.storage[0];
    double toY = delta.storage[1];
    double toZ = delta.storage[2];
    double toW = delta.storage[3];
    double cosom;

    cosom = fromX * toX + fromY * toY + fromZ * toZ + fromW * toW;

    if ( cosom < 0.0 ) {
      toX = - toX;
      toY = - toY;
      toZ = - toZ;
      toW = - toW;
    }

    _localRotation.storage[0] = fromX + toX;
    _localRotation.storage[1] = fromY + toY;
    _localRotation.storage[2] = fromZ + toZ;
    _localRotation.storage[3] = fromW + toW;
  }


  @mist.Ignore()
  void rotateSlerpLocal(Quaternion delta, double scale) {
    _transformFlag |= (dirty+posRotScaleDirty);
    double fromX = _localRotation.storage[0];
    double fromY = _localRotation.storage[1];
    double fromZ = _localRotation.storage[2];
    double fromW = _localRotation.storage[3];
    double toX = delta.storage[0];
    double toY = delta.storage[1];
    double toZ = delta.storage[2];
    double toW = delta.storage[3];
    double omega, cosom, sinom, scale0, scale1;

    cosom = fromX * toX + fromY * toY + fromZ * toZ + fromW * toW;

    if ( cosom < 0.0 ) {
      cosom = -cosom;
      toX = - toX;
      toY = - toY;
      toZ = - toZ;
      toW = - toW;
    }

    if ( (1.0 - cosom) > 0.001 ) {
      omega = acos(cosom);
      sinom = sin(omega);
      scale0 = sin((1.0 - scale) * omega) / sinom;
      scale1 = sin(scale * omega) / sinom;
    } else {
      scale0 = 1.0 - scale;
      scale1 = scale;
    }

    _localRotation.storage[0] = scale0 * fromX + scale1 * toX;
    _localRotation.storage[1] = scale0 * fromY + scale1 * toY;
    _localRotation.storage[2] = scale0 * fromZ + scale1 * toZ;
    _localRotation.storage[3] = scale0 * fromW + scale1 * toW;
  }


  Vector3 get localEulerAngles => quatToEuler(new Vector3.zero(),_localRotation);



  static final Vector3 _pool0 = new Vector3.zero();
  static final Vector3 _pool1 = new Vector3.zero();
  static final Vector3 _pool2 = new Vector3.zero();
  // TODO: Needs verification if it works



  @mist.Ignore()
  void lookAt(Vector3 focusPoint, Vector3 upVector) {


    Vector3 forward = _pool0;
    Vector3 up = _pool1;
    focusPoint.copyInto(forward);
    upVector.copyInto(up);

    vec3OrthoNormalize(forward,up);
    Vector3 right = _pool2;
    up.crossInto(forward, right);

    double m00 = right.x,
        m01 = up.x,
        m02 = forward.x,
        m10 = right.y,
        m11 = up.y,
        m12 = forward.y,
        m20 = right.z,
        m21 = up.z,
        m22 = forward.z;
    double w = sqrt(1.0 + m00 + m11 + m22) * 0.5;

    //this fixes some cases!
    if(w == 0.0) w = 0.0000001;
    double wRes = 1.0 / (4.0 * w);
    _localRotation.storage[0] = (m21 - m12) * wRes;
    _localRotation.storage[1] = (m02 - m20) * wRes;
    _localRotation.storage[2] = (m10 - m01) * wRes;
    _localRotation.storage[3] = w;
    _localRotation.normalize();
  }
  @mist.Ignore()
  double distanceTo(Transform other) {
    if(other.gameObject.parent == gameObject.parent) {

      double sum;
      double x = _localPosition.storage[0] - other._localPosition.storage[0];
      double y = _localPosition.storage[1] - other._localPosition.storage[1];
      double z = _localPosition.storage[2] - other._localPosition.storage[2];
      sum = (x * x);
      sum += (y * y);
      sum += (z * z);
      return sqrt(sum);

    } else {
      _updateWorldMatrix();
      other._updateWorldMatrix();
      double sum;
      double x = _worldMatrix[12] - other._worldMatrix[12];
      double y = _worldMatrix[13] - other._worldMatrix[13];
      double z = _worldMatrix[14] - other._worldMatrix[14];
      sum = (x * x);
      sum += (y * y);
      sum += (z * z);
      return sqrt(sum);
    }
  }


  @mist.Ignore()
  Vector3 getLeftLocal(Vector3 out) {
    out.storage[0] = 1.0;
    out.storage[1] = 0.0;
    out.storage[2] = 0.0;
    _localRotation.rotate(out);
    return out;
  }
  @mist.Ignore()
  Vector3 getRightLocal(Vector3 out) {
    out.storage[0] = -1.0;
    out.storage[1] = 0.0;
    out.storage[2] = 0.0;
    _localRotation.rotate(out);
    return out;
  }
  @mist.Ignore()
  Vector3 getUpLocal(Vector3 out) {
    out.storage[0] = 0.0;
    out.storage[1] = 1.0;
    out.storage[2] = 0.0;
    _localRotation.rotate(out);
    return out;
  }
  @mist.Ignore()
  Vector3 getForwardLocal(Vector3 out) {
    out.storage[0] = 0.0;
    out.storage[1] = 0.0;
    out.storage[2] = -1.0;
    _localRotation.rotate(out);
    return out;
  }


  Vector3 get right {
    if(_transformFlag & dirty != 0) _updateWorldMatrix();
    return _worldMat.right;
  }

  Vector3 get up {
    if(_transformFlag & dirty != 0) _updateWorldMatrix();
    return _worldMat.up;
  }

  @mist.Ignore()
  void vec3OrthoNormalize( Vector3 normal, Vector3 tangent ) {
    normal.normalize();
    //D3DXVec3Normalize( normal, normal );

    Vector3 proj = normal.scaled(tangent.dot(normal));
    //D3DXVec3Scale( &proj, normal, D3DXVec3Dot( tangent, normal) );

    tangent.sub(proj);
    //D3DXVec3Subtract( tangent, tangent, proj );

    tangent.normalize();
    //D3DXVec3Normalize( tangent, tangent );
  }

  @mist.Ignore()
  Vector3 getEulerAngles(Vector3 euler) {
    var m12 = this._worldMatrix[2]; // m12
    var m31 = this._worldMatrix[8];// 31 -> 6
    var m32 = this._worldMatrix[9];// 32 -> 7
    var m33 = this._worldMatrix[10];// 33 -> 8
    var m22 = this._worldMatrix[5];

    euler.x = -atan2(m32, m22);
    euler.y = atan2(m31, m33);
    euler.z = atan2(m12, m22);
    return euler;

  }


  Vector3 get eulerAngles => getEulerAngles(new Vector3.zero());
  void set eulerAngles(Vector3 euler) {
    _transformFlag |= (dirty+posRotScaleDirty);
    this._localRotation.setEuler(euler.x, euler.y, euler.z);
    if(gameObject.parent == null) return;
    var pTransform = gameObject.parent.transform;
    if(pTransform._transformFlag & Transform.dirty != 0) pTransform._updateWorldMatrix();

    _quatDifference(new Quaternion.fromRotation(pTransform._worldMat.getRotation()),
        _localRotation,
        _localRotation);
  }

  @mist.Ignore()
  Vector3 transformPointToWorld(Vector3 point) {
    return _worldMat.transform3(point);
  }

  @mist.Ignore()
  Aabb3 transformBounds(Aabb3 bounds, Aabb3 out) {
    if(_transformFlag & dirty != 0) _updateWorldMatrix();
    return bounds.transformed(_worldMat, out);
  }

  @mist.Ignore()
  void _updateLocalMatrix() {
    if(_transformFlag & posRotScaleDirty != 0) {

    }
    worldMatrixFromPosRotScale(_cachedLocalMatrix, _posrotscale);

  }
  @mist.Ignore()
  void _updateWorldMatrix() {
    if(_transformFlag & dirty == 0) return;
    _transformFlag -= dirty;
    var parent = gameObject.parent;
    if(parent != null) {
      var pTrans = parent.transform;
      // Transform Position, Rotation is not Zero or Scale is not 1
      //if(pTrans._transformFlag & nonZero != 0) {
      pTrans._updateWorldMatrix();
      /*if(_transformFlag & posRotScaleDirty != 0) {
        _transformFlag -= posRotScaleDirty;

      } else {
        calcWorldMatrix(pTrans._worldMatrix,_cachedLocalMatrix,_worldMatrix,_posrotscale);
        //mul44WorldMatrix(_worldMatrix,pTrans._worldMatrix,_cachedLocalMatrix);
      }*/
      final worldMat = _worldMatrix;
      if(_transformFlag & posRotScaleDirty != 0) {
        worldMatrixFromPosRotScale(worldMat, _posrotscale);
        //calcWorldMatrix(pTrans._worldMatrix,_cachedLocalMatrix,worldMat,_posrotscale);
      }



      for(var par = gameObject.parent; par != null; par = par.parent) {
        final parentTransform = par.transform;
        parentTransform._updateLocalMatrix();
        mul44GM(_worldMatrix,parentTransform._cachedLocalMatrix,_worldMatrix);
      }
      return;
      //}
    }
    if(_transformFlag & posRotScaleDirty != 0) _transformFlag -= posRotScaleDirty;
    worldMatrixFromPosRotScale(_worldMatrix, _posrotscale);
  }
  @mist.Ignore()
  void _updateWorldMatrixSIMD() {
    if(_transformFlag & dirty == 0) return;
    _transformFlag -= dirty;
    var parent = gameObject.parent;
    if(parent != null) {
      var pTrans = parent.transform;
      if(pTrans._transformFlag & nonZero != 0) {
        pTrans._updateWorldMatrix();
        if(_transformFlag & posRotScaleDirty != 0) {
          _transformFlag -= posRotScaleDirty;
          calcWorldMatrix(pTrans._worldMatrix,_cachedLocalMatrix,_worldMatrix,_posrotscale);
        } else {
          calcWorldMatrix(pTrans._worldMatrix,_cachedLocalMatrix,_worldMatrix,_posrotscale);
          //mul44(_worldMatrix,pTrans._worldMatrix,_cachedLocalMatrix);
        }
        return;
      }
    }
    if(_transformFlag & posRotScaleDirty != 0) _transformFlag -= posRotScaleDirty;
    worldMatrixFromPosRotScale(_worldMatrix, _posrotscale);
  }

  String toJson() => '{"position":[${_localPosition.x},${_localPosition.y},${_localPosition.z}],'
    '"rotation":[${_localRotation.x},${_localRotation.y},${_localRotation.z},${_localRotation.w}]}'
    '{"scale":[${_localScale.x},${_localScale.y},${_localScale.z}],';
  Map toMap() => { 'position' : [_localPosition.x,_localPosition.y,_localPosition.z],
    'rotation' : [_localRotation.x,_localRotation.y,_localRotation.z,_localRotation.w],
    'scale' : [_localScale.x,_localScale.y,_localScale.z]};

}


void _simdMultiply(Matrix4 first, Matrix4 second, Matrix4 out) {
  var matrix0 = new Float32x4List.view(first.storage.buffer);
  var matrix1 = new Float32x4List.view(second.storage.buffer);
  var matrixOut = new Float32x4List.view(out.storage.buffer);
  Matrix44SIMDOperations.multiply(matrixOut, 0, matrix0, 0, matrix1, 0);
}


Quaternion quaternionFromMatrix(Matrix4 mat, Quaternion out) {
  Float32List m = mat.storage;
  double m00 = m[0], m01 = m[1], m02 = m[2];
  double m10 = m[4], m11 = m[5], m12 = m[6];
  double m20 = m[8], m21 = m[9], m22 = m[10];
  double trace = 1.0 + m00 + m11 + m22;
  double s = 0.0;
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  double w = 0.0;

  if (trace > double.MIN_POSITIVE) {
    s = sqrt(trace) * 2.0;
    x = (m12 - m21) / s;
    y = (m20 - m02) / s;
    z = (m01 - m10) / s;
    w = 0.25 * s;
  } else {
    if (m00 > m11 && m00 > m22) {
      // Column 0:
      s = sqrt(1.0 + m00 - m11 - m22) * 2.0;
      x = 0.25 * s;
      y = (m01 + m10) / s;
      z = (m20 + m02) / s;
      w = (m12 - m21) / s;
    } else if (m11 > m22) {
      // Column 1:
      s = sqrt(1.0 + m11 - m00 - m22) * 2.0;
      x = (m01 + m10) / s;
      y = 0.25 * s;
      z = (m12 + m21) / s;
      w = (m20 - m02) / s;
    } else {
      // Column 2:
      s = sqrt(1.0 + m22 - m00 - m11) * 2.0;
      x = (m20 + m02) / s;
      y = (m12 + m21) / s;
      z = 0.25 * s;
      w = (m01 - m10) / s;
    }
  }
  out.x = x;
  out.y = y;
  out.z = z;
  out.w = w;
  return out;
}

final rad2degree = 57.2957795130824;
final deg2rad = 0.01745329251994;

Vector3 quatToEuler(Vector3 out, Quaternion quat) {
  var x = quat[0], y = quat[1], z = quat[2], w = quat[3],
      yy = y * y, radianToDegree = rad2degree;
    if (out == null) {
      out = new Vector3.zero();
    }
    out[0] = atan2(2 * (w * x + y * z), 1.0 - 2.0 * (x * x + yy)) * radianToDegree;
    out[1] = asin(2 * (w * y - z * x)) * radianToDegree;
    out[2] = atan2(2 * (w * z + x * y), 1.0 - 2.0 * (yy + z * z)) * radianToDegree;
    return out;
}

Quaternion eulerToQuat(Quaternion out, Vector3 vec) {
    // code based on GLM
    var degreeToRadian = deg2rad, halfDTR = degreeToRadian * 0.5,
        x = vec.storage[0] * halfDTR,
        y = vec.storage[1] * halfDTR,
        z = vec.storage[2] * halfDTR,
        cx = cos(x), cy = cos(y), cz = cos(z),
        sx = sin(x), sy = sin(y), sz = sin(z);
    out.storage[3] = cx * cy * cz + sx * sy * sz;
    out.storage[0] = sx * cy * cz - cx * sy * sz;
    out.storage[1] = cx * sy * cz + sx * cy * sz;
    out.storage[2] = cx * cy * sz - sx * sy * cz;
    return out;
}


Quaternion quaternionFromMatrix2(Quaternion out, Matrix4 m) {
  // Adapted from: http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
  double x,y,z,w;
  final m00 = m.entry(0,0);
  final m11 = m.entry(1,1);
  final m22 = m.entry(2,2);
  w = sqrt( max( 0.0, 1.0 + m00 + m11 + m22 ) ) / 2.0;
  x = sqrt( max( 0.0, 1.0 + m00 - m11 - m22 ) ) / 2.0;
  y = sqrt( max( 0.0, 1.0 - m00 + m11 - m22 ) ) / 2.0;
  z = sqrt( max( 0.0, 1.0 - m00 - m11 + m22 ) ) / 2.0;

  final m12 = m.entry(1,2);
  final m21 = m.entry(2,1);

  final m02 = m.entry(0,2);
  final m20 = m.entry(2,0);

  final m10 = m.entry(1,0);
  final m01 = m.entry(0,1);

  x *= ( x * ( m21 - m12 ) ).sign;
  y *= ( y * ( m02 - m20 ) ).sign;
  z *= ( z * ( m10 - m01 ) ).sign;
  out.x = x;
  out.y = y;
  out.z = z;
  out.w = w;
  return out;
}



void worldMatrixFromPosRotScale(Float32List worldMatrix, Float32List localPosRotScale) {
  //print(localPosRotScale);
  final double px = localPosRotScale[0];
  final double py = localPosRotScale[1];
  final double pz = localPosRotScale[2];

  final double rx = localPosRotScale[4], ry = localPosRotScale[5], rz = localPosRotScale[6], rw = localPosRotScale[7];
  final double sx = localPosRotScale[8], sy = localPosRotScale[9], sz = localPosRotScale[10];
  final double x2 = rx + rx;
  final double y2 = ry + ry;
  final double z2 = rz + rz;

  final double xx = rx * x2;
  final double xy = rx * y2;
  final double xz = rx * z2;
  final double yy = ry * y2;
  final double yz = ry * z2;
  final double zz = rz * z2;
  final double wx = rw * x2;
  final double wy = rw * y2;
  final double wz = rw * z2;


  double m11 = sx * (1.0 - (yy + zz));
  double m12 = sy * (xy + wz);
  double m13 = sz * (xz - wy);

  double m21 = sx * (xy - wz);
  double m22 = sy * (1.0 - (xx + zz));
  double m23 = sz * (yz + wx);

  double m31 = sx * (xz + wy);
  double m32 = sy * (yz - wx);
  double m33 = sz * (1.0 - (xx + yy));

  final double m41 = px;//(px * m11 + py * m21 + pz * m31);
  final double m42 = py;//(px * m12 + py * m22 + pz * m32);
  final double m43 = pz;//(px * m13 + py * m23 + pz * m33);

  worldMatrix[0] = m11;
  worldMatrix[1] = m12;
  worldMatrix[2] = m13;
  worldMatrix[3] = 0.0;
  worldMatrix[4] = m21;
  worldMatrix[5] = m22;
  worldMatrix[6] = m23;
  worldMatrix[7] = 0.0;
  worldMatrix[8] = m31;
  worldMatrix[9] = m32;
  worldMatrix[10] = m33;
  worldMatrix[11] = 0.0;
  worldMatrix[12] = m41;
  worldMatrix[13] = m42;
  worldMatrix[14] = m43;
  worldMatrix[15] = 1.0;

}

void viewMatrixFromPosRotScale(Float32List worldMatrix, Float32List localPosRotScale) {
  final double px = localPosRotScale[0];
  final double py = localPosRotScale[1];
  final double pz = localPosRotScale[2];

  final double rx = localPosRotScale[4], ry = localPosRotScale[5], rz = localPosRotScale[6], rw = localPosRotScale[7];
  final double sx = localPosRotScale[8], sy = localPosRotScale[9], sz = localPosRotScale[10];
  final double x2 = rx + rx;
  final double y2 = ry + ry;
  final double z2 = rz + rz;

  final double xx = rx * x2;
  final double xy = rx * y2;
  final double xz = rx * z2;
  final double yy = ry * y2;
  final double yz = ry * z2;
  final double zz = rz * z2;
  final double wx = rw * x2;
  final double wy = rw * y2;
  final double wz = rw * z2;


  double m11 = sx * (1.0 - (yy + zz));
  double m12 = sy * (xy + wz);
  double m13 = sz * (xz - wy);

  double m21 = sx * (xy - wz);
  double m22 = sy * (1.0 - (xx + zz));
  double m23 = sz * (yz + wx);

  double m31 = sx * (xz + wy);
  double m32 = sy * (yz - wx);
  double m33 = sz * (1.0 - (xx + yy));

  final double m41 = px;//(px * m11 + py * m21 + pz * m31);
  final double m42 = py;//(px * m12 + py * m22 + pz * m32);
  final double m43 = pz;//(px * m13 + py * m23 + pz * m33);

  worldMatrix[0] = m11;
  worldMatrix[1] = m12;
  worldMatrix[2] = m13;
  worldMatrix[3] = 0.0;
  worldMatrix[4] = m21;
  worldMatrix[5] = m22;
  worldMatrix[6] = m23;
  worldMatrix[7] = 0.0;
  worldMatrix[8] = m31;
  worldMatrix[9] = m32;
  worldMatrix[10] = m33;
  worldMatrix[11] = 0.0;
  worldMatrix[12] = m41;
  worldMatrix[13] = m42;
  worldMatrix[14] = m43;
  worldMatrix[15] = 1.0;

}

void calcWorldMatrix(Float32List parentWorldMat, Float32List outLocalMatrix, Float32List outWorldMatrix, Float32List localPosRotScale) {
  final double rx = localPosRotScale[4], ry = localPosRotScale[5], rz = localPosRotScale[6], rw = localPosRotScale[7];
  final double sx = localPosRotScale[8], sy = localPosRotScale[9], sz = localPosRotScale[10];
  double x2 = rx + rx;
  double y2 = ry + ry;
  double z2 = rz + rz;

  double xx = rx * x2;
  double xy = rx * y2;
  double xz = rx * z2;
  double yy = ry * y2;
  double yz = ry * z2;
  double zz = rz * z2;
  double wx = rw * x2;
  double wy = rw * y2;
  double wz = rw * z2;
  final lm00 = outLocalMatrix[0]  = sx * (1.0 - (yy + zz));
  final lm01 = outLocalMatrix[1]  = sy * (xy + wz);
  final lm02 = outLocalMatrix[2]  = sz * (xz - wy);
  //final lm03 = 0.0;
  //outLocalMatrix[3]  = 0.0;
  final lm10 = outLocalMatrix[4]  = sx * (xy - wz);
  final lm11 = outLocalMatrix[5]  = sy * (1.0 - (xx + zz));
  final lm12 = outLocalMatrix[6]  = sz * (yz + wx);
  //final lm13 = 0.0;
  //outLocalMatrix[7]  = 0.0;
  final lm20 = outLocalMatrix[8]  = sx * (xz + wy);
  final lm21 = outLocalMatrix[9]  = sy * (yz - wx);
  final lm22 = outLocalMatrix[10] = sz * (1.0 - (xx + yy));
  //final lm23 = 0.0;
  //outLocalMatrix[11] = 0.0;

  final lm30 = outLocalMatrix[12] = localPosRotScale[0];
  final lm31 = outLocalMatrix[13] = localPosRotScale[1];
  final lm32 = outLocalMatrix[14] = localPosRotScale[2];
  //final lm33 = 0.0;
  //outLocalMatrix[15] = 1.0;


  final a00 = parentWorldMat[0], a01 = parentWorldMat[1], a02 = parentWorldMat[2];//, a03 = a[3],
  final a10 = parentWorldMat[4], a11 = parentWorldMat[5], a12 = parentWorldMat[6];//, a13 = a[7],
  final a20 = parentWorldMat[8], a21 = parentWorldMat[9], a22 = parentWorldMat[10];//, a23 = a[11],
  final a30 = parentWorldMat[12], a31 = parentWorldMat[13], a32 = parentWorldMat[14];//, a33 = a[15];

  //var lm00  = b[0], lm01 = b[1], lm02 = b[2], lm03 = b[3];
  outWorldMatrix[0] = lm00*a00 + lm01*a10 + lm02*a20;// + b3*a30;
  outWorldMatrix[1] = lm00*a01 + lm01*a11 + lm02*a21;// + b3*a31;
  outWorldMatrix[2] = lm00*a02 + lm01*a12 + lm02*a22;// + b3*a32;
  //out[3] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

  //var lm10 = b[4], lm11 = b[5], lm12 = b[6], lm13 = b[7];
  outWorldMatrix[4] = lm10*a00 + lm11*a10 + lm12*a20;// + b3*a30;
  outWorldMatrix[5] = lm10*a01 + lm11*a11 + lm12*a21;// + b3*a31;
  outWorldMatrix[6] = lm10*a02 + lm11*a12 + lm12*a22;// + b3*a32;
  //outWorldMatrix[7] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

  //var lm20 = b[8], lm21 = b[9], lm22 = b[10], lm23 = b[11];
  outWorldMatrix[8] = lm20*a00 + lm21*a10 + lm22*a20;// + b3*a30;
  outWorldMatrix[9] = lm20*a01 + lm21*a11 + lm22*a21;// + b3*a31;
  outWorldMatrix[10] = lm20*a02 + lm21*a12 + lm22*a22;// + b3*a32;
  //outWorldMatrix[11] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

  //var lm30 = b[12], lm31 = b[13], lm32 = b[14], lm33 = b[15];
  outWorldMatrix[12] = lm30*a00 + lm31*a10 + lm32*a20 + /*b3*/a30;
  outWorldMatrix[13] = lm30*a01 + lm31*a11 + lm32*a21 + /*b3*/a31;
  outWorldMatrix[14] = lm30*a02 + lm31*a12 + lm32*a22 + /*b3*/a32;
  //out[15] = b0*a03 + b1*a13 + b2*a23 + b3*a33;
}

void mul44WorldMatrix(Float32List out, Float32List a, Float32List b) {
  final a00 = a[0], a01 = a[1], a02 = a[2];//, a03 = a[3],
  final a10 = a[4], a11 = a[5], a12 = a[6];//, a13 = a[7],
  final a20 = a[8], a21 = a[9], a22 = a[10];//, a23 = a[11],
  final a30 = a[12], a31 = a[13], a32 = a[14];//, a33 = a[15];

  var b0  = b[0], b1 = b[1], b2 = b[2], b3 = b[3];
  out[0] = b0*a00 + b1*a10 + b2*a20;// + b3*a30;
  out[1] = b0*a01 + b1*a11 + b2*a21;// + b3*a31;
  out[2] = b0*a02 + b1*a12 + b2*a22;// + b3*a32;
  //out[3] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

  b0 = b[4]; b1 = b[5]; b2 = b[6]; b3 = b[7];
  out[4] = b0*a00 + b1*a10 + b2*a20;// + b3*a30;
  out[5] = b0*a01 + b1*a11 + b2*a21;// + b3*a31;
  out[6] = b0*a02 + b1*a12 + b2*a22;// + b3*a32;
  //out[7] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

  b0 = b[8]; b1 = b[9]; b2 = b[10]; b3 = b[11];
  out[8] = b0*a00 + b1*a10 + b2*a20;// + b3*a30;
  out[9] = b0*a01 + b1*a11 + b2*a21;// + b3*a31;
  out[10] = b0*a02 + b1*a12 + b2*a22;// + b3*a32;
  //out[11] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

  b0 = b[12]; b1 = b[13]; b2 = b[14]; b3 = b[15];
  out[12] = b0*a00 + b1*a10 + b2*a20 + /*b3*/a30;
  out[13] = b0*a01 + b1*a11 + b2*a21 + /*b3*/a31;
  out[14] = b0*a02 + b1*a12 + b2*a22 + /*b3*/a32;
  //out[15] = b0*a03 + b1*a13 + b2*a23 + b3*a33;
}

void mul442WorldMatrix(Float32List out, Float32List parentWorldMat, Float32List b) {
  final a00 = parentWorldMat[0], a01 = parentWorldMat[1], a02 = parentWorldMat[2];//, a03 = a[3],
  final a10 = parentWorldMat[4], a11 = parentWorldMat[5], a12 = parentWorldMat[6];//, a13 = a[7],
  final a20 = parentWorldMat[8], a21 = parentWorldMat[9], a22 = parentWorldMat[10];//, a23 = a[11],
  final a30 = parentWorldMat[12], a31 = parentWorldMat[13], a32 = parentWorldMat[14];//, a33 = a[15];

  var lm00  = b[0], lm01 = b[1], lm02 = b[2], lm03 = b[3];
  out[0] = lm00*a00 + lm01*a10 + lm02*a20;// + b3*a30;
  out[1] = lm00*a01 + lm01*a11 + lm02*a21;// + b3*a31;
  out[2] = lm00*a02 + lm01*a12 + lm02*a22;// + b3*a32;
  //out[3] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

  var lm10 = b[4], lm11 = b[5], lm12 = b[6], lm13 = b[7];
  out[4] = lm10*a00 + lm11*a10 + lm12*a20;// + b3*a30;
  out[5] = lm10*a01 + lm11*a11 + lm12*a21;// + b3*a31;
  out[6] = lm10*a02 + lm11*a12 + lm12*a22;// + b3*a32;
  //out[7] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

  var lm20 = b[8], lm21 = b[9], lm22 = b[10], lm23 = b[11];
  out[8] = lm20*a00 + lm21*a10 + lm22*a20;// + b3*a30;
  out[9] = lm20*a01 + lm21*a11 + lm22*a21;// + b3*a31;
  out[10] = lm20*a02 + lm21*a12 + lm22*a22;// + b3*a32;
  //out[11] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

  var lm30 = b[12], lm31 = b[13], lm32 = b[14], lm33 = b[15];
  out[12] = lm30*a00 + lm31*a10 + lm32*a20 + /*b3*/a30;
  out[13] = lm30*a01 + lm31*a11 + lm32*a21 + /*b3*/a31;
  out[14] = lm30*a02 + lm31*a12 + lm32*a22 + /*b3*/a32;
  //out[15] = b0*a03 + b1*a13 + b2*a23 + b3*a33;
}
void mul44GM(Float32List out, Float32List a, Float32List b) {
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

void _quatDifference(Quaternion q0, Quaternion q1, Quaternion out) {

  double fromX = q1.storage[0];
  double fromY = q1.storage[1];
  double fromZ = q1.storage[2];
  double fromW = q1.storage[3];

  double l = 1.0 / q0.length2;
  double toX = q0.storage[0] * l;
  double toY = q0.storage[1] * l;
  double toZ = q0.storage[2] * l;
  double toW = q0.storage[3] * l;


  out.storage[0] = fromW * toX + fromX * toW + fromY * toZ - fromZ * toY;
  out.storage[1] = fromW * toY + fromY * toW + fromZ * toX - fromX * toZ;
  out.storage[2] = fromW * toZ + fromZ * toW + fromX * toY - fromY * toX;
  out.storage[3] = fromW * toW - fromX * toX - fromY * toY - fromZ * toZ;
  return;
}


void _rotate(Quaternion q0, Quaternion q1, Quaternion out) {

  double fromX = q1.storage[0];
  double fromY = q1.storage[1];
  double fromZ = q1.storage[2];
  double fromW = q1.storage[3];
  double toX = q0.storage[0];
  double toY = q0.storage[1];
  double toZ = q0.storage[2];
  double toW = q0.storage[3];


  out.storage[0] = fromW * toX + fromX * toW + fromY * toZ - fromZ * toY;
  out.storage[1] = fromW * toY + fromY * toW + fromZ * toX - fromX * toZ;
  out.storage[2] = fromW * toZ + fromZ * toW + fromX * toY - fromY * toX;
  out.storage[3] = fromW * toW - fromX * toX - fromY * toY - fromZ * toZ;
  return;
}