library animation2;
import 'dart:typed_data';
import 'dart:math' as Math;
import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math_operations.dart';


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

class AnimationNode implements AnimationTreeNode {
  String name = '';
  AnimationTree _tree;
  final SkeletonAnimation anim;
  WrapMode mode = WrapMode.loop;
  double currentPlayTime = 0.0;
  bool playingForward = true;
  double lastPlayTime = 0.0;
  AnimationNode(this.anim);
  Float32x4List generatePosRotScaleAtTimeSIMD(Float32x4List out, int boneIndex){

  }
  Float32List generatePosRotScaleAtTime(Float32List out, int boneIndex) {
    _generatePosRotScaleAtTime(currentPlayTime, anim.boneList[boneIndex],mode, out);
    //return anim.boneList[boneIndex].
  }

  void update(double dt) {
    currentPlayTime += dt;
    /*
    switch(mode) {
      case(WrapMode.loop):
        currentPlayTime += dt;
        if(currentPlayTime > anim.length) currentPlayTime -= anim.length;
        break;
    }*/
  }

  void register(AnimationTree tree) {

    tree._registerAnimationNode(this);
  }

}

abstract class AnimationTreeNode {
  String name;
  AnimationTree _tree;

  void register(AnimationTree tree);


}

abstract class BlendNode implements AnimationTreeNode {
  String name;
  void _animate(double t);
  List<BlendNode> get childNodes;


  void setValue(dynamic value) {

  }

  BoneAnimInstruction evaluate(double dt, int startBoneIndex, List<BoneAnimInstruction> instructions) {

  }

