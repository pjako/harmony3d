part of harmony;

class AnimationClip extends Asset {
  SkeletonAnimation _clip;
  AnimationClip();

  AnimationNode createAnimationNode() => new AnimationNode(_clip);

  AnimationClip.empty() {
    _clip = new SkeletonAnimation('empty',0);
  }
}

@HandlesAsset('anim')
class AnimationClipHandler extends AssetHandler {

  Asset create() => new AnimationClip();

  Asset load(String src, Loader loader) {
    AnimationClip asset = create();
    loader.getText(src).then((val) {
      Map map = JSON.decode(val);
      String name = map['name'];
      var frameRate = map['frameRate'];
      var keyframes = map['keyframe'];
      double length = map['length'];
      var positions = base64decoder.decode(keyframes['positions']);
      var rotations = base64decoder.decode(keyframes['rotations']);
      var scale = base64decoder.decode(keyframes['scale']);

      var positionKeyFrameTime = base64decoder.decode(keyframes['positionKeyframeTime']);
      var rotationKeyFrameTime = base64decoder.decode(keyframes['rotationKeyframeTime']);
      var scaleKeyFrameTime = base64decoder.decode(keyframes['scaleKeyframeTime']);

      var positionsTangentInList = base64decoder.decode(keyframes['positionsTangentIn']);
      var positionsTangentOutList = base64decoder.decode(keyframes['positionsTangentOut']);

      var rotationsTangentInList = base64decoder.decode(keyframes['rotationsTangentIn']);
      var rotationsTangentOutList = base64decoder.decode(keyframes['rotationsTangentOut']);

      var scaleTangentInList = base64decoder.decode(keyframes['scaleTangentIn']);
      var scaleTangentOutList = base64decoder.decode(keyframes['scaleTangentOut']);

      List positionKeyFrameCountList = keyframes['positionKeyframeCount'];
      List rotationKeyFrameCountList = keyframes['rotationKeyframeCount'];
      List scaleKeyFrameCountList = keyframes['scaleKeyframeCount'];

      int positionKeyFrameCountLength = positionKeyFrameCountList.length;
      int rotationKeyFrameCountLength = rotationKeyFrameCountList.length;
      int scaleKeyFrameCountLength = scaleKeyFrameCountList.length;
      List<String> bones = map['bones'];
      var boneCount = bones.length;
      //print(bones);

      int posOffset = 0;
      int rotOffset = 0;
      int scaleOffset = 0;

      var skelAnim = new SkeletonAnimation(name,boneCount);
      skelAnim.boneAnimations;

      for(int i=0;  bones.length > i; i++) {
        String boneName = bones[i];
        Float32List posKeyTimes;
        Float32List posKeys;
        Float32List rotKeyTimes;
        Float32List rotKeys;
        Float32List scaleKeyTimes;
        Float32List scaleKeys;

        Float32List posTangentIn;
        Float32List posTangentOut;

        Float32List rotTangentIn;
        Float32List rotTangentOut;

        Float32List scaleTangentIn;
        Float32List scaleTangentOut;

        if(positionKeyFrameCountLength > i) {
          int posKeyframeCount = positionKeyFrameCountList[i];
          if(posKeyframeCount > 0) {
            posKeyTimes = new Float32List.view(positionKeyFrameTime, posOffset*4, posKeyframeCount);

            posTangentIn = new Float32List.view(positionsTangentInList, posOffset*4*3, 3*posKeyframeCount);
            posTangentOut = new Float32List.view(positionsTangentOutList, posOffset*4*3, 3*posKeyframeCount);

            posKeys = new Float32List.view(positions, posOffset*4*3, 3*posKeyframeCount);
            posOffset += posKeyframeCount;
          }
        }
        if(rotationKeyFrameCountLength > i) {
          int rotKeyframeCount = rotationKeyFrameCountList[i];
          if(rotKeyframeCount > 0) {
            rotKeyTimes = new Float32List.view(rotationKeyFrameTime, rotOffset*4, rotKeyframeCount);

            rotTangentIn = new Float32List.view(rotationsTangentInList, rotOffset*4*4, 4*rotKeyframeCount);
            rotTangentOut = new Float32List.view(rotationsTangentOutList, rotOffset*4*4, 4*rotKeyframeCount);

            rotKeys = new Float32List.view(rotations, rotOffset*4*4, 4*rotKeyframeCount);
            rotOffset += rotKeyframeCount;
          }
        }
        if(scaleKeyFrameCountLength > i) {
          int scaleKeyframeCount = scaleKeyFrameCountList[i];
          if(scaleKeyframeCount > 0) {
            scaleKeyTimes = new Float32List.view(scaleKeyFrameTime, scaleOffset*4, scaleKeyframeCount);

            scaleTangentIn = new Float32List.view(scaleTangentInList, scaleOffset*4*3, 3*scaleKeyframeCount);
            scaleTangentOut = new Float32List.view(scaleTangentOutList, scaleOffset*4*3, 3*scaleKeyframeCount);

            scaleKeys = new Float32List.view(scale, scaleOffset*4*3, 3*scaleKeyframeCount);
            scaleOffset += scaleKeyframeCount;
          }
        }

        //var posKeyTimes = new Float32List.view(positionKeyFrameTime, posOffset*4, posKeyframeCount);

        //var posKeys = new Float32List.view(positions, posOffset*4*3, 3*posKeyframeCount);

        int index = bones.indexOf(boneName);
        AnimationCurve4 _posCurve;
        if(posKeyTimes != null) {
          _posCurve = new AnimationCurve4(posKeyTimes,posKeys,posTangentIn,posTangentOut);
        } else {
          _posCurve = new AnimationCurve4.empty();
        }
        var _rotCurve;
        if(rotKeyTimes != null) {
          _rotCurve = new AnimationCurve4(rotKeyTimes,rotKeys,rotTangentIn,rotTangentOut);
        } else {
          _rotCurve = new AnimationCurve4.empty();
        }

        print(scaleKeyTimes);
        AnimationCurve4 _scaleCurve;
        if(scaleKeyTimes != null) {
          _scaleCurve = new AnimationCurve4(scaleKeyTimes,scaleKeys,scaleTangentIn,scaleTangentOut);
        } else {
          _scaleCurve = new AnimationCurve4.scaleEmpty();
        }
        skelAnim.boneList[index] = new BoneAnimation(boneName,length,index,_posCurve,_rotCurve,_scaleCurve);

        /*
        int index = bones.indexOf(boneName);
        skelAnim.boneList[index] = new BoneAnimation(boneName,
            length,
            index,
            posKeys,
            rotKeys,
            scaleKeys,
            posKeyTimes,
            rotKeyTimes,
            scaleKeyTimes,
            posTangentIn,
            posTangentOut,
            rotTangentIn,
            rotTangentOut,
            scaleTangentIn,
            scaleTangentOut);
*/
      }

      //var animation = new SkeletonAnimation(name, boneCount);
      skelAnim.length = map['length']; // duration
      skelAnim.timeScale = 1.0 / map['frameRate'];//ticksPerSecond.toDouble();
      asset._clip = skelAnim;

      this.loadingDone(asset);
    });
    return asset;
  }
  Future<Asset> save(Asset asset, String src, var saveDevice) {

  }

