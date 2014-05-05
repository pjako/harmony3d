part of animation;



class BoneState {
  final int boneIndex;
  final Float32List _positionMatrix = new Float32List(16);
  final Float32List _rotationMatrix = new Float32List(16);
  final Float32List _scaleMatrix = new Float32List(16);

  Float32x4List _positionMatrix4;
  Float32x4List _rotationMatrix4;
  Float32x4List _scaleMatrix4;

  BoneState(this.boneIndex);

  /// Set [boneMatrix] to correspond to bone animation at time [t].
  /// Does not interpolate between key frames.
  void setBoneMatrixAtTimeLerp(double t0, double t1, BoneAnimation anim0, BoneAnimation anim1, double lerp, Float32List boneMatrix) {
    buildTransformMatricesAtTimeLerp(t0, t1, anim0, anim1, lerp);

    Matrix44Operations.multiply(boneMatrix, 0, _scaleMatrix, 0, _rotationMatrix, 0);
    Matrix44Operations.multiply(boneMatrix, 0, _positionMatrix, 0, boneMatrix, 0);
  }


  /// Set [boneMatrix] to correspond to bone animation at time [t].
  /// Does not interpolate between key frames.
  void setBoneMatrixAtTime(double t, BoneAnimation anim0, Float32List boneMatrix) {
    buildTransformMatricesAtTime(t, anim0);

    Matrix44Operations.multiply(boneMatrix, 0, _scaleMatrix, 0, _rotationMatrix, 0);
    Matrix44Operations.multiply(boneMatrix, 0, _positionMatrix, 0, boneMatrix, 0);
  }

  /// Set [boneMatrix] to correspond to bone animation at time [t].
  /// Does not interpolate between key frames.
  void setBoneMatrixAtTimeSIMD(double t, BoneAnimation anim0, Float32x4List boneMatrix) {
    buildTransformMatricesAtTime(t, anim0);

    Matrix44SIMDOperations.multiply(boneMatrix, 0, _scaleMatrix4, 0, _rotationMatrix4, 0);
    Matrix44SIMDOperations.multiply(boneMatrix, 0, _positionMatrix4, 0, boneMatrix, 0);
  }


