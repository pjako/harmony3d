part of animation;

/// Skeleton ready to be used for skinning.
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