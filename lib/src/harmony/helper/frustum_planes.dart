part of harmony;

class _FrustumPlanes {
  final List<Plane> lrtb = new List<Plane>(4);
  final List<Plane> lrtbf = new List<Plane>(5);
  final Plane near = new Plane();
  final Plane far = new Plane();
  final Plane right = new Plane();
  final Plane left = new Plane();
  final Plane bottom = new Plane();
  final Plane top = new Plane();
  _FrustumPlanes() {
    lrtb[0] = lrtbf[0] = left;
    lrtb[1] = lrtbf[1] = right;
    lrtb[2] = lrtbf[2] = top;
    lrtb[3] = lrtbf[3] = bottom;
    lrtbf[4] = far;
  }
}
