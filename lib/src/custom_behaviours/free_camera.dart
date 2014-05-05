part of custom_behaviours;


class FreeCamera extends ScriptBehaviour {

  static final Quaternion delta = new Quaternion.identity();


  @Serialize(SerializeType.double)
  double sensitivityX = 15.0;
  @Serialize(SerializeType.double)
  double sensitivityY = 15.0;
  @Serialize(SerializeType.double)
  double minimumX = -360.0;
  @Serialize(SerializeType.double)
  double maximumX = 360.0;
  @Serialize(SerializeType.double)
  double minimumY = -60.0;
  @Serialize(SerializeType.double)
  double maximumY = 60.0;

  double _rotationX = 0.0;
  double _rotationY = 0.0;

  final Quaternion _originalRotation = new Quaternion.identity();
  final Quaternion _quat1 = new Quaternion.identity();
  final Quaternion _quat2 = new Quaternion.identity();
  static final Vector3 _up = new Vector3(0.0, 1.0, 0.0);
  static final Vector3 _negRight = new Vector3(-1.0, 0.0, 0.0);

  FreeCamera() {
  }

  void awake() {

  }

  void init() {
    transform.getLocalRotation(_originalRotation);
  }
  final Vector3 vec = new Vector3.zero();
  void update() {
    transform.getForwardLocal(vec);
    vec.normalize();
    if(Input.keyDown(Keyboard.UP)) {
      vec.scale(-0.2);
      transform.translate(vec);
      //vec.z -= 0.2;
    } else if(Input.keyDown(Keyboard.DOWN)) {
      vec.scale(0.2);
      transform.translate(vec);
      //vec.z += 0.2;
    }
    if(Input.keyDown(Keyboard.LEFT)) {
      transform.getRightLocal(vec);
      vec.normalize();
      vec.scale(-0.2);
      transform.translate(vec);
    } else if(Input.keyDown(Keyboard.RIGHT)) {
      transform.getRightLocal(vec);
      vec.normalize();
      vec.scale(0.2);
      transform.translate(vec);
    }
    if(Input.keyDown(Keyboard.O)) {
      transform.getUpLocal(vec);
      vec.normalize();
      vec.scale(-0.2);
      transform.translate(vec);
    } else if(Input.keyDown(Keyboard.L)) {
      transform.getUpLocal(vec);
      vec.normalize();
      vec.scale(0.2);
      transform.translate(vec);
    }
    print(transform.localPosition);
    //transform.translate(vec);
    if(Input.buttonUp(0)) return;
      // Read the mouse input axis
    _rotationX += /*Input.GetAxis("Mouse X")*/ Input.mouseXaxis * sensitivityX;
    _rotationY += /*Input.GetAxis("Mouse Y")*/ Input.mouseYaxis * sensitivityY;

    _rotationX = clampAngle(_rotationX, minimumX, maximumX);
    _rotationY = clampAngle(_rotationY, minimumY, maximumY);

    _quat1.setAxisAngle(_up, _rotationX);
    _quat2.setAxisAngle(_negRight, _rotationY);
    transform.localRotation /*localRotation*/ = multiplyQuat(multiplyQuat(_originalRotation,_quat1,_quat1),_quat2,_quat1);


  }
  void lateUpdate() {
    //gameObject.camera.debugDrawFrustum();



    //Debug.drawLine(new Vector3.zero(), new Vector3(0.0,1.0,0.0), new Vector4(1.0,0.0,0.0,1.0));
    //Debug.drawLine(new Vector3.zero(), new Vector3(0.0,0.0,1.0), new Vector4(1.0,0.0,0.0,1.0));
    //Debug.drawLine(new Vector3.zero(), transform.getForwardLocal(new Vector3.zero()).scale(5.0), new Vector4(1.0,0.0,0.0,1.0));
    //Debug.drawAABB(new Vector3(-1.0,-1.0,-1.0), new Vector3(1.0,1.0,1.0), new Vector4(1.0,0.0,0.0,1.0));
  }
}


