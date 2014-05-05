library animation;
import 'dart:math' as Math;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math_operations.dart';


part 'src/animation/animation_tree.dart';
part 'src/animation/bone_state.dart';
part 'src/animation/animation_curve.dart';
part 'src/animation/skeleton.dart';
part 'src/animation/skeleton_poser.dart';
part 'src/animation/simple_skeleton_poser.dart';
part 'src/animation/posed_skeleton.dart';



class AnimationNode implements AnimationTreeNode {
  final SkeletonAnimation anim;
  double currentPlayTime;
  double lastPlayTime;
  AnimationNode(this.anim);

}

abstract class AnimationTreeNode {
  AnimationTree _tree;


}

abstract class BlendNode implements AnimationTreeNode {
  final String name = '';
  void _animate(double t);
  List<BlendNode> get childNodes;

  void setValue(dynamic value) {

  }
}

class SpeedBlendData {
  String name;
  AnimationNode anim;
  double speed;
}

class BlendBySpeed implements BlendNode {
  AnimationTree _tree;
  String name;
  double _speed = 0.0;
  final List<SpeedBlendData> blendData = [];
  BlendBySpeed(this.name);

  void setValue(dynamic val) {
    if(val is! num) return;
    _speed = val.toDouble();
  }

  void _animate(double t) {


    int idx=0, l = blendData.length;
    SpeedBlendData anim;
    if(l == 1) {
      _tree._playAnimation(blendData[0].anim, t);
      return;
    }
    while(l > idx) {
      anim = blendData[idx];
      if(anim.speed > _speed) {

        _tree._playAnimationLerp(blendData[idx-1].anim, anim.anim, t, lerp);
      }

    }
    _tree._playAnimation(anim.anim, t);
  }
}

class BlendByValue implements BlendNode {
  AnimationTree _tree;
  String name;
  BlendByValue(this.name);

  List<BlendNode> get childNodes => null;

  final List<AnimationNode> anims = [];
  double _scala = 0.0;
  double get value => _scala;
  void set value(double scaleVal) {
    if(scaleVal < 0.0) {
      _scala = 0.0;
      return;
    }
    double maxVal = (anims.length-1).toDouble();
    if(scaleVal > maxVal) {
      _scala = maxVal;
      return;
    }
    _scala = scaleVal;
  }
  void setValue(dynamic val) {
    if(value is! num) return;
    value = val.toDouble();
  }

  void _animate(double t) {
    var floorVal = _scala.floorToDouble();
    var lerp = _scala - floorVal;
    int min = floorVal.toInt();
    int max = min+1;

    // No Lerp, so Animation Blending is not needed
    if(lerp == 0.0) {
      _tree._playAnimation(anims[min], t);
      return;
    }
    _tree._playAnimationLerp(anims[min], anims[max], t, lerp);
  }

  void _animateRestricted(double t, int minBoneIndex, int maxBoneIdex) {
    var floorVal = _scala.floorToDouble();
    var lerp = _scala - floorVal;
    int min = floorVal.toInt();
    int max = min+1;

    // No Lerp, so Animation Blending is not needed
    if(lerp == 0.0) {

    }


  }




}
//SimpleSkeletonPoser2 skeletonPoser = new SimpleSkeletonPoser2();


class AnimationTree {
  final Map<String,BlendNode> _nodes = {};
  BlendNode _root;

  final PosedSkeleton posedSkeleton;
  final SkeletonPoser skeletonPoser;
  final Skeleton skeleton;

  AnimationTree(Skeleton skeleton_, [SkeletonPoser skeletonPoser_, PosedSkeleton posedSkeleton_]) : skeleton = skeleton_,
      posedSkeleton = posedSkeleton_ == null ? new PosedSkeleton(skeleton_) : posedSkeleton_,
      skeletonPoser = skeletonPoser_ == null ? new SimpleSkeletonPoser() : skeletonPoser_;

  AnimationTree.fromRoot(this._root, Skeleton skeleton_, [SkeletonPoser skeletonPoser_, PosedSkeleton posedSkeleton_])  : skeleton = skeleton_,
      posedSkeleton = posedSkeleton_ == null ? new PosedSkeleton(skeleton_) : posedSkeleton_,
      skeletonPoser = skeletonPoser_ == null ? new SimpleSkeletonPoser() : skeletonPoser_ {
    _addNode(_root);
  }

  void _addNode(BlendNode node) {
    node._tree = this;

    if(node.name != '' || node.name != null) {
      _nodes[node.name] = node;
    }
    var childs = node.childNodes;
    if(childs != null) {
      for(var child in childs) {
        _addNode(child);
      }
    }
  }

