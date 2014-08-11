library shared;
import 'package:harmony3d/harmony.dart';
import 'package:vector_math/vector_math.dart';
import 'package:mist/mist.dart';

class GuyController extends Component {
  double rt = 0.0;
  double ml = 1.0;
  final Vector3 cameraOffset = new Vector3(1.1739181280136108,23.34816551208496,11.043895721435547);

  void init() {
    Camera camera = Camera.current;
    //transform.localPosition = new Vector3(0.0,5.0,0.0);
    camera.transform.localPosition = cameraOffset;
    transform.position = new Vector3(0.0,0.748130798339844,0.0);
    camera.transform.localRotation = new Quaternion(0.5331676602363586,-0.019031694158911705,0.011998297646641731,0.8457103371620178).inverted();
    //(this.collider2d as CircleCollider2D).radius = 0.1;
    this.rigidbody2d.damping = 3.0;
  }

  void update() {
    // Collision Test START
    /*for(int i=0; i < collision.length; i+=8) {
      final p0 = new Vector3(collision[i],0.5,collision[i+1]);
      final p1 = new Vector3(collision[i+2],0.5,collision[i+3]);
      final p2 = new Vector3(collision[i+4],0.5,collision[i+5]);
      final p3 = new Vector3(collision[i+6],0.5,collision[i+7]);


      var col = new Vector4.zero() ..x = 1.0 ..w = 1.0;
      Debug.drawLine(p0,p1, col);
      Debug.drawLine(p1,p2, col);
      Debug.drawLine(p2,p3, col);
      Debug.drawLine(p3,p0, col);
      //Debug.drawLine(,, col);



      //Debug.drawLine(new Vector3(collision[i], 0.5, collision[i+1]), new Vector3(collision[i+2], 0.5, collision[i+3]), new Vector4.zero() ..x = 1.0 ..w = 1.0);
      //Debug.drawLine(new Vector3(collision[i+4], 0.5, collision[i+5]), new Vector3(collision[i+6], 0.5, collision[i+7]), new Vector4.zero() ..x = 1.0 ..w = 1.0);
      //Debug.drawLine(new Vector3(collision[i], 0.5, collision[i+1]), new Vector3(collision[i+2], 0.5, collision[i+3]), new Vector4.zero() ..x = 1.0 ..w = 1.0);
      //Debug.drawLine(new Vector3(collision[i], 0.5, collision[i+1]), new Vector3(collision[i+2], 0.5, collision[i+3]), new Vector4.zero() ..x = 1.0 ..w = 1.0);
      //col.points = [new Vector2(collision[i],collision[i+1]),new Vector2(collision[i+2],collision[i+3]),new Vector2(collision[i+4],collision[i+5]),new Vector2(collision[i+6],collision[i+7])];
      //Scene.current.root.addChild(go);
    }
    for(PolygonCollider2D collider in colliderList) {
      var l = collider.points;
      final p0 = new Vector3(l[0].x,0.5,l[0].y);
      final p1 = new Vector3(l[1].x,0.5,l[1].y);
      final p2 = new Vector3(l[2].x,0.5,l[2].y);
      final p3 = new Vector3(l[3].x,0.5,l[3].y);
      var col = new Vector4.zero() ..x = 1.0 ..w = 1.0;
      Debug.drawLine(p0,p1, col);
      Debug.drawLine(p1,p2, col);
      Debug.drawLine(p2,p3, col);
      Debug.drawLine(p3,p0, col);
    }*/
    /// END


    //transform.position = new Vector3(1.0,0.748130798339844,0.0);
    //print('this pos: ${transform.position}');
    //Debug.drawLine(new Vector3(1.0, 0.0, 0.0), new Vector3(1.0, 2.0, 0.0), new Vector4(1.0,0.0,0.0,0.0));
    //this.rigidbody2d.applyForce(new Vector2(0.0,0.1),new Vector2(0.0,0.0));
    //this.rigidbody2d.applyForce(new Vector2(0.0,0.1),new Vector2(0.0,0.0));
    //print(this.rigidbody2d.velocity);

    Camera camera = Camera.current;
    var offset = new Vector3(0.0,0.0,0.0);
    final pad = Input.getGamePad(0) as Gamepad;
    if(pad != null) {
      print(pad.id);
      print(pad.buttons);
      print(pad.axes);
    }

    if(Input.keyDown(Keyboard.S)) {
      //offset.y = -0.1;
    }
    if(Input.keyDown(Keyboard.W)) {
      //offset.y = 0.1;
    }
    if(Input.keyDown(Keyboard.D)) {
      rigidbody2d.applyForce(new Vector2(0.0,4.0),new Vector2(0.0,0.0));
      //offset.x = -0.1;
    }
    if(Input.keyDown(Keyboard.A)) {
      rigidbody2d.applyForce(new Vector2(0.0,-4.0),new Vector2(0.0,0.0));
      //offset.x = 0.1;
    }
    if(Input.keyDown(Keyboard.W)) {
      rigidbody2d.applyForce(new Vector2(4.0,0.0),new Vector2(0.0,0.0));
    }
    if(Input.keyDown(Keyboard.S)) {
      rigidbody2d.applyForce(new Vector2(-4.0,0.0),new Vector2(0.0,0.0));
    }
    //transform.translate(offset);
    //var guyPos = transform.position;
    //transform.position = guyPos.add(offset);//.add(offset);
    //print(camera.transform.position);

    final cameraParent = camera.gameObject;
    //print(cameraParent.transform.position);

    var cameraPos = cameraParent.transform.position;
    //print(cameraPos);
    //print(camera.gameObject.parent.name);
    //camera.transform.translate(offset);
    final newPos = this.gameObject.transform.position.add(offset);
    this.gameObject.transform.position = newPos;
    //print(transform.position);
    //newPos.scale(1.15);
    newPos.add(cameraOffset);
    //print(gameObject.name);
    //print(gameObject.parent.name);
    //print('localpos: ${transform.localPosition}');


    cameraParent.transform.position = newPos;//.add(offset);
    //transform.position = cameraPos.add(offset);
    //camera.transform.translate(offset);
    rt += ml * Time.deltaTime;
    if(rt > 1.0 || rt < 0.0) {
      ml *= -1.0;
      rt += 2.0 * ml * Time.deltaTime;
    }

    //print(cameraParent.transform.position.sub(transform.position));
    gameObject.updateBounds();

    //final vel3 = new Vector3(rigidbody2d.velocity.x,0.0,rigidbody2d.velocity.y);//.normalized();

    final velLength = rigidbody2d.velocity.length2;
    final SkinnedMeshRenderer skrenderer = (renderer as SkinnedMeshRenderer);
    if(velLength == 0.0) {
      skrenderer.setBlendNodeValue('idle_run_blender',0.0001);
    } else {
      double animState = velLength/2.0;
      if(animState > 0.9999) animState = 0.9999;
      skrenderer.setBlendNodeValue('idle_run_blender',animState);


      //   Vector3 mousePos = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 10);
      //   Vector3 lookPos = Camera.main.ScreenToWorldPoint(mousePos);
      //   lookPos = lookPos - transform.position;
      //   float angle = Mathf.Atan2(lookPos.y, lookPos.x) * Mathf.Rad2Deg;
      //   transform.rotation = Quaternion.AngleAxis(angle, Vector3.forward);
      //transform.localRotation = new Quaternion.axisAngle(new Vector3(0.0,1.0,0.0), atan2(rigidbody2d.velocity.x,rigidbody2d.velocity.y) * (360.0 / (PI * 2.0)));

      //var direction transform.position.normalized();
      //transform.localRotation = ;
      //print(rigidbody2d.velocity);
      final eulerRot = gameObject.parent.transform.localEulerAngles;
      if(rigidbody2d.velocity.x > 0.0) {
        eulerRot.y = 45.0;
        //gameObject.parent.transform.localRotation = eulerToQuat(_quat,eulerRot);
        //transform.rotateSlerpLocal(eulerToQuat(_quat,eulerRot), 0.1);
        //transform.localRotation =(new Quaternion.identity()..setEuler(40.0, 0.0, 0.0) ..normalized());
      }
      if(rigidbody2d.velocity.x < 0.0) {
        eulerRot.y = -45.0;
        //gameObject.parent.transform.localRotation = eulerToQuat(_quat,eulerRot);
        //transform.rotateSlerpLocal(eulerToQuat(_quat,eulerRot), 0.1);
        //transform.localRotation = ;
        //transform.localRotation =(new Quaternion.identity()..setEuler(-40.0, 0.0, 0.0) ..normalized());
      }
      if(rigidbody2d.velocity.y > 0.0) {
        eulerRot.y = 0.0;
        //gameObject.parent.transform.localRotation = eulerToQuat(_quat,eulerRot);
        //transform.rotateSlerpLocal(eulerToQuat(_quat,eulerRot), 0.1);
        //transform.localRotation =(new Quaternion.identity()..setEuler(220.0, 0.0, 0.0) ..normalized());
      }
      if(rigidbody2d.velocity.y < 0.0) {
        eulerRot.y = 90.0;
        //gameObject.parent.transform.localRotation = eulerToQuat(_quat,eulerRot);
        //transform.rotateSlerpLocal(eulerToQuat(_quat,eulerRot), 0.1);
        //transform.localRotation = ;
        //transform.localRotation =(new Quaternion.identity()..setEuler(180.0, 0.0, 0.0) ..normalized());
      }
      transform.lookAt(new Vector3(rigidbody2d.velocity.x,0.0,rigidbody2d.velocity.y), new Vector3(0.0,1.0,0.0));
       //quatFromDirectionVector(vel3).normalize(); //
    }
    //print( quatToEuler(new Vector3.zero(),eulerToQuat(_quat,new Vector3(0.0, 15.0,0.0))) );
    //final eulerRot = transform.localEulerAngles;
    //degCount += 1.0;
    //eulerRot.storage[1] = degCount;
    //print(eulerRot.storage[1]);
    //print(eulerRot);
    //_quat.setEuler(eulerRot.x,eulerRot.y + 0.001,eulerRot.z);
    //transform.localRotation = eulerToQuat(_quat,eulerRot);
    //var debugPos = transform.position;
    //print(debugPos);
    //Debug.drawCircle(debugPos, new Vector3(0.0,1.0,0.0), 1.0, new Vector4(0.0,1.0,0.0,1.0));


  }

