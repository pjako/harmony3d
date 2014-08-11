part of animation;



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
    BoneState boneState = posedSkeleton.boneStates[boneIndex];
    if (boneData != null) {
      boneState.setBoneMatrixAtTime(t, boneData, nodeTransform);
      //boneData.setBoneMatrixAtTime(t, nodeTransform);
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
      SkeletonAnimation animation0, SkeletonAnimation animation1, double lerp,
      PosedSkeleton posedSkeleton,
      double t0, double t1) {
    int boneIndex = bone.boneIndex;
    final Float32List nodeTransform = _scratchMatrix;
    final Float32List globalTransform =
        posedSkeleton.globalTransforms[boneIndex];
    BoneAnimation boneData0 = animation0.boneList[boneIndex];
    BoneAnimation boneData1 = animation1.boneList[boneIndex];
    BoneState boneState = posedSkeleton.boneStates[boneIndex];
    if (boneData0 != null) {
      //boneData.setBoneMatrixAtTime(t, nodeTransform);
      boneState.setBoneMatrixAtTimeLerp(t0,t1, boneData0, boneData1, lerp, nodeTransform);
    } else {
      for (int i = 0; i < 16; i++) {
        throw 'Something wrong';
        nodeTransform[i] = bone.localTransform[i];
      }
    }

    mul44(globalTransform, parentTransform, nodeTransform);
    for (int i = 0; i < bone.children.length; i++) {
      Bone childBone = bone.children[i];
      updateGlobalTransformLerp(childBone, globalTransform, animation0, animation1, lerp,
                            posedSkeleton, t0,t1);
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
    updateGlobalTransform(skeleton.boneList[0], parentTransform, animation, posedSkeleton, t);
    updateSkinningTransform(posedSkeleton, skeleton);
  }
  void poseLerp(Skeleton skeleton, SkeletonAnimation animation0, SkeletonAnimation animation1, double lerp,
      PosedSkeleton posedSkeleton, double t0, double t1) {
    Float32List parentTransform = new Float32List(16);
    parentTransform[0] = 1.0;
    parentTransform[5] = 1.0;
    parentTransform[10] = 1.0;
    parentTransform[15] = 1.0;
    updateGlobalTransformLerp(skeleton.boneList[0], parentTransform, animation0, animation1, lerp, posedSkeleton, t0, t1);
    updateSkinningTransform(posedSkeleton, skeleton);
  }
}