  void _playAnimation(AnimationNode node, double time) {
    var anim = node.anim;
    double length = anim.length;
    if(node.lastPlayTime == null) {
      node.lastPlayTime = time;
    }
    double playTime = time - node.lastPlayTime;
    switch(anim.wrapMode) {
      case(WrapMode.loop):
        if(playTime > length) {
          var tp = playTime/length;
          playTime = length * (tp - tp.floorToDouble());

        } else if(playTime < 0) {
          playTime = 0.0;
        }
        break;
    }
    skeletonPoser.pose(skeleton, anim, posedSkeleton, playTime);
  }
  void _playAnimationLerp(AnimationNode node0, AnimationNode node1, double time, double lerp) {
    var anim0 = node0.anim, anim1 = node1.anim;
    double t0 = _getPlayTime(node0,time), t1 = _getPlayTime(node1,time);
    skeletonPoser.poseLerp(skeleton, anim0, anim1, lerp, posedSkeleton, t0, t1);
  }
  double _getPlayTime(AnimationNode node, double time) {
    var anim = node.anim;
    double length = anim.length;
    if(node.lastPlayTime == null) {
      node.lastPlayTime = time;
    }
    double playTime = time - node.lastPlayTime;
    switch(anim.wrapMode) {
      case(WrapMode.loop):
        if(playTime > length) {
          var tp = playTime/length;
          playTime = length * (tp - tp.floorToDouble());

        } else if(playTime < 0) {
          playTime = 0.0;
        }
        break;
    }
    return playTime;
  }


  void animate(double time) {
    _root._animate(time);
  }
  void setNodeValue(String nodeName, dynamic value) {
    var node = _nodes[nodeName];
    if(node == null) throw 'Node $nodeName does not exist';
    node.setValue(value);
  }

  BlendNode queryNode(String nodeName) {
    return _nodes[nodeName];
  }
}

final Float32x4List _lPool0 = new Float32x4List(3);
final Float32x4List _lPool1 = new Float32x4List(3);
Float32x4List blendAnimeNodesSIMD(AnimationNode node0, AnimationNode node1, double t, Float32x4 lerpx4, int boneIndex, Float32x4List out) {
  var t0 = generatePosRotScaleAtTimeSIMD(t,node0.anim.boneList[boneIndex],_lPool0);
  var t1 = generatePosRotScaleAtTimeSIMD(t,node0.anim.boneList[boneIndex],_lPool1);
  return lerpPosRotScaleSIMD(t0,t1,lerpx4,out);
}
Float32x4List blendAnimeNodes(AnimationNode node0, AnimationNode node1, double t, double lerp, int boneIndex) {
  node0.anim.boneList[boneIndex];
}

class BoneAnimator {

}




class Bone {
  final String boneName;
  final Float32List bindPose;// = new Float32List(16);
  Float32x4List bindPose4;
  final List<Bone> children = new List<Bone>();
  final Bone parent;
  int boneIndex = -1;

  Bone(this.boneName, this.parent, Float32List this.bindPose, [bool hasBindPose = true]) {
    bindPose4 = new Float32x4List.view(bindPose.buffer);

    if (hasBindPose == false) {
      // Identify
      bindPose[0] = 1.0;
      bindPose[5] = 1.0;
      bindPose[10] = 1.0;
      bindPose[15] = 1.0;
    }
    if(parent != null) {
      parent.children.add(this);
    }
  }
}

class WrapMode {
  final int _w;
  static const once = const WrapMode(0);
  static const loop = const WrapMode(1);
  static const pingPong = const WrapMode(2);
  static const clampForever = const WrapMode(3);
  const WrapMode(this._w);

  static WrapMode parse(int i) {
    switch(i) {
      case(0):
        return once;
      case(1):
        return loop;
      case(2):
        return pingPong;
      case(3):
        return clampForever;
    }
    throw 'Wrap State does not exist';
  }
  static int serialize(WrapMode wrap) {
    switch(wrap) {
      case(WrapMode.once):
        return 0;
      case(WrapMode.loop):
        return 1;
      case(WrapMode.pingPong):
        return 2;
      case(WrapMode.clampForever):
        return 3;
    }
  }
}

/// Key frame animation data for an entire skeleton.
class SkeletonAnimation {
  final String name;
  final Map<String, BoneAnimation> boneAnimations =
      new Map<String, BoneAnimation>();
  final List<BoneAnimation> boneList;
  SkeletonAnimation(this.name, int length) :
    boneList = new List<BoneAnimation>(length);

  double length = 0.0;
  double timeScale = 1.0/24.0;
  WrapMode wrapMode = WrapMode.loop;

  bool boneHasAnimation(String boneName) {
    return boneAnimations[boneName] != null;
  }

  /// Animates [skeleton] to time [t] and updates [posedSkeleton].
  void poseSkeleton(double t, Skeleton skeleton, PosedSkeleton posedSkeleton) {
    throw new UnsupportedError('Implement me!');
  }
}


