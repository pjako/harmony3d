part of harmony;

/// A Collider defines a physical Collision of an object and is not rigid
class Collider extends Component {
	/// The Bounds of the Collider
  Aabb3 bounds;
  /// Is this a trigger?
  bool isTrigger;

  void onCollisionEnter(Collider collision) {}
  void onCollisionStay(Collider collision) {}
  void onCollisionExit(Collider collision) {}


  void onTriggerEnter(Collider collider) {}
  void onTriggerStay(Collider collider) {}
  void onTriggerExit(Collider collider) {}
}


class BoxCollider extends Collider {
  //Vector3 get size;
}


