part of harmony;

class Collider extends Component {
  Aabb3 bounds;
  bool enabled;
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