/// Key frame animation data for a single bone in a skeleton.
class BoneAnimation {
  final String boneName;
  final int boneIndex;
  double _animationTime;


  Float32List get positionTimes => _positionTimes;
  Float32List get positionValues => _positionValues;
  Float32List get rotationTimes => _rotationTimes;
  Float32List get rotationValues => _rotationValues;
  Float32List get scaleTimes => _scaleTimes;
  Float32List get scaleValues => _scaleValues;

  Float32List _positionTangentIn;
  Float32List _positionTangentOut;
  Float32List _rotationTangentIn;
  Float32List _rotationTangentOut;
  Float32List _scaleTangentIn;
  Float32List _scaleTangentOut;



  Float32List _positionTimes;
  Float32List _positionValues;

  Float32List _rotationTimes;
  Float32List _rotationValues;
  Float32List _scaleTimes;
  Float32List _scaleValues;



  Float32x4List positionValues4;
  Float32x4List rotationValues4;
  Float32x4List scaleValues4;

  Float32x4List _positionInTangent4;
  Float32x4List _positionOutTangent4;

  Float32x4List _rotationInTangent4;
  Float32x4List _rotationOutTangent4;

  Float32x4List _scaleInTangent4;
  Float32x4List _scaleOutTangent4;

  final Float32List _positionMatrix = new Float32List(16);
  final Float32List _rotationMatrix = new Float32List(16);
  final Float32List _scaleMatrix = new Float32List(16);

  Float32x4List _positionMatrix4;
  Float32x4List _rotationMatrix4;
  Float32x4List _scaleMatrix4;

  /// Construct bone animation with [boneName]. Animation key frames
  /// will be loaded from [positions], [rotations], and [scales].
  BoneAnimation(this.boneName,
                this._animationTime,
                this.boneIndex,
                Float32List positions,
                Float32List rotations,
                Float32List scales,
                Float32List positionTimes,
                Float32List rotationTimes,
                Float32List scaleTimes,
                Float32List positionsTangentIn,
                Float32List positionsTangentOut,
                Float32List rotationsTangentIn,
                Float32List rotationsTangentOut,
                Float32List scaleTangentIn,
                Float32List scaleTangentOut
                ) {
    updatePositions(positions, positionTimes, positionsTangentIn, positionsTangentOut);
    updateRotations(rotations, rotationTimes, rotationsTangentIn, rotationsTangentOut);
    updateScales(scales, scaleTimes, scaleTangentIn, scaleTangentOut);

    positionValues4 = new Float32x4List.view(_positionValues.buffer);
    rotationValues4 = new Float32x4List.view(_rotationValues.buffer);
    scaleValues4 = new Float32x4List.view(_scaleValues.buffer);

    _positionMatrix4 = new Float32x4List.view(_positionMatrix.buffer);
    _rotationMatrix4 = new Float32x4List.view(_rotationMatrix.buffer);
    _scaleMatrix4 = new Float32x4List.view(_scaleMatrix.buffer);
  }

  /// Makes bone have no position animation.
  void setNoPositionAnimation() {
    _positionTimes = new Float32List(1);
    _positionValues = new Float32List(4);

    _positionTangentIn = new Float32List(4);
    _positionTangentOut = new Float32List(4);

    _positionTimes[0] = 0.0;
    _positionValues[0] = 0.0;
    _positionValues[1] = 0.0;
    _positionValues[2] = 0.0;
    _positionValues[3] = 1.0;
    _positionTangentIn[0] = 0.0;
    _positionTangentIn[1] = 0.0;
    _positionTangentIn[2] = 0.0;
    _positionTangentIn[3] = 0.0;
    _positionTangentOut[0] = 0.0;
    _positionTangentOut[1] = 0.0;
    _positionTangentOut[2] = 0.0;
    _positionTangentOut[3] = 0.0;
  }

  /// Makes room for [length] position animation frames.
  /// All position animation frames will be zero.
  void setPositionAnimationLength(int length) {
    _positionTimes = new Float32List(length);
    _positionValues = new Float32List(length*4);
    _positionTimes[0] = 0.0;
    _positionValues[0] = 0.0;
    _positionValues[1] = 0.0;
    _positionValues[2] = 0.0;
    _positionValues[3] = 1.0;
  }