  void register(AnimationTree tree) {

    tree._registerAnimationNode(this);
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

  void register(AnimationTree tree) {

    tree._registerAnimationNode(this);
  }

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

  void update(double deltaTime, List<AnimationCompute> animc) {

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



  BoneAnimInstruction evaluate(double dt, int boneIndex, List<BoneAnimInstruction> instructions) {
    var floorVal = _scala.floorToDouble();
    var lerp = _scala - floorVal;
    int min = floorVal.toInt();
    int max = min+1;

    // No Lerp, so Animation Blending is not needed
    LerpBoneAnim lerp_ = new LerpBoneAnim();
    var anim0 = anims[min];
    var anim1 = anims[max];
    anim0.update(dt);
    anim1.update(dt);
    lerp_.startBoneIndex = boneIndex;
    lerp_.node0 = anim0;
    lerp_.node1 = anim1;
    lerp_.lerpValue = lerp;
    if(_tree._root == this) {
      instructions.add(lerp_);
    }
  }

  void register(AnimationTree tree) {

    tree._registerAnimationNode(this);
  }




}
//SimpleSkeletonPoser2 skeletonPoser = new SimpleSkeletonPoser2();


class BoneAnimInstruction {
  int startBoneIndex;


  void destroy() {
  }

  Float32x4List generatePosRotScaleAtTimeSIMD(int boneIndex, Float32x4List out) {

  }
  Float32List generatePosRotScaleAtTime(int boneIndex, Float32List out) {

  }
}

class SingleBoneAnim implements BoneAnimInstruction {
  int startBoneIndex;
  AnimationNode node;

  factory SingleBoneAnim() {
    if(_factory.isEmpty) return new SingleBoneAnim._();

  }
  SingleBoneAnim._();
  static final _factory = new List<SingleBoneAnim>();
  void destroy() {
    _factory.add(this);
  }

  Float32x4List generatePosRotScaleAtTimeSIMD(int boneIndex, Float32x4List out) {

  }
  Float32List generatePosRotScaleAtTime(int boneIndex, Float32List out) {
    return node.generatePosRotScaleAtTime(out, boneIndex);
  }
}
final poolPrs = new Float32List(12);
class LerpBoneAnim implements BoneAnimInstruction {
  int startBoneIndex;
  double lerpValue;
  AnimationNode node0;
  AnimationNode node1;

  factory LerpBoneAnim() {
    if(_factory.isEmpty) return new LerpBoneAnim._();

  }
  LerpBoneAnim._();
  static final _factory = new List<LerpBoneAnim>();
  void destroy() {
    _factory.add(this);
  }


  Float32x4List generatePosRotScaleAtTimeSIMD(double t, int boneIndex, Float32x4List out) {

  }
  Float32List generatePosRotScaleAtTime(int boneIndex, Float32List out) {
    return node0.generatePosRotScaleAtTime(out, boneIndex);
    node1.generatePosRotScaleAtTime(poolPrs, boneIndex);
    return lerpPosRotScale(out, poolPrs, lerpValue, out);
  }

}

class LerpBlend implements BoneAnimInstruction {
  int startBoneIndex;
  double lerpValue;
  BoneAnimInstruction instruction0;
  BoneAnimInstruction instruction1;

  factory LerpBlend() {
    if(_factory.isEmpty) return new LerpBlend._();

  }
  LerpBlend._();
  static final _factory = new List<LerpBlend>();
  void destroy() {
    _factory.add(this);
  }

  Float32x4List generatePosRotScaleAtTimeSIMD(double t, int boneIndex, Float32x4List out) {

  }
  Float32List generatePosRotScaleAtTime(double t, int boneIndex, Float32List out) {

  }
}
/*
class AnimationCompute {
  int boneStartIndex;
  AnimationTreeNode node;
  //Float32x4List generatePosRotScaleAtTimeSIMD(double t, Float32x4List out);
  //Float32List generatePosRotScaleAtTime(double t, Float32List out);
}*/


class PoseMode {
  final _i;
  const PoseMode(this._i);
  static const scala = const PoseMode(0);
  static const simd = const PoseMode(1);
}

final SkeletonPoser _skeletonPoser = new SimpleSkeletonPoser();
final SkeletonPoser _skeletonPoserSIMD = null;
class AnimationTree {
  PoseMode mode = PoseMode.scala;
  double _lastUpdate;
  final Map<String,AnimationTreeNode> _nodes = {};
  BlendNode _root;
  final List<BoneAnimInstruction> _animc = [];

  PosedSkeleton _posedSkeleton;
  PosedSkeleton get posedSkeleton => _posedSkeleton;
  //static final SkeletonPoser skeletonPoser;
  //static final SkeletonPoser skeletonPoserSIMD;
  Skeleton _skeleton;
  void set skeleton(Skeleton skel) {
    _skeleton = skel;
    _posedSkeleton = new PosedSkeleton(skel);
  }

  AnimationTree();

  AnimationTree.fromRoot(this._root, Skeleton skel) {
    skeleton = skel;
    _root.register(this);
  }

  void _registerAnimationNode(AnimationTreeNode node) {
    if(node.name == null || node.name == '') return;
    if(_nodes.containsKey(node.name)) return;
    node._tree = this;
    _nodes[node.name] = node;
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

  void evaluate(double gameTime) {
    if(_lastUpdate == null) {
      _lastUpdate = gameTime;
    }
    final dt = gameTime - _lastUpdate;
    _lastUpdate = gameTime;
    print(dt);
    for(var instuction in _animc) {
      instuction.destroy();
    }
    _animc.clear();
    _root.evaluate(dt, 0, _animc);
    if(_animc.isEmpty) return;
    switch(mode) {
      case(PoseMode.scala):
        _skeletonPoser.poseFromTree(_skeleton, _posedSkeleton, _animc);
        break;
      case(PoseMode.simd):
        break;
    }
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
double inverseLerp(double a, double b, double v) => (v - a) / (b - a);
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


Float32List _generatePosRotScaleAtTime(double t, BoneAnimation anim0, WrapMode mode, Float32List out) {
  Float32List array = out;
  double pTime0 = anim0.position._keyTimes.last;
  double pTime1;// = anim0.position._keyTimes.last;
  int pId0, pId1;
  //anim0.animationDuration

  /*
  switch(mode) {
    case(WrapMode.loop):

  }*/
  double time = t / anim0.animationDuration;
  double tFloor = time.floorToDouble();
  t = (time - tFloor) * anim0.animationDuration;
  /*
   * Handle Position interpolation
   */

  if(t > pTime0) {
    pTime1 = anim0.animationDuration + anim0.position._keyTimes.first;
    pId1 = 0;
    pId0 = (anim0.position._keyTimes.length -1);
  } else {
    pId0 = anim0.position._findTime(t);
    pId1 = pId0+1;
    pTime0 = anim0.position._keyTimes[pId0];
    if(anim0.position._keyTimes.length <= pId1) pId1 = pId0;
    pTime1 = anim0.position._keyTimes[pId1];
  }
  pId0 = pId0 << 2;
  pId1 = pId1 << 2;


  double px0 = anim0.position._values[pId0];
  double px1 = anim0.position._values[pId1];
  double py0 = anim0.position._values[pId0+1];
  double py1 = anim0.position._values[pId1+1];
  double pz0 = anim0.position._values[pId0+2];
  double pz1 = anim0.position._values[pId1+2];

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
      double m0 = anim0.position._tangentsOut[pId0] * dt;
      double m1 = anim0.position._tangentsIn[pId1]  * dt;
      px = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = py0;
      double value1 = py1;
      double m0 = anim0.position._tangentsOut[pId0+1] * dt;
      double m1 = anim0.position._tangentsIn[pId1+1]  * dt;
      py = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = pz0;
      double value1 = pz1;
      double m0 = anim0.position._tangentsOut[pId0+2] * dt;
      double m1 = anim0.position._tangentsIn[pId1+2]  * dt;
      pz = a * value0 + b * m0 + c * m1 + d * value1;
    }
  }
  double rTime0 = anim0.rotation._keyTimes.last;
  double rTime1;// = anim0.position._keyTimes.last;
  int rId0, rId1;

  if(t > rTime0) {
    rTime1 = anim0.animationDuration + anim0.rotation._keyTimes.first;
    rId1 = 0;
    rId0 = (anim0.rotation._keyTimes.length -1);
  } else {
    rId0 = anim0.rotation._findTime(t);
    rId1 = rId0+1;
    if(anim0.rotation._keyTimes.length <= rId1) rId1 = rId0;
    rTime1 = anim0.rotation._keyTimes[rId1];
    rTime0 = anim0.rotation._keyTimes[rId0];
  }

  rId0 = rId0 << 2;
  rId1 = rId1 << 2;


  double rx0 = anim0.rotation._values[rId0];
  double rx1 = anim0.rotation._values[rId1];
  double ry0 = anim0.rotation._values[rId0+1];
  double ry1 = anim0.rotation._values[rId1+1];
  double rz0 = anim0.rotation._values[rId0+2];
  double rz1 = anim0.rotation._values[rId1+2];
  double rw0 = anim0.rotation._values[rId0+3];
  double rw1 = anim0.rotation._values[rId1+3];

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
      double m0 = anim0.rotation._tangentsOut[rId0] * dt;
      double m1 = anim0.rotation._tangentsIn[rId1]  * dt;
      rx = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = ry0;
      double value1 = ry1;
      double m0 = anim0.rotation._tangentsOut[rId0+1] * dt;
      double m1 = anim0.rotation._tangentsIn[rId1+1]  * dt;
      ry = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = rz0;
      double value1 = rz1;
      double m0 = anim0.rotation._tangentsOut[rId0+2] * dt;
      double m1 = anim0.rotation._tangentsIn[rId1+2]  * dt;
      rz = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = rw0;
      double value1 = rw1;
      double m0 = anim0.rotation._tangentsOut[rId0+3] * dt;
      double m1 = anim0.rotation._tangentsIn[rId1+3]  * dt;
      rw = a * value0 + b * m0 + c * m1 + d * value1;
    }
  }
  /*
   * Handle Scale interpolation
   */

  double sTime0 = anim0.scale._keyTimes.last;
  double sTime1;
  int sId0, sId1;

  if(t > sTime0) {
    sTime1 = anim0.animationDuration + anim0.scale._keyTimes.first;
    sId1 = 0;
    sId0 = (anim0.scale._keyTimes.length -1);
  } else {
    sId0 = anim0.scale._findTime(t);
    sId1 = sId0+1;
    sTime0 = anim0.scale._keyTimes[sId0];
    if(anim0.scale._keyTimes.length <= sId1) sId1 = sId0;
    sTime1 = anim0.scale._keyTimes[sId1];
  }
  sId0 = sId0 << 2;
  sId1 = sId1 << 2;


  double sx0 = anim0.scale._values[sId0];
  double sx1 = anim0.scale._values[sId1];
  double sy0 = anim0.scale._values[sId0+1];
  double sy1 = anim0.scale._values[sId1+1];
  double sz0 = anim0.scale._values[sId0+2];
  double sz1 = anim0.scale._values[sId1+2];

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
      double m0 = anim0.scale._tangentsOut[sId0] * dt;
      double m1 = anim0.scale._tangentsIn[sId1]  * dt;
      sx = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = sy0;
      double value1 = sy1;
      double m0 = anim0.scale._tangentsOut[sId0+1] * dt;
      double m1 = anim0.scale._tangentsIn[sId1+1]  * dt;
      sy = a * value0 + b * m0 + c * m1 + d * value1;
    }
    {
      double value0 = sz0;
      double value1 = sz1;
      double m0 = anim0.scale._tangentsOut[sId0+2] * dt;
      double m1 = anim0.scale._tangentsIn[sId1+2]  * dt;
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

  double pTime0 = anim0.position._keyTimes.last;
  double pTime1;// = anim0.position._keyTimes.last;
  int pId0, pId1;

  if(t > pTime0) {
    pTime1 = anim0.animationDuration + anim0.position._keyTimes.first;
    pId1 = 0;
    pId0 = (anim0.position._keyTimes.length -1);
  } else {
    pId0 = anim0.position._findIndex(t);//.position._findIndex(t);
    pId1 = pId0+1;
    pTime0 = anim0.position._keyTimes[pId0];
    if(anim0.position._keyTimes.length <= pId1) pId1 = pId0;
    pTime1 = anim0.position._keyTimes[pId1];
  }
  pId0 = pId0 << 2;
  pId1 = pId1 << 2;


  double rTime0 = anim0.rotation._keyTimes.last;
  double rTime1;// = anim0.position._keyTimes.last;
  int rId0, rId1;

  if(t > rTime0) {
    rTime1 = anim0.animationDuration + anim0.rotation._keyTimes.first;
    rId1 = 0;
    rId0 = (anim0.rotation._keyTimes.length -1);
  } else {
    rId0 = anim0.rotation._findIndex(t);
    rId1 = rId0+1;
    if(anim0.rotation._keyTimes.length <= rId1) rId1 = rId0;
    rTime1 = anim0.rotation._keyTimes[rId1];
    rTime0 = anim0.rotation._keyTimes[rId0];
  }
  rId0 = rId0 << 2;
  rId1 = rId1 << 2;

  double sTime0 = anim0.scale._keyTimes.last;
  double sTime1;
  int sId0, sId1;

  if(t > sTime0) {
    sTime1 = anim0.animationDuration + anim0.scale._keyTimes.first;
    sId1 = 0;
    sId0 = (anim0.scale._keyTimes.length -1);
  } else {
    sId0 = anim0.scale._findIndex(t);
    sId1 = sId0+1;
    sTime0 = anim0.scale._keyTimes[sId0];
    if(anim0.scale._keyTimes.length <= sId1) sId1 = sId0;
    sTime1 = anim0.scale._keyTimes[sId1];
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
    var val0 = anim0.position._values4[pId0];
    var val1 = anim0.position._values4[pId1];
    final Float32x4 tangentOut = anim0.position._tangentsOut4[pId0];
    final Float32x4 tangentIn = anim0.position._tangentsIn4[pId1];
    out[0] = a * val0 + b * tangentOut + c  * tangentIn + d * val1;
  }
  {
    var val0 = anim0.rotation._values4[rId0];
    var val1 = anim0.rotation._values4[rId1];
    final Float32x4 tangentOut = anim0.rotation._tangentsOut4[rId0];
    final Float32x4 tangentIn = anim0.rotation._tangentsIn4[rId1];
    out[1] = a * val0 + b * tangentOut + c  * tangentIn + d * val1;
  }
  {
    var val0 = anim0.scale._values4[sId0];
    var val1 = anim0.scale._values4[sId1];
    final Float32x4 tangentOut = anim0.scale._tangentsOut4[sId0];
    final Float32x4 tangentIn = anim0.scale._tangentsIn4[sId1];
    out[2] = a * val0 + b * tangentOut + c  * tangentIn + d * val1;
  }

  return out;
}

class PosedSkeleton {
  final Skeleton skeleton;
  final Float32List skinningMatrices;
  final List<Float32List> globalTransforms;
  final List<Float32List> skinningTransforms;
  final List<Float32x4List> globalTransforms4;
  final List<Float32x4List> skinningTransforms4;
  final List<BoneState> boneStates;

