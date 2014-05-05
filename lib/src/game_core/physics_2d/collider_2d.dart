part of game_core;

class Collision2D {
  Collider2D collider;
  GameObject gameObject;
  Transform transform;
  Vector2 velocity;
  List<ContactPoint2D> contactPoints;
}


class ContactPoint2D {
  Collision2D collider;
  Vector2 normal;
  Collision2D otherCollider;
  Vector2 point;
}




abstract class Collider2D extends Component {
  
  
  void _preInit() {
    if(gameObject._collider2d != null) {
      throw "Only one Collider2D per GameObject is allowed";
    }
    gameObject._collider2d = this;
  }


  void onCollisionEnter2D(Collision2D collision) {}
  void onCollisionStay2D(Collision2D collision) {}
  void onCollisionExit2D(Collision2D collision) {}


  void onTriggerEnter2D(Collider2D collider) {}
  void onTriggerStay2D(Collider2D collider) {}
  void onTriggerExit2D(Collider2D collider) {}


  bool get isTrigger;
  void set isTrigger(bool trigger);



  bool overlapPoint(Vector2 point) {
    throw new UnimplementedError();
  }

}


class PolygonCollider2D extends Collider2D {
  PolygonCollider _collider;
  List<Vector2> get points => _collider.points;
  var _tmpSavePoint;
  
  void _preInit() {
    super._preInit();
    _collider = new PolygonCollider(_physicsDevice2d);
  }
  
  void setPointsWithCentroid(List<Vector2> otherVertices, Vector2 centroid) {
    _collider.setFromWithCentroid(otherVertices, centroid);
  }
  
  void setToBox(double hx, double hy) {
    _collider.setToBox(hx, hy);
  }
  
  void set position(Vector2 pos) {
    _collider.position = pos;
  }
  
  
  
  void set points(List<Vector2> p) {
    if(_collider == null) {
      _tmpSavePoint = p;
    }
    _collider.points = p;
  }

  void set enabled(bool a) {
    _enabled = a;
    _collider.active = a;
  }

  bool get isTrigger => _collider.isTrigger;
  void set isTrigger(bool trigger) {
    _collider.isTrigger = trigger;
  }

  void _init() {
    enabled = true;
  }

  int addPath(List<Vector2> path) {
    throw new UnimplementedError();
  }
  bool overlapPoint(Vector2 point) {
    throw new UnimplementedError();
  }
}

class CircleCollider2D extends Collider2D {
  CircleCollider _collider;
  double get radius => _collider.radius;
  void set radius(double r) {
    _collider.radius = r;
  }
  Vector2 get center => _collider.center;
  void set center(Vector2 c) {
    _collider.center = c;
  }

  void set enabled(bool a) {
    _enabled = a;
    _collider.active = a;
  }

  bool get isTrigger => _collider.isTrigger;
  void set isTrigger(bool trigger) {
    _collider.isTrigger = trigger;
  }

  void _init() {
    _collider = new CircleCollider(_physicsDevice2d);
    enabled = true;
  }
}


class BoxCollider2D extends Collider2D {
  BoxCollider _collider;
  Vector2 get size => _collider.size;
  void set size(Vector2 s) {
    _collider.size = s;
  }
  Vector2 get center => _collider.center;
  void set center(Vector2 c) {
    _collider.center = c;
  }

  void set enabled(bool a) {
    _enabled = a;
    _collider.active = a;
  }

  bool get isTrigger => _collider.isTrigger;
  void set isTrigger(bool trigger) {
    _collider.isTrigger = trigger;
  }

  void _init() {
    _collider = new BoxCollider(_physicsDevice2d);
  }
}

class Rigidbody2D extends Component {
  RigidBody2d _rigid;

  void _init() {
    _owner._rigidbody2d = this;
    _rigid = new RigidBody2d(_physicsDevice2d);
  }

  Vector2 get position => _rigid.position;
  Vector2 get velocity => _rigid.velocity;
  void set velocity(Vector2 vel) {
    vel.copyInto(_rigid.velocity);
  }
  double get damping => _rigid.damping;
  void set damping(double d) {
    _rigid.damping = d;
  }

  void applyAngularImpulse(double imp) {
    _rigid.applyAngularImpulse(imp);
  }
  void applyForce(Vector2 force, Vector2 point) {
    _rigid.applyForce(force, point);
  }

  void update() {
    transform.position = new Vector3(position.x,transform.position.y,position.y);
  }


}