  /// Builds bone animation data from key frames in [positions].
  void updatePositions(Float32List positions, Float32List positionTimes, Float32List tangentIn, Float32List tangentOut) {
    if (positions == null || positions.length == 0) {
      setNoPositionAnimation();
      return;
    }
    int l = positions.length ~/ 3;
    _positionTimes = positionTimes;//new Float32List(positions.length);
    _positionValues = new Float32List(((positions.length~/3)*4));

    _positionTangentIn = new Float32List(((positions.length~/3)*4));
    _positionTangentOut = new Float32List(((positions.length~/3)*4));

    for (int i = 0; i < l; i++) {
      _positionValues[i*4+0] = positions[i*3+0];
      _positionValues[i*4+1] = positions[i*3+1];
      _positionValues[i*4+2] = positions[i*3+2];
      _positionValues[i*4+3] = 1.0;

      _positionTangentIn[i*4+0] = tangentIn[i*3+0];
      _positionTangentIn[i*4+1] = tangentIn[i*3+1];
      _positionTangentIn[i*4+2] = tangentIn[i*3+2];
      _positionTangentIn[i*4+3] = 1.0;

      _positionTangentOut[i*4+0] = tangentOut[i*3+0];
      _positionTangentOut[i*4+1] = tangentOut[i*3+1];
      _positionTangentOut[i*4+2] = tangentOut[i*3+2];
      _positionTangentOut[i*4+3] = 1.0;
    }
  }

  /// Makes bone have no rotation animation.
  void setNoRotationAnimation() {
    _rotationTimes = new Float32List(1);
    _rotationTangentIn = new Float32List(4);
    _rotationTangentOut = new Float32List(4);
    _rotationValues = new Float32List(4);
    _rotationTimes[0] = 0.0;
    _rotationValues[0] = 0.0;
    _rotationValues[1] = 0.0;
    _rotationValues[2] = 0.0;
    _rotationValues[3] = 1.0;
    _rotationTangentIn[0] = 0.0;
    _rotationTangentIn[1] = 0.0;
    _rotationTangentIn[2] = 0.0;
    _rotationTangentIn[3] = 0.0;
    _rotationTangentOut[0] = 0.0;
    _rotationTangentOut[1] = 0.0;
    _rotationTangentOut[2] = 0.0;
    _rotationTangentOut[3] = 0.0;
  }

  /// Makes room for [length] rotation animation frames.
  /// All rotation animation frames will be zero.
  void setRotationAnimationLength(int length) {
    _rotationTimes = new Float32List(length);
    _rotationValues = new Float32List(length*4);
    _rotationTimes[0] = 0.0;
    _rotationValues[0] = 0.0;
    _rotationValues[1] = 0.0;
    _rotationValues[2] = 0.0;
    _rotationValues[3] = 1.0;
  }

  /// Builds bone animation data from key frames in [rotations].
  void updateRotations(Float32List rotations, Float32List rotationsTimes, Float32List tangentIn, Float32List tangentOut) {
    if (rotations == null || rotations.length == 0) {
      setNoRotationAnimation();
      return;
    }
    _rotationTimes = rotationsTimes;
    _rotationValues = new Float32List(rotations.length*4);

    _rotationTangentIn = new Float32List(rotations.length*4);
    _rotationTangentOut = new Float32List(rotations.length*4);

    for (int i = 0; i < _rotationTimes.length; i++) {
      _rotationValues[i*4+0] = rotations[i*4+0];
      _rotationValues[i*4+1] = rotations[i*4+1];
      _rotationValues[i*4+2] = rotations[i*4+2];
      _rotationValues[i*4+3] = rotations[i*4+3];

      _rotationTangentIn[i*4+0] = tangentIn[i*4+0];
      _rotationTangentIn[i*4+1] = tangentIn[i*4+1];
      _rotationTangentIn[i*4+2] = tangentIn[i*4+2];
      _rotationTangentIn[i*4+3] = tangentIn[i*4+3];

      _rotationTangentOut[i*4+0] = tangentOut[i*4+0];
      _rotationTangentOut[i*4+1] = tangentOut[i*4+1];
      _rotationTangentOut[i*4+2] = tangentOut[i*4+2];
      _rotationTangentOut[i*4+3] = tangentOut[i*4+3];
    }
  }

  /// Makes bone have no scale animation.
  void setNoScaleAnimation() {
    _scaleTangentOut = new Float32List(4);
    _scaleTangentIn = new Float32List(4);
    _scaleTimes = new Float32List(1);
    _scaleValues = new Float32List(4);
    _scaleTimes[0] = 0.0;
    _scaleValues[0] = 1.0;
    _scaleValues[1] = 1.0;
    _scaleValues[2] = 1.0;
    _scaleValues[3] = 1.0;
    _scaleTangentOut[0] = 0.0;
    _scaleTangentOut[1] = 0.0;
    _scaleTangentOut[2] = 0.0;
    _scaleTangentOut[3] = 0.0;
    _scaleTangentIn[0] = 0.0;
    _scaleTangentIn[1] = 0.0;
    _scaleTangentIn[2] = 0.0;
    _scaleTangentIn[3] = 0.0;

  }

  /// Makes room for [length] scale animation frames.
  /// All scale animation frames will be zero.
  void setScaleAnimationLength(int length) {
    _scaleTimes = new Float32List(length);
    _scaleValues = new Float32List(length*4);
    _scaleTimes[0] = 0.0;
    _scaleValues[0] = 1.0;
    _scaleValues[1] = 1.0;
    _scaleValues[2] = 1.0;
    _scaleValues[3] = 1.0;
  }

