part of animation;


abstract class SkeletonPoser {
  /// Poses [skeleton] using [animation] at time [t]. Posed skeleton
  /// is stored in [posedSkeleton].
  pose(Skeleton skeleton, SkeletonAnimation animation,
       PosedSkeleton posedSkeleton, double t);
  void poseLerp(Skeleton skeleton, SkeletonAnimation animation0, SkeletonAnimation animation1,
                PosedSkeleton posedSkeleton, double t0, double t1);
}