  bool unload(Asset asset) {

  }
}


/*


void importAnimationFrames(SkeletonAnimation animation, int boneId, Map ba) {
  assert(boneId >= 0 && boneId < animation.boneList.length);
  assert(animation.boneList[boneId] == null);

  List positions = ba['positions'];
  List rotations = ba['rotations'];
  List scales = ba['scales'];

  BoneAnimation boneData = new BoneAnimation('', boneId, positions, rotations,
                                             scales);
  animation.boneList[boneId] = boneData;
}

void importAnimation(SkinnedMesh mesh, Map json) {
  String name = json['name'];
  assert(name != null);
  assert(name != "");
  num ticksPerSecond = json['ticksPerSecond'];
  num duration = json['duration'];
  assert(ticksPerSecond != null);
  assert(duration != null);
  var animation = new SkeletonAnimation(name, mesh.skeleton.boneList.length);
  animation.runTime = duration.toDouble();
  animation.timeScale = ticksPerSecond.toDouble();
  mesh.animations[name] = animation;
  mesh._currentAnimation = mesh.animations[name];
  json['boneAnimations'].forEach((ba) {
    Bone bone = mesh.skeleton.bones[ba['name']];
    if (bone == null) {
      _spectreLog.shout('Cannot find ${ba['name']}');
      return;
    }
    int id = bone._boneIndex;
    importAnimationFrames(animation, id, ba);
  });
}*/