  /// Builds bone animation data from key frames in [scales].
  void updateScales(Float32List scales, Float32List scalesTimes, Float32List tangentIn, Float32List tangentOut) {
    if (scales == null || scales.length == 0) {
      setNoScaleAnimation();
      return;
    }
    _scaleTimes = scalesTimes;
    _scaleValues = new Float32List(scales.length*4);

    _scaleTangentIn = new Float32List(scales.length*4);
    _scaleTangentOut = new Float32List(scales.length*4);

    for (int i = 0; i < _scaleTimes.length; i++) {
      _scaleValues[i*4+0] = scales[i*3+0];
      _scaleValues[i*4+1] = scales[i*3+1];
      _scaleValues[i*4+2] = scales[i*3+2];
      _scaleValues[i*4+3] = 1.0;

      _scaleTangentIn[i*4+0] = tangentIn[i*3+0];
      _scaleTangentIn[i*4+1] = tangentIn[i*3+1];
      _scaleTangentIn[i*4+2] = tangentIn[i*3+2];
      _scaleTangentIn[i*4+3] = 1.0;

      _scaleTangentOut[i*4+0] = tangentOut[i*3+0];
      _scaleTangentOut[i*4+1] = tangentOut[i*3+1];
      _scaleTangentOut[i*4+2] = tangentOut[i*3+2];
      _scaleTangentOut[i*4+3] = 1.0;
    }
  }

  int _findTime(Float32List timeList, double t) {
    for (int i = 0; i < timeList.length-1; i++) {
      if (t < timeList[i+1]) {
        return i;
      }
    }
    return 0;
  }

  int _findPositionIndex(double t) {
    return _findTime(_positionTimes, t) << 2;
  }

  int _findScaleIndex(double t) {
    return _findTime(_scaleTimes, t) << 2;
  }

  int _findRotationIndex(double t) {
    return _findTime(_rotationTimes, t) << 2;
  }

  int _findPositionTimeIndex(double t) {
    return _findTime(_positionTimes, t);
  }

  int _findScaleTimeIndex(double t) {
    return _findTime(_scaleTimes, t);
  }

  int _findRotationTimeIndex(double t) {
    return _findTime(_rotationTimes, t);
  }

  void buildTransformMatricesSIMD(Float32x4List posrotscale) {
    Float32x4List scaleTransform, posTransform;
    scaleTransform[0] = posrotscale[3];
    posTransform[3] = posrotscale[0];
    var rot = posrotscale[1];
    var rotSqrt = rot.sqrt();
    var rotSqrt2 = rot * rotSqrt;
    var xxx_xyz = rot.shuffle(Float32x4.XXXX) * rotSqrt2;
    var www_xyz = rot.shuffle(Float32x4.WWWW) * rotSqrt2;
    var yyz_yzz = rot.shuffle(Float32x4.YYZZ) * rotSqrt2.shuffle(Float32x4.YZZZ);


    double xx = xxx_xyz.x;
    double xy = xxx_xyz.y;
    double xz = xxx_xyz.z;

    double yy = yyz_yzz.x;
    double yz = yyz_yzz.y;
    double zz = yyz_yzz.z;

    double wx = www_xyz.x;
    double wy = www_xyz.y;
    double wz = www_xyz.z;
    _rotationMatrix[0] = 1.0 - (yy + zz);
    _rotationMatrix[1] = xy + wz;
    _rotationMatrix[2] = xy - www_xyz.y;
    _rotationMatrix[4] = xy - wz;
    _rotationMatrix[5] = 1.0 - (xx + zz);
    _rotationMatrix[6] = yz + wx;
    _rotationMatrix[8] = xz + wy;
    _rotationMatrix[9] = yz - wx;
    _rotationMatrix[10] = 1.0 - (xx + yy);
    _rotationMatrix[15] = 1.0;



  }