  void buildTransformMatricesAtTime(double t, BoneAnimation anim0) {

    double pTime0 = anim0._positionTimes.last;
    double pTime1;// = anim0._positionTimes.last;
    int pId0, pId1;


    /*
     * Handle Position interpolation
     */

    if(t > pTime0) {
      pTime1 = anim0._animationTime + anim0._positionTimes.first;
      pId1 = 0;
      pId0 = (anim0._positionTimes.length -1);
    } else {
      pId0 = anim0._findPositionTimeIndex(t);
      pId1 = pId0+1;
      pTime0 = anim0._positionTimes[pId0];
      if(anim0._positionTimes.length <= pId1) pId1 = pId0;
      pTime1 = anim0._positionTimes[pId1];
    }
    pId0 = pId0 << 2;
    pId1 = pId1 << 2;


    double px0 = anim0._positionValues[pId0];
    double px1 = anim0._positionValues[pId1];
    double py0 = anim0._positionValues[pId0+1];
    double py1 = anim0._positionValues[pId1+1];
    double pz0 = anim0._positionValues[pId0+2];
    double pz1 = anim0._positionValues[pId1+2];

    double pTimeDif = pTime1-pTime0;


    double px, py, pz, pw;

    {
      double t0 = pTime0;
      double t1 = pTime1;
      double time = inverseLerp(t0,t1,t);
      double dt = time;
      double t2 = time * time;
      double t3 = t2 * time;
      {
        double value0 = px0;
        double value1 = px1;
        //time = dt / (time - t0);

        double m0 = anim0._positionTangentOut[pId0] * dt;
        double m1 = anim0._positionTangentIn[pId1]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + time;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        px = a * value0 + b * m0 + c * m1 + d * value1;
      }
      {
        double value0 = py0;
        double value1 = py1;
        //t = dt / (t - t0);

        double m0 = anim0._positionTangentOut[pId0+1] * dt;
        double m1 = anim0._positionTangentIn[pId1+1]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + time;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        py = a * value0 + b * m0 + c * m1 + d * value1;
      }
      {
        double value0 = pz0;
        double value1 = pz1;
        //t = dt / (t - t0);

        double m0 = anim0._positionTangentOut[pId0+2] * dt;
        double m1 = anim0._positionTangentIn[pId1+2]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + time;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        pz = a * value0 + b * m0 + c * m1 + d * value1;
      }
    }

    // Interpolate Position
    //double px = px0 + pTimeDif * (px1-px0);
    //double py = py0 + pTimeDif * (py1-py0);
    //double pz = pz0 + pTimeDif * (pz1-pz0);



    /*
     * Handle Rotation interpolation
     */


    double rTime0 = anim0._rotationTimes.last;
    double rTime1;// = anim0._positionTimes.last;
    int rId0, rId1;

    if(t > rTime0) {
      rTime1 = anim0._animationTime + anim0._rotationTimes.first;
      rId1 = 0;
      rId0 = (anim0._rotationTimes.length -1);
    } else {
      rId0 = anim0._findRotationTimeIndex(t);
      rId1 = rId0+1;
      if(anim0._rotationTimes.length <= rId1) rId1 = rId0;
      rTime1 = anim0._rotationTimes[rId1];
      rTime0 = anim0._rotationTimes[rId0];
    }
    rId0 = rId0 << 2;
    rId1 = rId1 << 2;


    double rx0 = anim0._rotationValues[rId0];
    double rx1 = anim0._rotationValues[rId1];
    double ry0 = anim0._rotationValues[rId0+1];
    double ry1 = anim0._rotationValues[rId1+1];
    double rz0 = anim0._rotationValues[rId0+2];
    double rz1 = anim0._rotationValues[rId1+2];
    double rw0 = anim0._rotationValues[rId0+3];
    double rw1 = anim0._rotationValues[rId1+3];

    //double rTimeDif = rTime1 - rTime0;


    double rx, ry, rz, rw;

    {
      double t0 = rTime0;
      double t1 = rTime1;
      double time = inverseLerp(t0,t1,t);
      double dt = t1 - t0;
      double t2 = time * time;
      double t3 = t2 * time;
      {
        double value0 = rx0;
        double value1 = rx1;
        //time = dt / (time - t0);

        double m0 = anim0._rotationTangentOut[rId0] * dt;
        double m1 = anim0._rotationTangentIn[rId1]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + time;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        rx = a * value0 + b * m0 + c * m1 + d * value1;
      }
      {
        double value0 = ry0;
        double value1 = ry1;
        //time = dt / (time - t0);

        double m0 = anim0._rotationTangentOut[rId0+1] * dt;
        double m1 = anim0._rotationTangentIn[rId1+1]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + time;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        ry = a * value0 + b * m0 + c * m1 + d * value1;
      }
      {
        double value0 = rz0;
        double value1 = rz1;
        //time = dt / (time - t0);

        double m0 = anim0._rotationTangentOut[rId0+2] * dt;
        double m1 = anim0._rotationTangentIn[rId1+2]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + time;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        rz = a * value0 + b * m0 + c * m1 + d * value1;
      }
      {
        double value0 = rw0;
        double value1 = rw1;
        //time = dt / (time - t0);

        double m0 = anim0._rotationTangentOut[rId0+3] * dt;
        double m1 = anim0._rotationTangentIn[rId1+3]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + time;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        rw = a * value0 + b * m0 + c * m1 + d * value1;
      }
    }

    // Interpolate Position
    //double rx = rx0 + rTimeDif * ( rx1 - rx0);
    //double ry = ry0 + rTimeDif * ( ry1 - ry0);
    //double rz = rz0 + rTimeDif * ( rz1 - rz0);
    //double rw = rw0 + rTimeDif * ( rw1 - rw0);


    /*
     * Handle Scale interpolation
     */

    double sTime0 = anim0._scaleTimes.last;
    double sTime1;
    int sId0, sId1;

    if(t > sTime0) {
      sTime1 = anim0._animationTime + anim0._scaleTimes.first;
      sId1 = 0;
      sId0 = (anim0._scaleTimes.length -1);
    } else {
      sId0 = anim0._findScaleTimeIndex(t);
      sId1 = sId0+1;
      sTime0 = anim0._scaleTimes[sId0];
      if(anim0._scaleTimes.length <= sId1) sId1 = sId0;
      sTime1 = anim0._scaleTimes[sId1];
    }
    sId0 = sId0 << 2;
    sId1 = sId1 << 2;


    double sx0 = anim0._scaleValues[sId0];
    double sx1 = anim0._scaleValues[sId1];
    double sy0 = anim0._scaleValues[sId0+1];
    double sy1 = anim0._scaleValues[sId1+1];
    double sz0 = anim0._scaleValues[sId0+2];
    double sz1 = anim0._scaleValues[sId1+2];

    double sTimeDif = sTime1 - sTime0;

    //double sx = sx0 + sTimeDif * ( sx1 - sx0);
    //double sy = sy0 + sTimeDif * ( sy1 - sy0);
    //double sz = sz0 + sTimeDif * ( sz1 - sz0);
    double sx,sy,sz;


    {
      double t0 = sTime0;
      double t1 = sTime1;
      double time = inverseLerp(t0,t1,t);
      double dt = time;
      double t2 = time * time;
      double t3 = t2 * time;
      {
        double value0 = sx0;
        double value1 = sx1;
        //time = dt / (time - t0);

        double m0 = anim0._scaleTangentOut[sId0] * dt;
        double m1 = anim0._scaleTangentIn[sId1]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + time;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        sx = a * value0 + b * m0 + c * m1 + d * value1;
      }
      {
        double value0 = sy0;
        double value1 = sy1;
        //t = dt / (t - t0);

        double m0 = anim0._scaleTangentOut[sId0+1] * dt;
        double m1 = anim0._scaleTangentIn[sId1+1]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + time;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        sy = a * value0 + b * m0 + c * m1 + d * value1;
      }
      {
        double value0 = sz0;
        double value1 = sz1;
        //t = dt / (t - t0);

        double m0 = anim0._scaleTangentOut[sId0+2] * dt;
        double m1 = anim0._scaleTangentIn[sId1+2]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + time;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        sz = a * value0 + b * m0 + c * m1 + d * value1;
      }
    }

    // Interpolate Position
    //double sx = sx0 + sTimeDif * ( sx1 - sx0);
    //double sy = sy0 + sTimeDif * ( sy1 - sy0);
    //double sz = sz0 + sTimeDif * ( sz1 - sz0);



    _scaleMatrix[0] = sx > 0.0 ? 1.0 : -1.0;
    _scaleMatrix[5] = sy > 0.0 ? 1.0 : -1.0;
    _scaleMatrix[10] = sz > 0.0 ? 1.0 : -1.0;
    _scaleMatrix[15] = 1.0;

    _positionMatrix[0] = 1.0;
    _positionMatrix[5] = 1.0;
    _positionMatrix[10] = 1.0;
    _positionMatrix[12] = px;
    _positionMatrix[13] = py;
    _positionMatrix[14] = pz;
    _positionMatrix[15] = 1.0;

    double x = rx;
    double y = ry;
    double z = rz;
    double w = rw;
    double x2 = x + x;
    double y2 = y + y;
    double z2 = z + z;

    double xx = x * x2;
    double xy = x * y2;
    double xz = x * z2;
    double yy = y * y2;
    double yz = y * z2;
    double zz = z * z2;
    double wx = w * x2;
    double wy = w * y2;
    double wz = w * z2;

    _rotationMatrix[0] = 1.0 - (yy + zz);
    _rotationMatrix[1] = xy + wz;
    _rotationMatrix[2] = xz - wy;
    _rotationMatrix[4] = xy - wz;
    _rotationMatrix[5] = 1.0 - (xx + zz);
    _rotationMatrix[6] = yz + wx;
    _rotationMatrix[8] = xz + wy;
    _rotationMatrix[9] = yz - wx;
    _rotationMatrix[10] = 1.0 - (xx + yy);
    _rotationMatrix[15] = 1.0;


    _rotationMatrix[0] = /*1.0*/ sx - (yy + zz);
    _rotationMatrix[1] = xy + wz;
    _rotationMatrix[2] = xz - wy;
    _rotationMatrix[4] = xy - wz;
    _rotationMatrix[5] = /*1.0*/ sy - (xx + zz);
    _rotationMatrix[6] = yz + wx;
    _rotationMatrix[8] = xz + wy;
    _rotationMatrix[9] = yz - wx;
    _rotationMatrix[10] = /*1.0*/ sz - (xx + yy);
    //_rotationMatrix[11] = ;
    _rotationMatrix[12] = px * sx;
    _rotationMatrix[13] = py * sy;
    _rotationMatrix[14] = pz * sz;
    _rotationMatrix[15] = 1.0;
  }