  PosedSkeleton._internal(this.skeleton, int length) :
    skinningMatrices = new Float32List(length * 16),
    globalTransforms = new List<Float32List>(length),
    skinningTransforms = new List<Float32List>(length),
    globalTransforms4 = new List<Float32x4List>(length),
    skinningTransforms4 = new List<Float32x4List>(length),
    boneStates = new List.generate(length, (i) => new BoneState(i), growable: false){
    for (int i = 0; i < length; i++) {
      globalTransforms[i] = new Float32List(16);
      globalTransforms4[i] = new Float32x4List.view(globalTransforms[i].buffer);
      skinningTransforms[i] = new Float32List.view(skinningMatrices.buffer,
                                                   i*64, 16);
      skinningTransforms4[i] = new Float32x4List.view(skinningMatrices.buffer,
                                                      i*64, 4);
    }
  }

  factory PosedSkeleton(Skeleton skeleton) {
    return new PosedSkeleton._internal(skeleton, skeleton.boneList.length);
  }
}

class Skeleton {
  final String name;
  final Float32List globalOffsetTransform = new Float32List(16);
  Float32x4List globalOffsetTransform4;
  final List<Bone> boneList;
  final Map<String, Bone> bones = new Map<String, Bone>();
  Skeleton(this.name, int length) :
      boneList = new List<Bone>(length) {
    globalOffsetTransform4 = new Float32x4List.view(globalOffsetTransform.buffer);
  }
  Skeleton.fromList(this.name, this.boneList) {
    globalOffsetTransform4 = new Float32x4List.view(globalOffsetTransform.buffer);
  }
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

class AnimationState {
  Float32List evaluate(int boneId, double time) {

  }
}
class AnimationStateBlendAnimNode implements AnimationState {
  AnimationNode anim0, anim1;
  Float32List evaluate(int boneId, double time) {

  }
}


class BoneAnimation {
  final String boneName;
  final double animationDuration;
  final int boneIndex;
  final AnimationCurve4 position;
  final AnimationCurve4 rotation;
  final AnimationCurve4 scale;
  BoneAnimation(
      this.boneName,
      this.animationDuration,
      this.boneIndex,
      this.position,
      this.rotation,
      this.scale);

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