double clampAngle (double angle, double min, double max) {
  if (angle < -360.0)
    angle += 360.0;
  if (angle > 360.0)
    angle -= 360.0;
  return clamp(angle, min, max);
}
double clamp(double number, double minVal, double maxVal) {
  if (number <= minVal) return minVal;
  if (maxVal <= number) return maxVal;
  return number;
}

Quaternion multiplyQuat(Quaternion q0, Quaternion q1, Quaternion out) {
  double _w = q0.storage[3];
  double _z = q0.storage[2];
  double _y = q0.storage[1];
  double _x = q0.storage[0];
  double ow = q1.storage[3];
  double oz = q1.storage[2];
  double oy = q1.storage[1];
  double ox = q1.storage[0];
  out.storage[0] = _w * ox + _x * ow + _y * oz - _z * oy;
  out.storage[1] = _w * oy + _y * ow + _z * ox - _x * oz;
  out.storage[2] = _w * oz + _z * ow + _x * oy - _y * ox;
  out.storage[3] = _w * ow - _x * ox - _y * oy - _z * oz;
  return out;
}



class FreeCamera2 extends Component {
  var mainSpeed = 100.0; //regular speed
  var shiftAdd = 250.0; //multiplied by how long shift is held.  Basically running
  var maxShift = 1000.0; //Maximum speed when holdin gshift
  var camSens = 0.25; //How sensitive it with mouse
  //var lastMouse = new Vector3(255.0, 255.0, 255.0); //kind of in the middle of the screen, rather than at the top (play)
  var lastMouseX = 255.0;
  var lastMouseY = 255.0;
  final _p = new Vector3.zero();
  var totalRun = 1.0;
  void update() {

    // Input.mouseClampX



    var lmX = (Input.mouseX) * camSens;
    var lmY = (Input.mouseY) * camSens;
    if(Input.buttonDown(0)) {
      //print(Input.mouseDx);
      transform.getEulerAngles(_p);
      _p.x = _p.x + lmX;
      _p.y = _p.y + lmY;
      _p.z = 0.0;
      transform.eulerAngles = _p;
    }
    lastMouseX = Input.mouseX;
    lastMouseY = Input.mouseY;
    //lastMouse = Input.mousePosition - lastMouse ;
    //lastMouse = Vector3(-lastMouse.y * camSens, lastMouse.x * camSens, 0 );
    //lastMouse = Vector3(transform.eulerAngles.x + lastMouse.x , transform.eulerAngles.y + lastMouse.y, 0);
    //transform.eulerAngles = lastMouse;
    //lastMouse =  Input.mousePosition;
    //Mouse & camera angle done.
    //Keyboard commands

    var f = 0.0;

    double x,y,z;
    x=y=z=0.0;

    if (Input.keyDown(Keyboard.W)) {
      z += 1.0;
      //p_Velocity += new Vector3(0, 0 , 1);
    }
    if (Input.keyDown(Keyboard.S)) {
      z += -1.0;
      //p_Velocity += new Vector3(0, 0 , -1);
    }
    if (Input.keyDown(Keyboard.A)) {
      x += -1.0;
      //p_Velocity += new Vector3(-1, 0 , 0);
    }

    if (Input.keyDown(Keyboard.D)) {
      x+= 1.0;
      //p_Velocity += new Vector3(1, 0 , 0);
    }


    //if (false/*Input.GetKey (KeyCode.LeftShift)*/){
        //totalRun += Time.deltaTime;
        //p  = p * totalRun * shiftAdd;
        //p.x = clamp(p.x, -maxShift, maxShift);
        //p.y = clamp(p.y, -maxShift, maxShift);
        //p.z = clamp(p.z, -maxShift, maxShift);
    //} else {
        totalRun = clamp(totalRun * 0.5, 1.0, 1000.0);
        x = x * mainSpeed;
        z = z * mainSpeed;
        //p = p * mainSpeed;
    //}

    x = x * Time.deltaTime;
    z = z * Time.deltaTime;

    //if (Input.keyDown(Keyboard.Space)){ //If player wants to move on X and Z axis only
    //    f = transform.position.y;
    //   transform.Translate(p);
    //    transform.position.y = f;
    //
    //} else {
    _p.x = x;
    _p.z = z;
     transform.translate( _p);
    //}
  }