  void buildTransformMatricesAtTimeLerp(double t0, double t1, BoneAnimation anim0, BoneAnimation anim1, double lerp) {
    double posx_0, posx_1, posy_0, posy_1, posz_0, posz_1;
    double rotx_0, rotx_1, roty_0, roty_1, rotz_0, rotz_1, rotw_0, rotw_1;
    double scalex_0, scalex_1, scaley_0, scaley_1, scalez_0, scalez_1;
    {
      double t = t0;
      double pTime0 = anim0._positionTimes.last;
      double pTime1;// = anim0._positionTimes.last;
      int pId0, pId1;


      /*
       * Handle Position interpolation
       */

      if(t > pTime0) {
        pTime1 = anim0._animationTime + anim0._positionTimes.first;
        pId1 = 0;
        pId0 = (anim0._positionTimes.length -1);
      } else {
        pId0 = anim0._findPositionTimeIndex(t);
        pId1 = pId0+1;
        pTime0 = anim0._positionTimes[pId0];
        if(anim0._positionTimes.length <= pId1) pId1 = pId0;
        pTime1 = anim0._positionTimes[pId1];
      }
      pId0 = pId0 << 2;
      pId1 = pId1 << 2;


      double px0 = anim0._positionValues[pId0];
      double px1 = anim0._positionValues[pId1];
      double py0 = anim0._positionValues[pId0+1];
      double py1 = anim0._positionValues[pId1+1];
      double pz0 = anim0._positionValues[pId0+2];
      double pz1 = anim0._positionValues[pId1+2];

      double pTimeDif = pTime1-pTime0;


      double px, py, pz, pw;

      {
        double t0 = pTime0;
        double t1 = pTime1;
        double time = inverseLerp(t0,t1,t);
        double dt = time;
        double t2 = time * time;
        double t3 = t2 * time;
        {
          double value0 = px0;
          double value1 = px1;
          //time = dt / (time - t0);

          double m0 = anim0._positionTangentOut[pId0] * dt;
          double m1 = anim0._positionTangentIn[pId1]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          px = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = py0;
          double value1 = py1;
          //t = dt / (t - t0);

          double m0 = anim0._positionTangentOut[pId0+1] * dt;
          double m1 = anim0._positionTangentIn[pId1+1]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          py = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = pz0;
          double value1 = pz1;
          //t = dt / (t - t0);

          double m0 = anim0._positionTangentOut[pId0+2] * dt;
          double m1 = anim0._positionTangentIn[pId1+2]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          pz = a * value0 + b * m0 + c * m1 + d * value1;
        }
      }

      // Interpolate Position
      //double px = px0 + pTimeDif * (px1-px0);
      //double py = py0 + pTimeDif * (py1-py0);
      //double pz = pz0 + pTimeDif * (pz1-pz0);



      /*
       * Handle Rotation interpolation
       */


      double rTime0 = anim0._rotationTimes.last;
      double rTime1;// = anim0._positionTimes.last;
      int rId0, rId1;

      if(t > rTime0) {
        rTime1 = anim0._animationTime + anim0._rotationTimes.first;
        rId1 = 0;
        rId0 = (anim0._rotationTimes.length -1);
      } else {
        rId0 = anim0._findRotationTimeIndex(t);
        rId1 = rId0+1;
        if(anim0._rotationTimes.length <= rId1) rId1 = rId0;
        rTime1 = anim0._rotationTimes[rId1];
        rTime0 = anim0._rotationTimes[rId0];
      }
      rId0 = rId0 << 2;
      rId1 = rId1 << 2;


      double rx0 = anim0._rotationValues[rId0];
      double rx1 = anim0._rotationValues[rId1];
      double ry0 = anim0._rotationValues[rId0+1];
      double ry1 = anim0._rotationValues[rId1+1];
      double rz0 = anim0._rotationValues[rId0+2];
      double rz1 = anim0._rotationValues[rId1+2];
      double rw0 = anim0._rotationValues[rId0+3];
      double rw1 = anim0._rotationValues[rId1+3];

      //double rTimeDif = rTime1 - rTime0;


      double rx, ry, rz, rw;

      {
        double t0 = rTime0;
        double t1 = rTime1;
        double time = inverseLerp(t0,t1,t);
        double dt = t1 - t0;
        double t2 = time * time;
        double t3 = t2 * time;
        {
          double value0 = rx0;
          double value1 = rx1;
          //time = dt / (time - t0);

          double m0 = anim0._rotationTangentOut[rId0] * dt;
          double m1 = anim0._rotationTangentIn[rId1]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          rx = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = ry0;
          double value1 = ry1;
          //time = dt / (time - t0);

          double m0 = anim0._rotationTangentOut[rId0+1] * dt;
          double m1 = anim0._rotationTangentIn[rId1+1]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          ry = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = rz0;
          double value1 = rz1;
          //time = dt / (time - t0);

          double m0 = anim0._rotationTangentOut[rId0+2] * dt;
          double m1 = anim0._rotationTangentIn[rId1+2]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          rz = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = rw0;
          double value1 = rw1;
          //time = dt / (time - t0);

          double m0 = anim0._rotationTangentOut[rId0+3] * dt;
          double m1 = anim0._rotationTangentIn[rId1+3]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          rw = a * value0 + b * m0 + c * m1 + d * value1;
        }
      }

      // Interpolate Position
      //double rx = rx0 + rTimeDif * ( rx1 - rx0);
      //double ry = ry0 + rTimeDif * ( ry1 - ry0);
      //double rz = rz0 + rTimeDif * ( rz1 - rz0);
      //double rw = rw0 + rTimeDif * ( rw1 - rw0);


      /*
       * Handle Scale interpolation
       */

      double sTime0 = anim0._scaleTimes.last;
      double sTime1;
      int sId0, sId1;

      if(t > sTime0) {
        sTime1 = anim0._animationTime + anim0._scaleTimes.first;
        sId1 = 0;
        sId0 = (anim0._scaleTimes.length -1);
      } else {
        sId0 = anim0._findScaleTimeIndex(t);
        sId1 = sId0+1;
        sTime0 = anim0._scaleTimes[sId0];
        if(anim0._scaleTimes.length <= sId1) sId1 = sId0;
        sTime1 = anim0._scaleTimes[sId1];
      }
      sId0 = sId0 << 2;
      sId1 = sId1 << 2;


      double sx0 = anim0._scaleValues[sId0];
      double sx1 = anim0._scaleValues[sId1];
      double sy0 = anim0._scaleValues[sId0+1];
      double sy1 = anim0._scaleValues[sId1+1];
      double sz0 = anim0._scaleValues[sId0+2];
      double sz1 = anim0._scaleValues[sId1+2];

      double sTimeDif = sTime1 - sTime0;

      //double sx = sx0 + sTimeDif * ( sx1 - sx0);
      //double sy = sy0 + sTimeDif * ( sy1 - sy0);
      //double sz = sz0 + sTimeDif * ( sz1 - sz0);
      double sx,sy,sz;


      {
        double t0 = sTime0;
        double t1 = sTime1;
        double time = inverseLerp(t0,t1,t);
        double dt = time;
        double t2 = time * time;
        double t3 = t2 * time;
        {
          double value0 = sx0;
          double value1 = sx1;
          //time = dt / (time - t0);

          double m0 = anim0._scaleTangentOut[sId0] * dt;
          double m1 = anim0._scaleTangentIn[sId1]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          sx = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = sy0;
          double value1 = sy1;
          //t = dt / (t - t0);

          double m0 = anim0._scaleTangentOut[sId0+1] * dt;
          double m1 = anim0._scaleTangentIn[sId1+1]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          sy = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = sz0;
          double value1 = sz1;
          //t = dt / (t - t0);

          double m0 = anim0._scaleTangentOut[sId0+2] * dt;
          double m1 = anim0._scaleTangentIn[sId1+2]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          sz = a * value0 + b * m0 + c * m1 + d * value1;
        }
      }

      posx_0 = px;
      posy_0 = py;
      posz_0 = pz;
      rotx_0 = rx;
      roty_0 = ry;
      rotz_0 = rz;
      rotw_0 = rw;
      scalex_0 = sx;
      scaley_0 = sy;
      scalez_0 = sz;
    }


    /*
     * BoneAnim1
     */


    {
      double pTime0 = anim1._positionTimes.last;
      double pTime1;// = anim1._positionTimes.last;
      int pId0, pId1;
      double t = t1;


      /*
       * Handle Position interpolation
       */

      if(t > pTime0) {
        pTime1 = anim1._animationTime + anim1._positionTimes.first;
        pId1 = 0;
        pId0 = (anim1._positionTimes.length -1);
      } else {
        pId0 = anim1._findPositionTimeIndex(t);
        pId1 = pId0+1;
        pTime0 = anim1._positionTimes[pId0];
        if(anim1._positionTimes.length <= pId1) pId1 = pId0;
        pTime1 = anim1._positionTimes[pId1];
      }
      pId0 = pId0 << 2;
      pId1 = pId1 << 2;


      double px0 = anim1._positionValues[pId0];
      double px1 = anim1._positionValues[pId1];
      double py0 = anim1._positionValues[pId0+1];
      double py1 = anim1._positionValues[pId1+1];
      double pz0 = anim1._positionValues[pId0+2];
      double pz1 = anim1._positionValues[pId1+2];

      double pTimeDif = pTime1-pTime0;


      double px, py, pz, pw;

      {
        double t0 = pTime0;
        double t1 = pTime1;
        double time = inverseLerp(t0,t1,t);
        double dt = time;
        double t2 = time * time;
        double t3 = t2 * time;
        {
          double value0 = px0;
          double value1 = px1;
          //time = dt / (time - t0);

          double m0 = anim1._positionTangentOut[pId0] * dt;
          double m1 = anim1._positionTangentIn[pId1]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          px = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = py0;
          double value1 = py1;
          //t = dt / (t - t0);

          double m0 = anim1._positionTangentOut[pId0+1] * dt;
          double m1 = anim1._positionTangentIn[pId1+1]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          py = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = pz0;
          double value1 = pz1;
          //t = dt / (t - t0);

          double m0 = anim1._positionTangentOut[pId0+2] * dt;
          double m1 = anim1._positionTangentIn[pId1+2]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          pz = a * value0 + b * m0 + c * m1 + d * value1;
        }
      }

      // Interpolate Position
      //double px = px0 + pTimeDif * (px1-px0);
      //double py = py0 + pTimeDif * (py1-py0);
      //double pz = pz0 + pTimeDif * (pz1-pz0);



      /*
       * Handle Rotation interpolation
       */


      double rTime0 = anim1._rotationTimes.last;
      double rTime1;// = anim1._positionTimes.last;
      int rId0, rId1;

      if(t > rTime0) {
        rTime1 = anim1._animationTime + anim1._rotationTimes.first;
        rId1 = 0;
        rId0 = (anim1._rotationTimes.length -1);
      } else {
        rId0 = anim1._findRotationTimeIndex(t);
        rId1 = rId0+1;
        if(anim1._rotationTimes.length <= rId1) rId1 = rId0;
        rTime1 = anim1._rotationTimes[rId1];
        rTime0 = anim1._rotationTimes[rId0];
      }
      rId0 = rId0 << 2;
      rId1 = rId1 << 2;


      double rx0 = anim1._rotationValues[rId0];
      double rx1 = anim1._rotationValues[rId1];
      double ry0 = anim1._rotationValues[rId0+1];
      double ry1 = anim1._rotationValues[rId1+1];
      double rz0 = anim1._rotationValues[rId0+2];
      double rz1 = anim1._rotationValues[rId1+2];
      double rw0 = anim1._rotationValues[rId0+3];
      double rw1 = anim1._rotationValues[rId1+3];

      //double rTimeDif = rTime1 - rTime0;


      double rx, ry, rz, rw;

      {
        double t0 = rTime0;
        double t1 = rTime1;
        double time = inverseLerp(t0,t1,t);
        double dt = t1 - t0;
        double t2 = time * time;
        double t3 = t2 * time;
        {
          double value0 = rx0;
          double value1 = rx1;
          //time = dt / (time - t0);

          double m0 = anim1._rotationTangentOut[rId0] * dt;
          double m1 = anim1._rotationTangentIn[rId1]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          rx = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = ry0;
          double value1 = ry1;
          //time = dt / (time - t0);

          double m0 = anim1._rotationTangentOut[rId0+1] * dt;
          double m1 = anim1._rotationTangentIn[rId1+1]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          ry = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = rz0;
          double value1 = rz1;
          //time = dt / (time - t0);

          double m0 = anim1._rotationTangentOut[rId0+2] * dt;
          double m1 = anim1._rotationTangentIn[rId1+2]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          rz = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = rw0;
          double value1 = rw1;
          //time = dt / (time - t0);

          double m0 = anim1._rotationTangentOut[rId0+3] * dt;
          double m1 = anim1._rotationTangentIn[rId1+3]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          rw = a * value0 + b * m0 + c * m1 + d * value1;
        }
      }

      // Interpolate Position
      //double rx = rx0 + rTimeDif * ( rx1 - rx0);
      //double ry = ry0 + rTimeDif * ( ry1 - ry0);
      //double rz = rz0 + rTimeDif * ( rz1 - rz0);
      //double rw = rw0 + rTimeDif * ( rw1 - rw0);


      /*
       * Handle Scale interpolation
       */

      double sTime0 = anim1._scaleTimes.last;
      double sTime1;
      int sId0, sId1;

      if(t > sTime0) {
        sTime1 = anim1._animationTime + anim1._scaleTimes.first;
        sId1 = 0;
        sId0 = (anim1._scaleTimes.length -1);
      } else {
        sId0 = anim1._findScaleTimeIndex(t);
        sId1 = sId0+1;
        sTime0 = anim1._scaleTimes[sId0];
        if(anim1._scaleTimes.length <= sId1) sId1 = sId0;
        sTime1 = anim1._scaleTimes[sId1];
      }
      sId0 = sId0 << 2;
      sId1 = sId1 << 2;


      double sx0 = anim1._scaleValues[sId0];
      double sx1 = anim1._scaleValues[sId1];
      double sy0 = anim1._scaleValues[sId0+1];
      double sy1 = anim1._scaleValues[sId1+1];
      double sz0 = anim1._scaleValues[sId0+2];
      double sz1 = anim1._scaleValues[sId1+2];

      double sTimeDif = sTime1 - sTime0;

      //double sx = sx0 + sTimeDif * ( sx1 - sx0);
      //double sy = sy0 + sTimeDif * ( sy1 - sy0);
      //double sz = sz0 + sTimeDif * ( sz1 - sz0);
      double sx,sy,sz;


      {
        double t0 = sTime0;
        double t1 = sTime1;
        double time = inverseLerp(t0,t1,t);
        double dt = time;
        double t2 = time * time;
        double t3 = t2 * time;
        {
          double value0 = sx0;
          double value1 = sx1;
          //time = dt / (time - t0);

          double m0 = anim1._scaleTangentOut[sId0] * dt;
          double m1 = anim1._scaleTangentIn[sId1]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          sx = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = sy0;
          double value1 = sy1;
          //t = dt / (t - t0);

          double m0 = anim1._scaleTangentOut[sId0+1] * dt;
          double m1 = anim1._scaleTangentIn[sId1+1]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          sy = a * value0 + b * m0 + c * m1 + d * value1;
        }
        {
          double value0 = sz0;
          double value1 = sz1;
          //t = dt / (t - t0);

          double m0 = anim1._scaleTangentOut[sId0+2] * dt;
          double m1 = anim1._scaleTangentIn[sId1+2]  * dt;
          double a = 2.0 * t3 - 3.0 * t2 + 1.0;
          double b = t3 - 2.0 * t2 + time;
          double c = t3 - t2;
          double d = -2.0 * t3 + 3.0 * t2;

          sz = a * value0 + b * m0 + c * m1 + d * value1;
        }
      }
      posx_1 = px;
      posy_1 = py;
      posz_1 = pz;
      rotx_1 = rx;
      roty_1 = ry;
      rotz_1 = rz;
      rotw_1 = rw;
      scalex_1 = sx;
      scaley_1 = sy;
      scalez_1 = sz;
    }
    double omega, sinom, scale0, scale1;
    double cosom = rotx_0 * rotx_1 + roty_0 * roty_1 + rotz_0 * rotz_1 + rotw_0 * rotw_1;
    if ( cosom < 0.0 ) {
        cosom = -cosom;
        rotx_1 = - rotx_1;
        roty_1 = - roty_1;
        rotz_1 = - rotz_1;
        rotw_1 = - rotw_1;
    }
    if ( (1.0 - cosom) > 0.000001 ) {
      // standard case (slerp)
      omega  = Math.acos(cosom);
      sinom  = Math.sin(omega);
      scale0 = Math.sin((1.0 - lerp) * omega) / sinom;
      scale1 = Math.sin(lerp * omega) / sinom;
    } else {
        // "from" and "to" quaternions are very close
        //  ... so we can do a linear interpolation
        scale0 = 1.0 - lerp;
        scale1 = lerp;
    }


    _scaleMatrix[0] =  scalex_1 > 0.0 ? 1.0 : -1.0;//scalex_1 + lerp * (scalex_1-scalex_0);//inverseLerp(scalex_0,scalex_1,lerp);
    _scaleMatrix[5] =  scaley_1 > 0.0 ? 1.0 : -1.0;//scaley_1 + lerp * (scaley_1-scaley_0);
    _scaleMatrix[10] = scalez_1 > 0.0 ? 1.0 : -1.0;//scalez_1 + lerp * (scalez_1-scalez_0);
    _scaleMatrix[15] = 1.0;

    _positionMatrix[0] = 1.0;
    _positionMatrix[5] = 1.0;
    _positionMatrix[10] = 1.0;
    _positionMatrix[12] = posx_0 + lerp * (posx_1-posx_0);
    _positionMatrix[13] = posy_0 + lerp * (posy_1-posy_0);
    _positionMatrix[14] = posz_0 + lerp * (posz_1-posz_0);
    _positionMatrix[15] = 1.0;

    double x = scale0 * rotx_0 + scale1 * rotx_1;//rotx_0 + lerp * (rotx_1-rotx_0);
    double y = scale0 * roty_0 + scale1 * roty_1;//roty_0 + lerp * (roty_1-roty_0);
    double z = scale0 * rotz_0 + scale1 * rotz_1;//rotz_0 + lerp * (rotz_1-rotz_0);
    double w = scale0 * rotw_0 + scale1 * rotw_1;//rotw_0 + lerp * (rotw_1-rotw_0);
    double x2 = x + x;
    double y2 = y + y;
    double z2 = z + z;

    double xx = x * x2;
    double xy = x * y2;
    double xz = x * z2;
    double yy = y * y2;
    double yz = y * z2;
    double zz = z * z2;
    double wx = w * x2;
    double wy = w * y2;
    double wz = w * z2;

    _rotationMatrix[0] = 1.0 - (yy + zz);
    _rotationMatrix[1] = xy + wz;
    _rotationMatrix[2] = xz - wy;
    _rotationMatrix[4] = xy - wz;
    _rotationMatrix[5] = 1.0 - (xx + zz);
    _rotationMatrix[6] = yz + wx;
    _rotationMatrix[8] = xz + wy;
    _rotationMatrix[9] = yz - wx;
    _rotationMatrix[10] = 1.0 - (xx + yy);
    _rotationMatrix[15] = 1.0;
  }
}



