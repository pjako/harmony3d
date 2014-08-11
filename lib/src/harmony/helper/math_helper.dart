part of harmony;



Matrix4 matrixFromPosRotScale(Vector3 position, Quaternion rotation, Vector3 scale, Matrix4 out) {
  Float32List mat = out.storage;
  double sx = scale.storage[0];
  double sy = scale.storage[1];
  double sz = scale.storage[1];
  double rx = rotation.storage[0];
  double ry = rotation.storage[1];
  double rz = rotation.storage[2];
  double rw = rotation.storage[3];
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
  mat[0] = /*1.0*/ sx - (yy + zz);
  mat[1] = xy + wz;
  mat[2] = xz - wy;
  mat[4] = xy - wz;
  mat[5] = /*1.0*/ sy - (xx + zz);
  mat[6] = yz + wx;
  mat[8] = xz + wy;
  mat[9] = yz - wx;
  mat[10] = /*1.0*/ sz - (xx + yy);
  mat[12] = position.storage[0] * sx;
  mat[13] = position.storage[1] * sy;
  mat[14] = position.storage[2] * sz;
  mat[15] = 1.0;
  return out;
}


Matrix4 setWorldMatrixFromPosRot(Vector3 position, Quaternion rotation, /*Vector3 scale,*/ Matrix4 outViewMatrix) {

  //_worldTransform.setFromTranslationRotation(_position, _rotation);
  //return;

  //double scaleX = scale.storage[0];
  //double scaleY = scale.storage[1];
  //double scaleZ = scale.storage[2];

  double vx = position.storage[0];
  double vy = position.storage[1];
  double vz = position.storage[2];


  double rx = rotation.storage[0];
  double ry = rotation.storage[1];
  double rz = rotation.storage[2];
  double rw = rotation.storage[3];


  //double sx = _position.storage[0];
  //double sy = _position.storage[1];
  //double sz = _position.storage[2];
  // calculate matrix terms
  double twoXSquared = 2.0 * rx * rx;
  double twoYSquared = 2.0 * ry * ry;
  double twoZSquared = 2.0 * rz * rz;
  double twoXY = 2.0 * rx * ry;
  double twoWZ = 2.0 * rw * rz;
  double twoXZ = 2.0 * rx * rz;
  double twoWY = 2.0 * rw * ry;
  double twoYZ = 2.0 * ry * rz;
  double twoWX = 2.0 * rw * rx;

  // update view matrix orientation
  double m11 = (1.0 - (twoYSquared + twoZSquared));
  double m12 = (twoXY + twoWZ);
  double m13 = (twoXZ - twoWY);

  double m21 = (twoXY - twoWZ);
  double m22 = (1.0 - (twoXSquared + twoZSquared));
  double m23 = (twoYZ + twoWX);

  double m31 = (twoXZ + twoWY);
  double m32 = (twoYZ - twoWX);
  double m33 = (1.0 - (twoXSquared + twoYSquared));

  // update view translation
  //Vector3 front = new Vector3(m11, m21, m31);
  //Vector3 up = new Vector3(m12, m22, m32);
  //Vector3 right = new Vector3(m13, m23, m33);
  //double m41 = -front.dot(_position);
  //double m42 = -up.dot(_position);
  //double m43 = -right.dot(_position);
  final double m41 =  -vx;//- (vx * m11 + vy * m21 + vz * m31);
  final double m42 =  -vy;//- (vx * m12 + vy * m22 + vz * m32);
  final double m43 =  -vz;//- (vx * m13 + vy * m23 + vz * m33);


  outViewMatrix.storage[0] = m11;
  outViewMatrix.storage[1] = m12;
  outViewMatrix.storage[2] = m13;
  outViewMatrix.storage[3] = 0.0;
  outViewMatrix.storage[4] = m21;
  outViewMatrix.storage[5] = m22;
  outViewMatrix.storage[6] = m23;
  outViewMatrix.storage[7] = 0.0;
  outViewMatrix.storage[8] = m31;
  outViewMatrix.storage[9] = m32;
  outViewMatrix.storage[10] = m33;
  outViewMatrix.storage[11] = 0.0;
  outViewMatrix.storage[12] = - m41;
  outViewMatrix.storage[13] = - m42;
  outViewMatrix.storage[14] = - m43;
  outViewMatrix.storage[15] = 1.0;
  return outViewMatrix;
}
Matrix4 setViewMatrixFromPosRot(Vector3 position, Quaternion rotation,/* Vector3 scale,*/ Matrix4 outViewMatrix) {

  //_worldTransform.setFromTranslationRotation(_position, _rotation);
  //return;

  //double scaleX = scale.storage[0];
  //double scaleY = scale.storage[1];
  //double scaleZ = scale.storage[2];

  double vx = position.storage[0];
  double vy = position.storage[1];
  double vz = position.storage[2];

  // conjungate
  //rotation.inverse();
  double rx = rotation.storage[0];
  double ry = rotation.storage[1];
  double rz = rotation.storage[2];
  double rw = rotation.storage[3];
  //rotation.inverse();

  //double sx = _position.storage[0];
  //double sy = _position.storage[1];
  //double sz = _position.storage[2];
  // calculate matrix terms
  double twoXSquared = 2.0 * rx * rx;
  double twoYSquared = 2.0 * ry * ry;
  double twoZSquared = 2.0 * rz * rz;
  double twoXY = 2.0 * rx * ry;
  double twoWZ = 2.0 * rw * rz;
  double twoXZ = 2.0 * rx * rz;
  double twoWY = 2.0 * rw * ry;
  double twoYZ = 2.0 * ry * rz;
  double twoWX = 2.0 * rw * rx;

  // update view matrix orientation
  double m11 = (1.0 - (twoYSquared + twoZSquared));
  double m12 = (twoXY + twoWZ);
  double m13 = (twoXZ - twoWY);

  double m21 = (twoXY - twoWZ);
  double m22 = (1.0 - (twoXSquared + twoZSquared));
  double m23 = (twoYZ + twoWX);

  double m31 = (twoXZ + twoWY);
  double m32 = (twoYZ - twoWX);
  double m33 = (1.0 - (twoXSquared + twoYSquared));

  // update view translation
  //Vector3 front = new Vector3(m11, m21, m31);
  //Vector3 up = new Vector3(m12, m22, m32);
  //Vector3 right = new Vector3(m13, m23, m33);
  //double m41 = -front.dot(_position);
  //double m42 = -up.dot(_position);
  //double m43 = -right.dot(_position);
  double m41 = - (vx * m11 + vy * m21 + vz * m31);
  double m42 = - (vx * m12 + vy * m22 + vz * m32);
  double m43 = - (vx * m13 + vy * m23 + vz * m33);


  outViewMatrix.storage[0] = m11;
  outViewMatrix.storage[1] = m12;
  outViewMatrix.storage[2] = m13;
  outViewMatrix.storage[3] = 0.0;
  outViewMatrix.storage[4] = m21;
  outViewMatrix.storage[5] = m22;
  outViewMatrix.storage[6] = m23;
  outViewMatrix.storage[7] = 0.0;
  outViewMatrix.storage[8] = m31;
  outViewMatrix.storage[9] = m32;
  outViewMatrix.storage[10] = m33;
  outViewMatrix.storage[11] = 0.0;
  outViewMatrix.storage[12] = m41;
  outViewMatrix.storage[13] = m42;
  outViewMatrix.storage[14] = m43;
  outViewMatrix.storage[15] = 1.0;
  return outViewMatrix;
}