part of game_core;

class RigidBody extends Collider {
  RigidBody3D _body;
  RigidBody() {
    _body = _physicsDevice3d.createRigidBody();
  }
  Vector3 get velocity => _body.velocity;
  double get damping => _body.damping;
  double get mass => _body.mass;
}