Float32List generatePosRotScaleAtTime(double t, BoneAnimation anim0, Float32List out) {
  Float32List array = out;
  double pTime0 = anim0._positionTimes.last;
  double pTime1;// = anim0._positionTimes.last;
  int pId0, pId1;


  /*
   * Handle Position interpolation
   */

  if(t > pTime0) {
    pTime1 = anim0._animationTime + anim0._positionTimes.first;
    pId1 = 0;
    pId0 = (anim0._positionTimes.length -1);
  } else {
    pId0 = anim0._findPositionTimeIndex(t);
    pId1 = pId0+1;
    pTime0 = anim0._positionTimes[pId0];
    if(anim0._positionTimes.length <= pId1) pId1 = pId0;
    pTime1 = anim0._positionTimes[pId1];
  }
  pId0 = pId0 << 2;
  pId1 = pId1 << 2;


  double px0 = anim0._positionValues[pId0];
  double px1 = anim0._positionValues[pId1];
  double py0 = anim0._positionValues[pId0+1];
  double py1 = anim0._positionValues[pId1+1];
  double pz0 = anim0._positionValues[pId0+2];
  double pz1 = anim0._positionValues[pId1+2];

  double pTimeDif = pTime1-pTime0;


  double px, py, pz, pw;
  {
    double t0 = pTime0;
    double t1 = pTime1;
    double time = inverseLerp(t0,t1,t);
    double dt = time;
    double t2 = time * time;
    double t3 = t2 * time;
    double a = 2.0 * t3 - 3.0 * t2 + 1.0;
    double b = t3 - 2.0 * t2 + time;
    double c = t3 - t2;
    double d = -2.0 * t3 + 3.0 * t2;
    {
      double value0 = px0;
      double value1 = px1;
      double m0 = anim0._positionTangentOut[pId0] * dt;
      double m1 = anim0._positionTangentIn[pId1]  * dt;
      px = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = py0;
      double value1 = py1;
      double m0 = anim0._positionTangentOut[pId0+1] * dt;
      double m1 = anim0._positionTangentIn[pId1+1]  * dt;
      py = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = pz0;
      double value1 = pz1;
      double m0 = anim0._positionTangentOut[pId0+2] * dt;
      double m1 = anim0._positionTangentIn[pId1+2]  * dt;
      pz = a * value0 + b * m0 + c * m1 + d * value1;
    }
  }
  double rTime0 = anim0._rotationTimes.last;
  double rTime1;// = anim0._positionTimes.last;
  int rId0, rId1;

  if(t > rTime0) {
    rTime1 = anim0._animationTime + anim0._rotationTimes.first;
    rId1 = 0;
    rId0 = (anim0._rotationTimes.length -1);
  } else {
    rId0 = anim0._findRotationTimeIndex(t);
    rId1 = rId0+1;
    if(anim0._rotationTimes.length <= rId1) rId1 = rId0;
    rTime1 = anim0._rotationTimes[rId1];
    rTime0 = anim0._rotationTimes[rId0];
  }
  rId0 = rId0 << 2;
  rId1 = rId1 << 2;


  double rx0 = anim0._rotationValues[rId0];
  double rx1 = anim0._rotationValues[rId1];
  double ry0 = anim0._rotationValues[rId0+1];
  double ry1 = anim0._rotationValues[rId1+1];
  double rz0 = anim0._rotationValues[rId0+2];
  double rz1 = anim0._rotationValues[rId1+2];
  double rw0 = anim0._rotationValues[rId0+3];
  double rw1 = anim0._rotationValues[rId1+3];

  //double rTimeDif = rTime1 - rTime0;


  double rx, ry, rz, rw;

  {
    double t0 = rTime0;
    double t1 = rTime1;
    double time = inverseLerp(t0,t1,t);
    double dt = t1 - t0;
    double t2 = time * time;
    double t3 = t2 * time;
    double a = 2.0 * t3 - 3.0 * t2 + 1.0;
    double b = t3 - 2.0 * t2 + time;
    double c = t3 - t2;
    double d = -2.0 * t3 + 3.0 * t2;
    {
      double value0 = rx0;
      double value1 = rx1;
      double m0 = anim0._rotationTangentOut[rId0] * dt;
      double m1 = anim0._rotationTangentIn[rId1]  * dt;
      rx = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = ry0;
      double value1 = ry1;
      double m0 = anim0._rotationTangentOut[rId0+1] * dt;
      double m1 = anim0._rotationTangentIn[rId1+1]  * dt;
      ry = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = rz0;
      double value1 = rz1;
      double m0 = anim0._rotationTangentOut[rId0+2] * dt;
      double m1 = anim0._rotationTangentIn[rId1+2]  * dt;
      rz = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = rw0;
      double value1 = rw1;
      double m0 = anim0._rotationTangentOut[rId0+3] * dt;
      double m1 = anim0._rotationTangentIn[rId1+3]  * dt;
      rw = a * value0 + b * m0 + c * m1 + d * value1;
    }
  }
  /*
   * Handle Scale interpolation
   */

  double sTime0 = anim0._scaleTimes.last;
  double sTime1;
  int sId0, sId1;

  if(t > sTime0) {
    sTime1 = anim0._animationTime + anim0._scaleTimes.first;
    sId1 = 0;
    sId0 = (anim0._scaleTimes.length -1);
  } else {
    sId0 = anim0._findScaleTimeIndex(t);
    sId1 = sId0+1;
    sTime0 = anim0._scaleTimes[sId0];
    if(anim0._scaleTimes.length <= sId1) sId1 = sId0;
    sTime1 = anim0._scaleTimes[sId1];
  }
  sId0 = sId0 << 2;
  sId1 = sId1 << 2;


  double sx0 = anim0._scaleValues[sId0];
  double sx1 = anim0._scaleValues[sId1];
  double sy0 = anim0._scaleValues[sId0+1];
  double sy1 = anim0._scaleValues[sId1+1];
  double sz0 = anim0._scaleValues[sId0+2];
  double sz1 = anim0._scaleValues[sId1+2];

  double sTimeDif = sTime1 - sTime0;



  double sx,sy,sz;


  {
    double t0 = sTime0;
    double t1 = sTime1;
    double time = inverseLerp(t0,t1,t);
    double dt = time;
    double t2 = time * time;
    double t3 = t2 * time;
    double a = 2.0 * t3 - 3.0 * t2 + 1.0;
    double b = t3 - 2.0 * t2 + time;
    double c = t3 - t2;
    double d = -2.0 * t3 + 3.0 * t2;
    {
      double value0 = sx0;
      double value1 = sx1;
      double m0 = anim0._scaleTangentOut[sId0] * dt;
      double m1 = anim0._scaleTangentIn[sId1]  * dt;
      sx = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = sy0;
      double value1 = sy1;
      double m0 = anim0._scaleTangentOut[sId0+1] * dt;
      double m1 = anim0._scaleTangentIn[sId1+1]  * dt;
      sy = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = sz0;
      double value1 = sz1;
      double m0 = anim0._scaleTangentOut[sId0+2] * dt;
      double m1 = anim0._scaleTangentIn[sId1+2]  * dt;
      sz = a * value0 + b * m0 + c * m1 + d * value1;
    }
  }
  array[0] =  px;
  array[1] =  py;
  array[2] =  pz;
  array[3] =  0.0;
  array[4] =  rx;
  array[5] =  ry;
  array[6] =  rz;
  array[7] =  rw;
  array[8] =  sx;
  array[9] =  sy;
  array[10] = sz;
  array[11] = 0.0;
  return array;
}