  var degCount = 0.0;
  final _quat = new Quaternion.identity();
}



class TopDownCamera extends Component {
  GameObject _observe;
  final Vector3 _currentPos = new Vector3.zero();
  final Vector3 _observePos = new Vector3.zero();

  void init() {
    transform.localPosition = new Vector3(-1.3739179372787476,-27.748130798339844,-13.156107902526855);
    transform.localRotation = new Quaternion(0.5331676602363586,-0.019031694158911705,0.011998297646641731,0.8457103371620178);
  }


  void update() {
    //transform.getPosition(_currentPos);
    transform.translate(new Vector3(0.1,0.0,0.1));
    //_observe.transform.getPosition(_observePos);
    //_observePos.y = 0.0;
    //_observePos.setValues(1.0, -15.0, 1.0);
    //camera.active

    //_observePos.y = _observePos.y + 15.0;
    //transform.localPosition = _observePos;
    //transform.localRotation = new Quaternion.identity()
    //..setEuler(20.0, 40.0, 0.0);


  }

}

class AmbientSoundController extends Component {
  double _lastPlayed = 0.0;
  double playDistance = 0.0;
  double playDelay = 20.0;
  bool playing = false;
  static final Vector3 _camPos = new Vector3.zero();

  void update() {
    final currTime = Time.realTimeSinceStartup;
    if(playDistance <= 0.0) {
      // No distance dependency if distance is zero or smaller
      if(currTime-_lastPlayed > playDelay) {
        _lastPlayed = currTime;
        audio.play();
      }
    }

  }
}



class AreaMusic extends Component {
  var song1, song2, song3, song4;
  var _currentSong;
  final Vector3 _camPos = new Vector3.zero();
  void update() {
    final campos = Camera.current.transform.getPosition(_camPos);
    final x = campos.x;
    final y = campos.y;
    if(x > 0.0) {
      if(y > 0.0) {
        if(_currentSong != song1) {
          Audio.fadeInMusic(song1, 2.0, 3.0);
          _currentSong = song1;
        }
        //print('a');
      } else {
        if(_currentSong != song2) {
          Audio.fadeInMusic(song2, 2.0, 3.0);
          _currentSong = song2;
        }
        //print('b');
      }

    } else {
      if(y > 0.0) {
        if(_currentSong != song3) {
          Audio.fadeInMusic(song3, 2.0, 3.0);
          _currentSong = song3;
        }
        //print('c');
      } else {
        if(_currentSong != song4) {
          Audio.fadeInMusic(song4, 2.0, 3.0);
          _currentSong = song4;
        }
        //print('d');
      }

    }

  }
}