  Vector3 GetBaseInput() { //returns the basic values, if it's 0 than it's not active.
    Vector3 p_Velocity;
    if (Input.keyDown(Keyboard.W)){
      p_Velocity += new Vector3(0, 0 , 1);
    }
    if (Input.keyDown(Keyboard.S)){
      p_Velocity += new Vector3(0, 0 , -1);
    }
    if (Input.keyDown(Keyboard.A)){
      p_Velocity += new Vector3(-1, 0 , 0);
    }

    if (Input.keyDown(Keyboard.D)){
      p_Velocity += new Vector3(1, 0 , 0);
    }

  return p_Velocity;

}
}


class FreeCamera3 extends Component {
  double mainSpeed = 100.0; //regular speed
  double shiftAdd = 250.0; //multiplied by how long shift is held.  Basically running
  double maxShift = 1000.0; //Maximum speed when holdin gshift
  double camSens = 0.25; //How sensitive it with mouse
  //Vector3 lastMouse = new Vector3(255, 255, 255); //kind of in the middle of the screen, rather than at the top (play)
  double lastMouseX = 255.0, lastMouseY = 255.0;
  double totalRun  = 1.0;
  Vector3 mouseTemp = new Vector3.zero();
  void Update () {
    lastMouseX = Input.mouseX.toDouble() - lastMouseX;
    lastMouseY = Input.mouseY.toDouble() - lastMouseY;
    //lastMouse = Input.mousePosition - lastMouse ;
    //lastMouse = new Vector3(-lastMouse.y * camSens, lastMouse.x * camSens, 0 );
    //lastMouse = new Vector3(transform.eulerAngles.x + lastMouse.x , transform.eulerAngles.y + lastMouse.y, 0);
    var euler = transform.eulerAngles;
    mouseTemp.x = -lastMouseY * camSens + euler.x;
    mouseTemp.y = lastMouseX * camSens + euler.y;
    transform.eulerAngles = mouseTemp;


    lastMouseX = Input.mouseX.toDouble();
    lastMouseY = Input.mouseY.toDouble();
    //Mouse & camera angle done.
    //Keyboard commands

    var f = 0.0;
    //var p = GetBaseInput();
    double px = 0.0;
    double py = 0.0;
    double pz = 0.0;
    if (Input.keyPressed (Keyboard.W)) {
      pz += 1;
    }
    if (Input.keyPressed (Keyboard.S)) {
      pz -= 1;
    }
    if (Input.keyPressed (Keyboard.A)) {
      pz += 1;
    }
    if (Input.keyPressed (Keyboard.D)) {
      pz -= 1;
    }

    if (false/*Input.keyPressed (Keyboard.LeftShift)*/){
      //totalRun += Time.deltaTime;
      //p  = p * totalRun * shiftAdd;
      //px = Mathf.Clamp(px * totalRun * shiftAdd, -maxShift, maxShift);
      //py = Mathf.Clamp(py * totalRun * shiftAdd, -maxShift, maxShift);
      //pz = Mathf.Clamp(pz * totalRun * shiftAdd, -maxShift, maxShift);
    } else {
      totalRun = clamp(totalRun * 0.5, 1.0, 1000.0);
      px = px * mainSpeed;
      py = py * mainSpeed;
      pz = pz * mainSpeed;
    }

    px = px * Time.deltaTime;
    py = py * Time.deltaTime;
    pz = pz * Time.deltaTime;
    transform.translate( new Vector3(px,py,pz));
    //if (Input.GetKey(KeyCode.Space)){ //If player wants to move on X and Z axis only
      //f = transform.position.y;
      //transform.Translate(p);
      //var pos = transform.position;
      //pos.y = f;
      //transform.position = pos;

    //} else {
    //  transform.Translate( new Vector3(px,py,pz));
    //}
  }
}