Float32List lerpPosRotScale(Float32List a, Float32List b, double lerp, Float32List out) {
  out[0] = a[0] + lerp * b[0];
  out[1] = a[1] + lerp * b[1];
  out[2] = a[2] + lerp * b[2];


  double omega, sinom, scale0, scale1;
  double rotx0=a[4], roty0=a[5], rotz0=a[6], rotw0=a[7], rotx1=b[4], roty1=b[5], rotz1=b[6], rotw1=b[7];
  double cosom = rotx0 * rotx1 + roty0 * roty1 + rotz0 * rotz1 + rotw0 * rotw1;
  if ( cosom < 0.0 ) {
    cosom = -cosom;
    rotx1 = - rotx1;
    roty1 = - roty1;
    rotz1 = - rotz1;
    rotw1 = - rotw1;
  }
  if ( (1.0 - cosom) > 0.000001 ) {
    // standard case (slerp)
    omega  = Math.acos(cosom);
    sinom  = Math.sin(omega);
    scale0 = Math.sin((1.0 - lerp) * omega) / sinom;
    scale1 = Math.sin(lerp * omega) / sinom;
  } else {
    // "from" and "to" quaternions are very close
    //  ... so we can do a linear interpolation
    scale0 = 1.0 - lerp;
    scale1 = lerp;
  }
  out[4] = scale0 * rotx0 + scale1 * rotx1;
  out[5] = scale0 * roty0 + scale1 * roty1;
  out[6] = scale0 * rotz0 + scale1 * rotz1;
  out[7] = scale0 * rotw0 + scale1 * rotw1;

  out[8] = a[8] + lerp * b[8];
  out[9] = a[9] + lerp * b[9];
  out[10] = a[10] + lerp * b[10];
  return out;
}

