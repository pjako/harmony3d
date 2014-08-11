part of animation;

/// Skeleton.
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