  void buildTransformMatricesAtTime(double t) {
    buildTransformMatricesAtTimeInterpolated(t);
    return;
    int positionIndex = _findPositionIndex(t);
    int rotationIndex = _findRotationIndex(t);
    int scaleIndex = _findScaleIndex(t);
    assert(positionIndex >= 0);
    assert(rotationIndex >= 0);
    assert(scaleIndex >= 0);

    double sx = _scaleValues[scaleIndex+0];
    double sy = _scaleValues[scaleIndex+1];
    double sz = _scaleValues[scaleIndex+2];

    _scaleMatrix[0] = sx;
    _scaleMatrix[5] = sy;
    _scaleMatrix[10] = sz;
    _scaleMatrix[15] = 1.0;

    _positionMatrix[0] = 1.0;
    _positionMatrix[5] = 1.0;
    _positionMatrix[10] = 1.0;
    _positionMatrix[12] = _positionValues[positionIndex+0];
    _positionMatrix[13] = _positionValues[positionIndex+1];
    _positionMatrix[14] = _positionValues[positionIndex+2];
    _positionMatrix[15] = 1.0;

    double x = _rotationValues[rotationIndex+0];
    double y = _rotationValues[rotationIndex+1];
    double z = _rotationValues[rotationIndex+2];
    double w = _rotationValues[rotationIndex+3];
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
  void buildTransformMatricesAtTimeInterpolated(double t) {
    double pTime0 = _positionTimes.last;
    double pTime1;// = _positionTimes.last;
    int pId0, pId1;


    /*
     * Handle Position interpolation
     */

    if(t > pTime0) {
      pTime1 = _animationTime + _positionTimes.first;
      pId1 = 0;
      pId0 = (_positionTimes.length -1);
    } else {
      pId0 = _findPositionTimeIndex(t);
      pId1 = pId0+1;
      pTime0 = _positionTimes[pId0];
      if(pId1 >= _positionTimes.length) {
        pId1 = pId0;
      }
      pTime1 = _positionTimes[pId1];
    }
    pId0 = pId0 << 2;
    pId1 = pId1 << 2;


    double px0 = _positionValues[pId0];
    double px1 = _positionValues[pId1];
    double py0 = _positionValues[pId0+1];
    double py1 = _positionValues[pId1+1];
    double pz0 = _positionValues[pId0+2];
    double pz1 = _positionValues[pId1+2];

    double pTimeDif = pTime1-pTime0;

    // Interpolate Position
    double px = px0 + pTimeDif * (px1-px0);
    double py = py0 + pTimeDif * (py1-py0);
    double pz = pz0 + pTimeDif * (pz1-pz0);



    /*
     * Handle Rotation interpolation
     */


    double rTime0 = _rotationTimes.last;
    double rTime1;// = _positionTimes.last;
    int rId0, rId1;

    if(t > rTime0) {
      rTime1 = _animationTime + _rotationTimes.first;
      rId1 = 0;
      rId0 = (_rotationTimes.length -1);
    } else {
      rId0 = _findRotationTimeIndex(t);
      rId1 = rId0+1;
      if(rId1 >= _positionTimes.length) {
        rId1 = rId0;
      }
      rTime1 = _rotationTimes[rId1];
      rTime0 = _rotationTimes[rId0];
    }
    rId0 = rId0 << 2;
    rId1 = rId1 << 2;


    double rx0 = _rotationValues[rId0];
    double rx1 = _rotationValues[rId1];
    double ry0 = _rotationValues[rId0+1];
    double ry1 = _rotationValues[rId1+1];
    double rz0 = _rotationValues[rId0+2];
    double rz1 = _rotationValues[rId1+2];
    double rw0 = _rotationValues[rId0+3];
    double rw1 = _rotationValues[rId1+3];

    double rTimeDif = rTime1 - rTime0;

    double rx, ry, rz, rw;

    {
      double t0 = rTime0;
      double t1 = rTime1;
      double t = t1 - t0;
      double dt = t;
      double t2 = t * t;
      double t3 = t2 * t;
      {
        double value0 = rx0;
        double value1 = rx1;
        t = dt / (t - t0);

        double m0 = _rotationTangentOut[rId0] * dt;
        double m1 = _rotationTangentIn[rId1]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + t;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        rx = a * value0 + b * m0 + c * m1 + d * value1;
      }
      {
        double value0 = ry0;
        double value1 = ry1;
        t = dt / (t - t0);

        double m0 = _rotationTangentOut[rId0+1] * dt;
        double m1 = _rotationTangentIn[rId1+1]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + t;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        ry = a * value0 + b * m0 + c * m1 + d * value1;
      }
      {
        double value0 = rz0;
        double value1 = rz1;
        t = dt / (t - t0);

        double m0 = _rotationTangentOut[rId0+2] * dt;
        double m1 = _rotationTangentIn[rId1+2]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + t;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        rz = a * value0 + b * m0 + c * m1 + d * value1;
      }
      {
        double value0 = rw0;
        double value1 = rw1;
        t = dt / (t - t0);

        double m0 = _rotationTangentOut[rId0+3] * dt;
        double m1 = _rotationTangentIn[rId1+3]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + t;
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

    double sTime0 = _scaleTimes.last;
    double sTime1;
    int sId0, sId1;

    if(t > sTime0) {
      sTime1 = _animationTime + _scaleTimes.first;
      sId1 = 0;
      sId0 = (_scaleTimes.length -1);
    } else {
      sId0 = _findScaleTimeIndex(t);
      sId1 = sId0+1;
      sTime0 = _scaleTimes[sId0];
      if(sId1 >= _positionTimes.length) {
        sId1 = sId0;
      }
      sTime1 = _scaleTimes[sId1];
    }
    sId0 = sId0 << 2;
    sId1 = sId1 << 2;


    double sx0 = _scaleValues[sId0];
    double sx1 = _scaleValues[sId1];
    double sy0 = _scaleValues[sId0+1];
    double sy1 = _scaleValues[sId1+1];
    double sz0 = _scaleValues[sId0+2];
    double sz1 = _scaleValues[sId1+2];

    double sx, sy, sz;


    {
      double t0 = sTime0;
      double t1 = sTime1;
      double sTimeDif = t1 - t0;
      double t = sTimeDif;
      double dt = t;
      double t2 = t * t;
      double t3 = t2 * t;
      {
        double value0 = sx0;
        double value1 = sx1;
        t = dt / (t - t0);

        double m0 = _scaleTangentOut[sId0] * dt;
        double m1 = _scaleTangentIn[sId1]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + t;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        sx = a * value0 + b * m0 + c * m1 + d * value1;
      }
      {
        double value0 = sy0;
        double value1 = sy1;
        t = dt / (t - t0);

        double m0 = _scaleTangentOut[sId0+1] * dt;
        double m1 = _scaleTangentIn[sId1+1]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + t;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        sy = a * value0 + b * m0 + c * m1 + d * value1;
      }
      {
        double value0 = sz0;
        double value1 = sz1;
        t = dt / (t - t0);

        double m0 = _scaleTangentOut[sId0+2] * dt;
        double m1 = _scaleTangentIn[sId1+2]  * dt;
        double a = 2.0 * t3 - 3.0 * t2 + 1.0;
        double b = t3 - 2.0 * t2 + t;
        double c = t3 - t2;
        double d = -2.0 * t3 + 3.0 * t2;

        sz = a * value0 + b * m0 + c * m1 + d * value1;
      }
    }

    // Interpolate Position
    //double sx = sx0 + sTimeDif * ( sx1 - sx0);
    //double sy = sy0 + sTimeDif * ( sy1 - sy0);
    //double sz = sz0 + sTimeDif * ( sz1 - sz0);



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
  }

  /// Set [boneMatrix] to correspond to bone animation at time [t].
  /// Does not interpolate between key frames.
  void setBoneMatrixAtTime(double t, Float32List boneMatrix) {
    buildTransformMatricesAtTime(t);

    Matrix44Operations.multiply(boneMatrix, 0, _scaleMatrix, 0, _rotationMatrix, 0);
    Matrix44Operations.multiply(boneMatrix, 0, _positionMatrix, 0, boneMatrix, 0);
  }

  /// Set [boneMatrix] to correspond to bone animation at time [t].
  /// Does not interpolate between key frames.
  void setBoneMatrixAtTimeSIMD(double t, Float32x4List boneMatrix) {
    buildTransformMatricesAtTime(t);

    Matrix44SIMDOperations.multiply(boneMatrix, 0, _scaleMatrix4, 0, _rotationMatrix4, 0);
    Matrix44SIMDOperations.multiply(boneMatrix, 0, _positionMatrix4, 0, boneMatrix, 0);
  }

  /// Set bone matrix [transform] to correspond to bone animation at time [t].
  /// Does interpolate between key frames.
  void setBoneMatrixAtTimeInterpolate(double t, Float32List transform) {
    throw new UnsupportedError('Implement me!');
  }
}









class SimpleSkeletonPoserXY implements SkeletonPoser {
  final Float32List _scratchMatrix = new Float32List(16);

  void mul44(Float32List out, Float32List a, Float32List b) {
    var a00 = a[0], a01 = a[1], a02 = a[2];//, a03 = a[3],
    var a10 = a[4], a11 = a[5], a12 = a[6];//, a13 = a[7],
    var a20 = a[8], a21 = a[9], a22 = a[10];//, a23 = a[11],
    var a30 = a[12], a31 = a[13], a32 = a[14];//, a33 = a[15];

    var b0  = b[0], b1 = b[1], b2 = b[2];//, b3 = b[3];
    out[0] = b0*a00 + b1*a10 + b2*a20;// + b3*a30;
    out[1] = b0*a01 + b1*a11 + b2*a21;// + b3*a31;
    out[2] = b0*a02 + b1*a12 + b2*a22;// + b3*a32;
    out[3] = 1.0;//b0*a03 + b1*a13 + b2*a23 + b3*a33;

    b0 = b[4]; b1 = b[5]; b2 = b[6];// b3 = b[7];
    out[4] = b0*a00 + b1*a10 + b2*a20;// + b3*a30;
    out[5] = b0*a01 + b1*a11 + b2*a21;// + b3*a31;
    out[6] = b0*a02 + b1*a12 + b2*a22;// + b3*a32;
    out[7] = 1.0;//b0*a03 + b1*a13 + b2*a23 + b3*a33;

    b0 = b[8]; b1 = b[9]; b2 = b[10];// b3 = b[11];
    out[8] = b0*a00 + b1*a10 + b2*a20;// + b3*a30;
    out[9] = b0*a01 + b1*a11 + b2*a21;// + b3*a31;
    out[10] = b0*a02 + b1*a12 + b2*a22;// + b3*a32;
    out[11] = 1.0;//b0*a03 + b1*a13 + b2*a23 + b3*a33;

    b0 = b[12]; b1 = b[13]; b2 = b[14];// b3 = b[15];
    out[12] = b0*a00 + b1*a10 + b2*a20;// + b3*a30;
    out[13] = b0*a01 + b1*a11 + b2*a21;// + b3*a31;
    out[14] = b0*a02 + b1*a12 + b2*a22;// + b3*a32;
    out[15] = 1.0;//b0*a03 + b1*a13 + b2*a23 + b3*a33;
    /*var a00 = a[0], a01 = a[1], a02 = a[2], a03 = a[3],
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
    out[15] = b0*a03 + b1*a13 + b2*a23 + b3*a33;*/
  }

  final Vector3 pos = new Vector3.zero();

  void updateGlobalTransform(
      Bone bone,
      Float32List parentTransform,
      SkeletonAnimation animation,
      PosedSkeleton posedSkeleton,
      double t) {
    int boneIndex = bone.boneIndex;
    final Float32List nodeTransform = _scratchMatrix;
    final Float32List globalTransform =
        posedSkeleton.globalTransforms[boneIndex];
    BoneAnimation boneData = animation.boneList[boneIndex];
    if (boneData != null) {
      boneData.setBoneMatrixAtTime(t, nodeTransform);
    } else {
      for (int i = 0; i < 16; i++) {
        throw 'Something wrong';
        nodeTransform[i] = bone.localTransform[i];
      }
    }

    mul44(globalTransform, parentTransform, nodeTransform);
    for (int i = 0; i < bone.children.length; i++) {
      Bone childBone = bone.children[i];
      updateGlobalTransform(childBone, globalTransform, animation,
                            posedSkeleton, t);
    }
  }
  void updateGlobalTransformLerp(
      Bone bone,
      Float32List parentTransform,
      SkeletonAnimation animation0, SkeletonAnimation animation1,
      PosedSkeleton posedSkeleton,
      double t) {
    int boneIndex = bone.boneIndex;
    final Float32List nodeTransform = _scratchMatrix;
    final Float32List globalTransform =
        posedSkeleton.globalTransforms[boneIndex];
    BoneAnimation boneData = animation.boneList[boneIndex];
    if (boneData != null) {
      boneData.setBoneMatrixAtTime(t, nodeTransform);
    } else {
      for (int i = 0; i < 16; i++) {
        throw 'Something wrong';
        nodeTransform[i] = bone.localTransform[i];
      }
    }

    mul44(globalTransform, parentTransform, nodeTransform);
    for (int i = 0; i < bone.children.length; i++) {
      Bone childBone = bone.children[i];
      updateGlobalTransform(childBone, globalTransform, animation,
                            posedSkeleton, t);
    }
  }

  void updateSkinningTransform(PosedSkeleton posedSkeleton, Skeleton skeleton) {
    for (int i = 0; i < skeleton.boneList.length; i++) {
      final Float32List globalTransform = posedSkeleton.globalTransforms[i];
      final Float32List skinningTransform = posedSkeleton.skinningTransforms[i];
      final Float32List offsetTransform = skeleton.boneList[i].bindPose;
      mul44(skinningTransform, globalTransform, offsetTransform);
      //mul44(skinningTransform, skeleton.globalOffsetTransform,skinningTransform);
    }
  }

  void pose(Skeleton skeleton, SkeletonAnimation animation,
      PosedSkeleton posedSkeleton, double t) {
    Float32List parentTransform = new Float32List(16);
    parentTransform[0] = 1.0;
    parentTransform[5] = 1.0;
    parentTransform[10] = 1.0;
    parentTransform[15] = 1.0;
    updateGlobalTransform(skeleton.boneList[0], parentTransform, animation,
                          posedSkeleton, t);
    updateSkinningTransform(posedSkeleton, skeleton);
  }
  void poseLerp(Skeleton skeleton, SkeletonAnimation animation0, SkeletonAnimation animation1,
      PosedSkeleton posedSkeleton, double t) {
    Float32List parentTransform = new Float32List(16);
    parentTransform[0] = 1.0;
    parentTransform[5] = 1.0;
    parentTransform[10] = 1.0;
    parentTransform[15] = 1.0;
    updateGlobalTransformLerp(skeleton.boneList[0], parentTransform, animation0, animation1,
                          posedSkeleton, t);
    updateSkinningTransform(posedSkeleton, skeleton);
  }
}