Float32x4List lerpPosRotScaleSIMD(Float32x4List a, Float32x4List b, Float32x4 lerpx4, Float32x4List out) {
  //final Float32x4 lerpx4 = new Float32x4.splat(lerp);
  out[0] = a[0] + lerpx4 * b[0];

  final Float32x4 a1 = a[1];
  Float32x4 b1 = b[1];

  Float32x4 scale0, scale1;
  Float32x4 cosomx4 = a1 * b1;
  double cosom = cosomx4.x + cosomx4.y + cosomx4.z + cosomx4.w;
  if ( cosom < 0.0 ) {
    cosom = -cosom;
    b1 = - b1;
  }
  if ( (1.0 - cosom) > 0.000001 ) {
    double omega  = Math.acos(cosom);
    double sinom  = Math.sin(omega);
    var lerp = lerpx4.x;
    scale0 = new Float32x4.splat(Math.sin((1.0 - lerp) * omega) / sinom);
    scale1 = new Float32x4.splat(Math.sin(lerp * omega) / sinom);
  } else {
    scale0 = new Float32x4.splat(0.0);
    scale1 = scale0;
  }

  out[1] = scale0 * a1 + scale1 * b1;
  out[2] = a[2] + lerpx4 * b[2];
  return out;
}

Float32x4List generatePosRotScaleAtTimeSIMD(double t, BoneAnimation anim0, Float32x4List out) {

  double pTime0 = anim0._positionTimes.last;
  double pTime1;// = anim0._positionTimes.last;
  int pId0, pId1;

  if(t > pTime0) {
    pTime1 = anim0._animationTime + anim0._positionTimes.first;
    pId1 = 0;
    pId0 = (anim0._positionTimes.length -1);
  } else {
    pId0 = anim0._findPositionTimeIndex(t);
    pId1 = pId0+1;
    pTime0 = anim0._positionTimes[pId0];
    if(anim0._positionTimes.length <= pId1) pId1 = pId0;
    pTime1 = anim0._positionTimes[pId1];
  }
  pId0 = pId0 << 2;
  pId1 = pId1 << 2;


  double rTime0 = anim0._rotationTimes.last;
  double rTime1;// = anim0._positionTimes.last;
  int rId0, rId1;

  if(t > rTime0) {
    rTime1 = anim0._animationTime + anim0._rotationTimes.first;
    rId1 = 0;
    rId0 = (anim0._rotationTimes.length -1);
  } else {
    rId0 = anim0._findRotationTimeIndex(t);
    rId1 = rId0+1;
    if(anim0._rotationTimes.length <= rId1) rId1 = rId0;
    rTime1 = anim0._rotationTimes[rId1];
    rTime0 = anim0._rotationTimes[rId0];
  }
  rId0 = rId0 << 2;
  rId1 = rId1 << 2;

  double sTime0 = anim0._scaleTimes.last;
  double sTime1;
  int sId0, sId1;

  if(t > sTime0) {
    sTime1 = anim0._animationTime + anim0._scaleTimes.first;
    sId1 = 0;
    sId0 = (anim0._scaleTimes.length -1);
  } else {
    sId0 = anim0._findScaleTimeIndex(t);
    sId1 = sId0+1;
    sTime0 = anim0._scaleTimes[sId0];
    if(anim0._scaleTimes.length <= sId1) sId1 = sId0;
    sTime1 = anim0._scaleTimes[sId1];
  }
  sId0 = sId0 << 2;
  sId1 = sId1 << 2;


  final Float32x4 tx4 = new Float32x4.splat(t);
  final Float32x4 t0 = new Float32x4(pTime0,rTime0,sTime0,0.0);
  final Float32x4 t1 = new Float32x4(pTime1,rTime1,sTime1,0.0);
  // time = inverseLerp(t0,t1,tx4);
  final Float32x4 time =  (tx4 - t0) / (t1 - t0);
  final Float32x4 timeSqrt1 = time.sqrt();
  final Float32x4 timeSqrt2 = time * timeSqrt1;

  final Float32x4 one = new Float32x4.splat(2.0);
  final Float32x4 two = new Float32x4.splat(2.0);
  final Float32x4 three = new Float32x4.splat(3.0);

  final Float32x4 a = two * timeSqrt2 - three * timeSqrt1 + one;
  final Float32x4 b = timeSqrt2 - two * timeSqrt1 + time;
  final Float32x4 c = timeSqrt2 - timeSqrt1;
  final Float32x4 d = -two * timeSqrt2 + three * timeSqrt1;
  {
    var val0 = anim0.positionValues4[pId0];
    var val1 = anim0.positionValues4[pId1];
    final Float32x4 tangentOut = anim0._positionOutTangent4[pId0];
    final Float32x4 tangentIn = anim0._positionInTangent4[pId1];
    out[0] = a * val0 + b * tangentOut + c  * tangentIn + d * val1;
  }
  {
    var val0 = anim0.rotationValues4[rId0];
    var val1 = anim0.rotationValues4[rId1];
    final Float32x4 tangentOut = anim0._rotationOutTangent4[rId0];
    final Float32x4 tangentIn = anim0._rotationInTangent4[rId1];
    out[1] = a * val0 + b * tangentOut + c  * tangentIn + d * val1;
  }
  {
    var val0 = anim0.scaleValues4[sId0];
    var val1 = anim0.scaleValues4[sId1];
    final Float32x4 tangentOut = anim0._scaleOutTangent4[sId0];
    final Float32x4 tangentIn = anim0._scaleInTangent4[sId1];
    out[2] = a * val0 + b * tangentOut + c  * tangentIn + d * val1;
  }

  return out;
}




