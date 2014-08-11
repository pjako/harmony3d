part of animation;

/*
  t  - in interval <0..1>
  p0 - Start position
  p1 - End position
  m0 - Start tangent
  m1 - End tangent
*/
double CubicHermite(double t, double p0, double p1, double m0, double m1) {
   var t2 = t*t;
   var t3 = t2*t;
   return (2*t3 - 3*t2 + 1)*p0 + (t3-2*t2+t)*m0 + (-2*t3+3*t2)*p1 + (t3-t2)*m1;
}

double inverseLerp(double a, double b, double v) => (v - a) / (b - a);

class AnimationCurve {
  Float32List _keyTimes;
  Float32List _values;
  Float32List _tangentsIn, _tangentsOut;

  /*
  double evaluate(double t) {
    int idx0 = 0;
    while(_keyTimes[idx0+1] < t) {
      idx0++;
    }
    int idx1 = idx0 + 1;
    double t0 = _keyTimes[idx0];
    double t1 = _keyTimes[idx1];
    // between 0.0 ... 1.0
    double timeScale = (Math.max(t0, t1) - Math.min(t0, t1)) / (t - t0);

    double v0 = _values[idx0];
    double v1 = _values[idx1];
    double tout = _tangentsOut[idx0];
    double tin = _tangentsIn[idx1];
    double tSquare = Math.sqrt(t);
    double tEnd = t*t1;
    return (2.0 * tEnd - 3.0 * tSquare + 1.0 ) * v0 + ( tEnd -2.0 * tSquare + t ) * tout + ( -2.0 * tEnd + 3.0 * tSquare ) * v1 + ( tEnd - tSquare ) * tin;
  }*/

  double evaluate(double t) {
    int idx0 = 0;
    while(_keyTimes[idx0+1] < t) {
      idx0++;
    }
    int idx1 = idx0 + 1;
    double t0 = _keyTimes[idx0];
    double t1 = _keyTimes[idx1];

    t = t1 - t0;

    double dt = t1 - t0;

    //t = Mathf.InverseLerp(keyframe0.time, keyframe1.time, time)
    t = dt / (t - t0);

    double m0 = _tangentsOut[idx0] * dt;
    double m1 = _tangentsIn[idx1]  * dt;

    double t2 = t * t;
    double t3 = t2 * t;

    double a = 2.0 * t3 - 3.0 * t2 + 1.0;
    double b = t3 - 2.0 * t2 + t;
    double c = t3 - t2;
    double d = -2.0 * t3 + 3.0 * t2;

    return a * _values[idx0] + b * m0 + c * m1 + d * _values[idx1];
  }
}


class BoneAnim {
  final AnimationCurve4 positon;
  final AnimationCurve4 rotation;
  final AnimationCurve4 scale;
  BoneAnim(this.positon, this.rotation, this.scale);
}

class AnimationCurve4 {
  final int valuesPerVector;
  final Float32List _keyTimes;
  final Float32List _values;
  final Float32List _tangentsIn, _tangentsOut;

  final Float32x4List _values4;
  final Float32x4List _tangentsIn4;
  final Float32x4List _tangentsOut4;

  int _findIndex(double t) {
    return _findTime(t) << 2;
  }
  int _findTime(double t) {
    for (int i = 0; i < _keyTimes.length-1; i++) {
      if (t < _keyTimes[i+1]) {
        return i;
      }
    }
    return 0;
  }

  factory AnimationCurve4.empty(int valuesPerVector) {
    var tKeyTimes = new Float32List(1);
    final tValues = new Float32List(valuesPerVector);
    final tTanIn = new Float32List(valuesPerVector);
    final tTanOut = new Float32List(valuesPerVector);
    // Special case for quanternion
    if(valuesPerVector == 4) {
      tValues[3] = 1.0;
    }
    return new AnimationCurve4._internal(
        valuesPerVector,
        tKeyTimes,
        tValues,
        tTanIn,
        tTanOut,
        new Float32x4List.view(tValues.buffer),
        new Float32x4List.view(tTanIn.buffer),
        new Float32x4List.view(tTanOut.buffer));
  }

  factory AnimationCurve4(Float32List keyTimes, Float32List values, Float32List tangentsIn, Float32List tangentsOut) {
    final leng = keyTimes.length;
    final leng4 = leng*4;
    final valuesPerVec4 = values.length / leng;
    if(valuesPerVec4 > 4) throw new Exception('Only 4 values per KeyFrame are allowed');
    if(valuesPerVec4 < 1) throw new Exception('At least one value per KeyFrame is required');

    final tValues = new Float32List(leng * 4);
    final tTanIn = new Float32List(leng * 4);
    final tTanOut = new Float32List(leng * 4);
    int count = 0;
    for(int i=0; i < leng4; i+4) {
      for(int r=0; r < valuesPerVec4; r++) {
        tValues[i+r] = values[count];
        count++;
      }
    }

    final tInLength = tangentsIn.length ~/ leng;
    final tOutLength = tangentsOut.length ~/ leng;

    count = 0;
    if(tInLength == valuesPerVec4) {
      for(int i=0; i < leng4; i+4) {
        for(int r=0; r < valuesPerVec4; r++) {
          tTanIn[i+r] = tangentsIn[count];
          count++;
        }
      }
    } else if(tInLength == 1) {
      for(int i=0; i < leng4; i+4) {
        for(int r=0; r < valuesPerVec4; r++) {
          tTanIn[i+r] = tangentsIn[count];
        }
        count++;
      }

    } else {
      if(valuesPerVec4 < 1) throw new Exception('Number of Out tangents missmatches tangent values');
    }
    count = 0;
    if(tOutLength == valuesPerVec4) {
      for(int i=0; i < leng4; i+4) {
        for(int r=0; r < valuesPerVec4; r++) {
          tTanOut[i+r] = tangentsOut[count];
          count++;
        }
      }
    } else if(tOutLength == 1) {
      for(int i=0; i < leng4; i+4) {
        for(int r=0; r < valuesPerVec4; r++) {
          tTanOut[i+r] = tangentsOut[count];
        }
        count++;
      }
    } else {
      if(valuesPerVec4 < 1) throw new Exception('Number of in tangents missmatches tangent values');
    }
    return new AnimationCurve4._internal(valuesPerVector,
        keyTimes,
        tValues,
        tTanIn,
        tTanOut,
        new Float32x4List.view(tValues.buffer),
        new Float32x4List.view(tTanIn.buffer),
        new Float32x4List.view(tTanOut.buffer));
  }
  AnimationCurve4._internal(this.valuesPerVector,this._keyTimes,this._values,this._tangentsIn,this._tangentsOut,this._values4,this._tangentsIn4,this._tangentsOut4);
}