  factory AnimationCurve4.empty() {
    var tKeyTimes = new Float32List(1);
    final tValues = new Float32List(4);
    final tTanIn = new Float32List(4);
    final tTanOut = new Float32List(4);
    // Special case for quanternion
    tValues[3] = 1.0;
    return new AnimationCurve4._internal(
        4,
        tKeyTimes,
        tValues,
        tTanIn,
        tTanOut,
        new Float32x4List.view(tValues.buffer),
        new Float32x4List.view(tTanIn.buffer),
        new Float32x4List.view(tTanOut.buffer));
  }
  factory AnimationCurve4.scaleEmpty() {
    var tKeyTimes = new Float32List(1);
    final tValues = new Float32List(4);
    final tTanIn = new Float32List(4);
    final tTanOut = new Float32List(4);
    for(int i=0; i < 4; i++) tValues[i] = 1.0;
    // Special case for quanternion
    return new AnimationCurve4._internal(
        4,
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
    for(int i=0; i < leng4; i+=4) {
      for(int r=0; r < valuesPerVec4; r++) {
        tValues[i+r] = values[count];
        count++;
      }
    }

    final tInLength = tangentsIn.length ~/ leng;
    final tOutLength = tangentsOut.length ~/ leng;

    count = 0;
    if(tInLength == valuesPerVec4) {
      for(int i=0; i < leng4; i+=4) {
        for(int r=0; r < valuesPerVec4; r++) {
          tTanIn[i+r] = tangentsIn[count];
          count++;
        }
      }
    } else if(tInLength == 1) {
      for(int i=0; i < leng4; i+=4) {
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
      for(int i=0; i < leng4; i+=4) {
        for(int r=0; r < valuesPerVec4; r++) {
          tTanOut[i+r] = tangentsOut[count];
          count++;
        }
      }
    } else if(tOutLength == 1) {
      for(int i=0; i < leng4; i+=4) {
        for(int r=0; r < valuesPerVec4; r++) {
          tTanOut[i+r] = tangentsOut[count];
        }
        count++;
      }
    } else {
      if(valuesPerVec4 < 1) throw new Exception('Number of in tangents missmatches tangent values');
    }
    return new AnimationCurve4._internal(valuesPerVec4,
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

abstract class SkeletonPoser {
  /// Poses [skeleton] using [cAnim] at time [t]. Posed skeleton
  /// is stored in [posedSkeleton].
  void poseFromTree(Skeleton skeleton, PosedSkeleton posedSkeleton, List<AnimationCompute> cAnim);
}

class SimpleSkeletonPoser implements SkeletonPoser {
  final Float32List _scratchMatrix = new Float32List(16);

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

  final Vector3 pos = new Vector3.zero();

  void updateSkinningTransform(PosedSkeleton posedSkeleton, Skeleton skeleton) {
    for (int i = 0; i < skeleton.boneList.length; i++) {
      final Float32List globalTransform = posedSkeleton.globalTransforms[i];
      final Float32List skinningTransform = posedSkeleton.skinningTransforms[i];
      final Float32List offsetTransform = skeleton.boneList[i].bindPose;
      mul44(skinningTransform, globalTransform, offsetTransform);
      //mul44(skinningTransform, skeleton.globalOffsetTransform,skinningTransform);
    }
  }

  void poseFromTree(Skeleton skeleton, PosedSkeleton posedSkeleton, List<BoneAnimInstruction> cAnim) {
    Float32List parentTransform = new Float32List(16);
    parentTransform[0] = 1.0;
    parentTransform[5] = 1.0;
    parentTransform[10] = 1.0;
    parentTransform[15] = 1.0;
    updateGlobalTransformTree(skeleton.boneList[0], parentTransform, posedSkeleton, cAnim.removeAt(0), cAnim);
    updateSkinningTransform(posedSkeleton, skeleton);


  }

  void updateGlobalTransformTree(
      Bone bone,
      Float32List parentTransform,
      PosedSkeleton posedSkeleton,
      BoneAnimInstruction cAnim,
      List<BoneAnimInstruction> cAnimList) {
    int boneIndex = bone.boneIndex;
    final Float32List nodeTransform = _scratchMatrix;
    final Float32List globalTransform = posedSkeleton.globalTransforms[boneIndex];
    BoneState boneState = posedSkeleton.boneStates[boneIndex];
    boneState.setBoneMatrixAtTime(cAnim, nodeTransform);
    /*
    if (boneData != null) {
      boneState.setBoneMatrixAtTime(t, cAnim, nodeTransform);
      //boneData.setBoneMatrixAtTime(t, nodeTransform);
    } else {
      for (int i = 0; i < 16; i++) {
        throw 'Something wrong';
        nodeTransform[i] = bone.localTransform[i];
      }
    }*/

    mul44(globalTransform, parentTransform, nodeTransform);
    var nextAnimBoneIndex = cAnimList.isNotEmpty ? cAnimList.first.startBoneIndex : 9999;
    for (int i = 0; i < bone.children.length; i++) {
      Bone childBone = bone.children[i];
      if(nextAnimBoneIndex == i) {
        var l = cAnimList.getRange(1, cAnimList.length-1);
        updateGlobalTransformTree(childBone, globalTransform, posedSkeleton, cAnimList.first, l);
      }
      updateGlobalTransformTree(childBone, globalTransform, posedSkeleton, cAnim, cAnimList);
    }
  }
}

class BoneState {
  final int boneIndex;
  final Float32List _positionMatrix = new Float32List(16);
  final Float32List _rotationMatrix = new Float32List(16);
  final Float32List _scaleMatrix = new Float32List(16);

  Float32x4List _positionMatrix4;
  Float32x4List _rotationMatrix4;
  Float32x4List _scaleMatrix4;
  final Float32List posrotscale = new Float32List(12);

  BoneState(this.boneIndex);

  void setBoneMatrixAtTime(BoneAnimInstruction cAnim, Float32List boneMatrix) {
    cAnim.generatePosRotScaleAtTime(boneIndex, posrotscale);


    _scaleMatrix[0] =  posrotscale[8] > 0.0 ? 1.0 : -1.0;//scalex_1 + lerp * (scalex_1-scalex_0);//inverseLerp(scalex_0,scalex_1,lerp);
    _scaleMatrix[5] =  posrotscale[9] > 0.0 ? 1.0 : -1.0;//scaley_1 + lerp * (scaley_1-scaley_0);
    _scaleMatrix[10] = posrotscale[10] > 0.0 ? 1.0 : -1.0;//scalez_1 + lerp * (scalez_1-scalez_0);
    _scaleMatrix[15] = 1.0;

    _positionMatrix[0] = 1.0;
    _positionMatrix[5] = 1.0;
    _positionMatrix[10] = 1.0;
    _positionMatrix[12] = posrotscale[0];
    _positionMatrix[13] = posrotscale[1];
    _positionMatrix[14] = posrotscale[2];
    _positionMatrix[15] = 1.0;

    double x = posrotscale[4];//rotx_0 + lerp * (rotx_1-rotx_0);
    double y = posrotscale[5];//roty_0 + lerp * (roty_1-roty_0);
    double z = posrotscale[6];//rotz_0 + lerp * (rotz_1-rotz_0);
    double w = posrotscale[7];//rotw_0 + lerp * (rotw_1-rotw_0);
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
    Matrix44Operations.multiply(boneMatrix, 0, _scaleMatrix, 0, _rotationMatrix, 0);
    Matrix44Operations.multiply(boneMatrix, 0, _positionMatrix, 0, boneMatrix, 0);

  }
}