/*
void buildTransformMatricesAtTimeLerp(double t, BoneAnimation anim0, BoneAnimation anim1, double lerp) {
double px_0, py_0, pz_0, px_1, py_1, pz_1;
double rx_0, ry_0, rz_0, rw_0, rx_1, ry_1, rz_1, rw_1;
double sx_0, sy_0, sz_0, sx_1, sy_1, sz_1;
double px,py,pz,rx,ry,rz,rw,sx,sy,sz;
{
double pTime0 = anim0._positionTimes.last;
double pTime1;// = anim0._positionTimes.last;
int pId0, pId1;


/*
 * Handle Position interpolation
 */

if(t > pTime0) {
pTime1 = anim0._animationTime + anim0._positionTimes.first;
pId1 = 0;
pId0 = (anim0._positionTimes.length -1);
} else {
pId0 = anim0._findPositionTimeIndex(t);
pId1 = pId0+1;
pTime0 = anim0._positionTimes[pId0];
pTime1 = anim0._positionTimes[pId1];
}
pId0 = pId0 << 2;
pId1 = pId1 << 2;


double px0 = anim0._positionValues[pId0];
double px1 = anim0._positionValues[pId1];
double py0 = anim0._positionValues[pId0+1];
double py1 = anim0._positionValues[pId1+1];
double pz0 = anim0._positionValues[pId0+2];
double pz1 = anim0._positionValues[pId1+2];

double pTimeDif = pTime1-pTime0;

// Interpolate Position
px_0 = px0 + pTimeDif * (px1-px0);
py_0 = py0 + pTimeDif * (py1-py0);
pz_0 = pz0 + pTimeDif * (pz1-pz0);



/*
 * Handle Rotation interpolation
 */


double rTime0 = anim0._rotationTimes.last;
double rTime1;// = anim0._positionTimes.last;
int rId0, rId1;

if(t > rTime0) {
rTime1 = anim0._animationTime + anim0._rotationTimes.first;
rId1 = 0;
rId0 = (anim0._rotationTimes.length -1);
} else {
rId0 = anim0._findRotationTimeIndex(t);
rId1 = rId0+1;
rTime1 = anim0._rotationTimes[rId1];
rTime0 = anim0._rotationTimes[rId0];
}
rId0 = rId0 << 2;
rId1 = rId1 << 2;


double rx0 = anim0._rotationValues[rId0];
double rx1 = anim0._rotationValues[rId1];
double ry0 = anim0._rotationValues[rId0+1];
double ry1 = anim0._rotationValues[rId1+1];
double rz0 = anim0._rotationValues[rId0+2];
double rz1 = anim0._rotationValues[rId1+2];
double rw0 = anim0._rotationValues[rId0+3];
double rw1 = anim0._rotationValues[rId1+3];

double rTimeDif = rTime1 - rTime0;

// Interpolate Position
rx_0 = rx0 + rTimeDif * ( rx1 - rx0);
ry_0 = ry0 + rTimeDif * ( ry1 - ry0);
rz_0 = rz0 + rTimeDif * ( rz1 - rz0);
rw_0 = rw0 + rTimeDif * ( rw1 - rw0);


/*
 * Handle Scale interpolation
 */

double sTime0 = anim0._scaleTimes.last;
double sTime1;
int sId0, sId1;

if(t > sTime0) {
sTime1 = anim0._animationTime + anim0._scaleTimes.first;
sId1 = 0;
sId0 = (anim0._scaleTimes.length -1);
} else {
sId0 = anim0._findScaleTimeIndex(t);
sId1 = sId0+1;
sTime0 = anim0._scaleTimes[sId0];
sTime1 = anim0._scaleTimes[sId1];
}
sId0 = sId0 << 2;
sId1 = sId1 << 2;


double sx0 = anim0._scaleValues[sId0];
double sx1 = anim0._scaleValues[sId1];
double sy0 = anim0._scaleValues[sId0+1];
double sy1 = anim0._scaleValues[sId1+1];
double sz0 = anim0._scaleValues[sId0+2];
double sz1 = anim0._scaleValues[sId1+2];

double sTimeDif = sTime1 - sTime0;

// Interpolate Position
sx_0 = sx0 + sTimeDif * ( sx1 - sx0);
sy_0 = sy0 + sTimeDif * ( sy1 - sy0);
sz_0 = sz0 + sTimeDif * ( sz1 - sz0);
}

{
double pTime0 = anim1._positionTimes.last;
double pTime1;// = anim1._positionTimes.last;
int pId0, pId1;


/*
 * Handle Position interpolation
 */

if(t > pTime0) {
pTime1 = anim1._animationTime + anim1._positionTimes.first;
pId1 = 0;
pId0 = (anim1._positionTimes.length -1);
} else {
pId0 = anim1._findPositionTimeIndex(t);
pId1 = pId0+1;
pTime0 = anim1._positionTimes[pId0];
pTime1 = anim1._positionTimes[pId1];
}
pId0 = pId0 << 2;
pId1 = pId1 << 2;


double px0 = anim1._positionValues[pId0];
double px1 = anim1._positionValues[pId1];
double py0 = anim1._positionValues[pId0+1];
double py1 = anim1._positionValues[pId1+1];
double pz0 = anim1._positionValues[pId0+2];
double pz1 = anim1._positionValues[pId1+2];

double pTimeDif = pTime1-pTime0;

// Interpolate Position
px_1 = px0 + pTimeDif * (px1-px0);
py_1 = py0 + pTimeDif * (py1-py0);
pz_1 = pz0 + pTimeDif * (pz1-pz0);



/*
 * Handle Rotation interpolation
 */

double rTime0 = anim1._rotationTimes.last;
double rTime1;// = anim1._positionTimes.last;
int rId0, rId1;

if(t > rTime0) {
rTime1 = anim1._animationTime + anim1._rotationTimes.first;
rId1 = 0;
rId0 = (anim1._rotationTimes.length -1);
} else {
rId0 = anim1._findRotationTimeIndex(t);
rId1 = rId0+1;
rTime1 = anim1._rotationTimes[rId1];
rTime0 = anim1._rotationTimes[rId0];
}
rId0 = rId0 << 2;
rId1 = rId1 << 2;


double rx0 = anim1._rotationValues[rId0];
double rx1 = anim1._rotationValues[rId1];
double ry0 = anim1._rotationValues[rId0+1];
double ry1 = anim1._rotationValues[rId1+1];
double rz0 = anim1._rotationValues[rId0+2];
double rz1 = anim1._rotationValues[rId1+2];
double rw0 = anim1._rotationValues[rId0+3];
double rw1 = anim1._rotationValues[rId1+3];

double rTimeDif = rTime1 - rTime0;

// Interpolate Position
rx_1 = rx0 + rTimeDif * ( rx1 - rx0);
ry_1 = ry0 + rTimeDif * ( ry1 - ry0);
rz_1 = rz0 + rTimeDif * ( rz1 - rz0);
rw_1 = rw0 + rTimeDif * ( rw1 - rw0);


/*
 * Handle Scale interpolation
 */

double sTime0 = anim1._scaleTimes.last;
double sTime1;
int sId0, sId1;

if(t > sTime0) {
sTime1 = anim1._animationTime + anim1._scaleTimes.first;
sId1 = 0;
sId0 = (anim1._scaleTimes.length -1);
} else {
sId0 = anim1._findScaleTimeIndex(t);
sId1 = sId0+1;
sTime0 = anim1._scaleTimes[sId0];
sTime1 = anim1._scaleTimes[sId1];
}
sId0 = sId0 << 2;
sId1 = sId1 << 2;


double sx0 = anim1._scaleValues[sId0];
double sx1 = anim1._scaleValues[sId1];
double sy0 = anim1._scaleValues[sId0+1];
double sy1 = anim1._scaleValues[sId1+1];
double sz0 = anim1._scaleValues[sId0+2];
double sz1 = anim1._scaleValues[sId1+2];

double sTimeDif = sTime1 - sTime0;

// Interpolate Position
sx_1 = sx0 + sTimeDif * ( sx1 - sx0);
sy_1 = sy0 + sTimeDif * ( sy1 - sy0);
sz_1 = sz0 + sTimeDif * ( sz1 - sz0);
}

//
// IMPLEMENT LERP HERE!
//

px = px_0 + lerp * ( px_1 - px_0);
py = py_0 + lerp * ( py_1 - py_0);
pz = pz_0 + lerp * ( pz_1 - pz_0);

rx = rx_0 + lerp * ( rx_1 - rx_0);
ry = ry_0 + lerp * ( ry_1 - ry_0);
rz = rz_0 + lerp * ( rz_1 - rz_0);
rw = rw_0 + lerp * ( rw_1 - rw_0);

sx = sx_0 + lerp * ( sx_1 - sx_0);
sy = sy_0 + lerp * ( sy_1 - sy_0);
sz = sz_0 + lerp * ( sz_1 - sz_0);



_scaleMatrix[0] = sx;
_scaleMatrix[5] = sy;
_scaleMatrix[10] = sz;
_scaleMatrix[15] = 1.0;

_positionMatrix[0] = 1.0;
_positionMatrix[5] = 1.0;
_positionMatrix[10] = 1.0;
_positionMatrix[12] = px;
_positionMatrix[13] = py;
_positionMatrix[14] = pz;
_positionMatrix[15] = 1.0;

double x = rx;
double y = ry;
double z = rz;
double w = rw;
double x2 = x + x;
double y2 = y + y;
double z2 = z + z;

double xx = x * x2;
double xy = x * y2;
double xz = x * z2;
double yy = y * y2;
double yz = y * z2;
double zz = z * z2;
double wx = w * x2;
double wy = w * y2;
double wz = w * z2;

_rotationMatrix[0] = 1.0 - (yy + zz);
_rotationMatrix[1] = xy + wz;
_rotationMatrix[2] = xz - wy;
_rotationMatrix[4] = xy - wz;
_rotationMatrix[5] = 1.0 - (xx + zz);
_rotationMatrix[6] = yz + wx;
_rotationMatrix[8] = xz + wy;
_rotationMatrix[9] = yz - wx;
_rotationMatrix[10] = 1.0 - (xx + yy);
_rotationMatrix[15] = 1.0;
}*/