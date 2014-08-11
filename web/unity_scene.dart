import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'package:vector_math/vector_math.dart';
import 'package:harmony3d/harmony.dart';
import 'package:harmony3d/browser.dart';
import 'package:harmony3d/custom_behaviours.dart';
import 'package:harmony3d/src/terrain.dart';
import 'package:harmony_devices/box2d_device.dart';
import 'package:animator/animation.dart';
import 'package:harmony3d/shared.dart';



final CanvasElement front_buffer = querySelector('#frontBuffer');




void main() {
  front_buffer.onClick.listen((onData){
    front_buffer.requestFullscreen();
    front_buffer.height = 1200;
    front_buffer.width = 1920;
  });
  final box2d = new Box2dDevice();
  initHarmonyBrowser(front_buffer).then(onEngineStart);
}

void onEngineStart(_) {
	HttpRequest.getString('assets/L_FG_Assets_Pack_Lite/Demo/Demo6.scene');






  //Resources.loadAsync('assets/frogames_warriors_&_commoners/characters/animations/animation@walk1.anim').then((e) {
  //  print('done');
  //});
	Application.loadScene('assets/L_FG_assets_Pack_Lite/Demo/Demo6.scene').then(onSceneLoad);

  //Resources.loadAsync('assets/L_FG_assets_Pack_Lite/Demo/Demo6.scene').then(onSceneLoad);
}

void _figureLoad() {
  Mesh fatGuy;
  Texture tex;
  AnimationClip clip, clip2;
  var fut0 = Resources.loadAsync('assets/frogames_warriors_&_commoners/characters/animations/animation@idle1.anim').then((e) {
    clip = e;
    return e;
  });
  var fut3 = Resources.loadAsync('assets/frogames_warriors_&_commoners/characters/animations/animation@walk1.anim').then((e) {
    clip2 = e;
    return e;
  });
  var fut1 = Resources.loadAsync('assets/frogames_warriors_&_commoners/characters/muscular_character_b.mesh').then((e) {
    fatGuy = e;
    return e;
  });
  var fut2 = Resources.loadAsync('assets/frogames_warriors_&_commoners/characters/DemoCharacter1_texture.png').then((e) {
    tex = e;
    return e;
  });
  Future.wait([fut0,fut1,fut2,fut3]).then((e) {
    ///// Create Skinned Renderer

    var parent = new GameObject();
    var go = new GameObject();
    //go.transform.position = new Vector3(4.0,0.5,0.0);
    go.transform.scaleBy(0.025);
    go.addComponent(Rigidbody2D);
    //go.addComponent('GuyController');
    go.name = 'fat_guy';
    SkinnedMeshRenderer renderer = go.addComponent(SkinnedMeshRenderer);
    renderer.mesh = fatGuy;
    renderer.setAnimationTreeFromRootNode(new BlendByValue('idle_run_blender')..anims.addAll([clip.createAnimationNode(),clip2.createAnimationNode()]));
    //renderer.currentClip = clip;
    //renderer.currentClip2 = clip2;


    var shader = new Shader.fromGLSL(vsShader, fsShader, RenderPass.geometry, "animatedfigure");
    shader.compile();
    var mat = new CustomMaterial();
    mat.setTexture('MainTexture', tex);
    mat.shader = shader;
    renderer.material = mat;
    //print(e);
    parent.name = 'fat_parent';
    //parent.addChild(go);
    //parent.transform.scaleBy(0.15);
    Scene.current.root.addChild(go);

    //Scene.current.root.addChild(go);

  });
  Future.wait([Resources.loadAsync('assets/audio/sound/owl.wav')]).then(sceneSound);

}



void onSceneLoad(Scene scene) {
	print('scene started!');
  //Scene.current = scene;
  addFreeCamera(scene);
  //addCollision();
  //Engine.start();
  //_figureLoad();
  Future.wait([Resources.loadAsync('assets/audio/music/swarm.ogg'),
               Resources.loadAsync('assets/audio/music/shades.ogg'),
               Resources.loadAsync('assets/audio/music/delirium.ogg'),
               Resources.loadAsync('assets/audio/music/evil_bgm_0.ogg')]).then(playMusic);

}

void sceneSound(var sounds) {
  final soundObj0 = new GameObject('sound0');
  soundObj0.addComponent('AudioSource').clip = sounds[0];
  soundObj0.addComponent('AmbientSoundController');
  Scene.current.root.addChild(soundObj0);
}


void playMusic(var clips) {
  final box = new GameObject('musicbox');
  final musicbox = box.addComponent(AreaMusic) as AreaMusic;
  Audio.playMusic(clips[0]);
  musicbox.song1 = clips[0];
  musicbox.song2 = clips[1];
  musicbox.song3 = clips[2];
  musicbox.song4 = clips[3];
  Scene.current.root.addChild(box);
}
/*
var colliderList = [];
void addCollision() {
  for(int i=0; i < hlList.length; i+=2) {
    var go = new GameObject("Collider");
    PolygonCollider2D col = go.addComponent('PolygonCollider2D') as PolygonCollider2D;
    col.setToBox(hlList[i] / 2.0, hlList[i+1] / 2.0);
    col.position = new Vector2(centers[i], centers[i+1]);
    colliderList.add(col);
    Scene.current.root.addChild(go);

  }
}*/


void addFreeCamera(Scene scene) {
  var camParent = new GameObject('cameraParent');
  var cam = new GameObject('camera');
  var trans = cam.transform;
  trans.position = new Vector3(0.0,0.0,0.0);
  //cam.addComponent('TopDownCamera');

  cam.addComponent(AudioListener);
  var camera = cam.addComponent(Camera) as Camera;
  cam.addComponent(FreeCamera);
  //var debugCam = new GameObject('debugCam');
  //cam.addComponent('DebugScene');



  //scene.root.addChild(debugCam);
  camParent.addChild(cam);
  scene.root.addChild(camParent);
  camera.active = true;
}








num degToRad(num deg) => deg * (PI / 180.0);
num radToDeg(num rad) => rad * (180.0 / PI);



Quaternion quatFromDirectionVector(Vector3 vDirection) {
  // Step 1. Setup basis vectors describing the rotation given the input vector and assuming an initial up direction of (0, 1, 0)
  Vector3 vUp = new Vector3(0.0, 1.0, 0.0);           // Y Up vector
  Vector3 vRight = vUp.cross(vDirection);    // The perpendicular vector to Up and Direction
  vUp = vDirection.cross(vRight);            // The actual up vector given the direction and the right vector

  // Step 2. Put the three vectors into the matrix to bulid a basis rotation matrix
  // This step isnt necessary, but im adding it because often you would want to convert from matricies to quaternions instead of vectors to quaternions
  // If you want to skip this step, you can use the vector values directly in the quaternion setup below
  Matrix4 mBasis = new Matrix4(vRight.x, vRight.y, vRight.z, 0.0,
                              vUp.x, vUp.y, vUp.z, 0.0,
                              vDirection.x, vDirection.y, vDirection.z, 0.0,
                              0.0, 0.0, 0.0, 1.0);

  // Step 3. Build a quaternion from the matrix
  Quaternion qrot = new Quaternion.identity();
  qrot.w = sqrt(1.0 + mBasis.entry(0,0) + mBasis.entry(1,1) + mBasis.entry(2,2)) / 2.0;
  double dfWScale = qrot.w * 4.0;
  qrot.x = ((mBasis.entry(2,1) - mBasis.entry(1,2)) / dfWScale);
  qrot.y = ((mBasis.entry(0,2) - mBasis.entry(2,0)) / dfWScale);
  qrot.z = ((mBasis.entry(1,0) - mBasis.entry(0,1)) / dfWScale);

  return qrot;
}



String vsShader =
'''
precision highp float;
attribute vec3 POSITION;
attribute vec2 TEXCOORD0;
attribute vec3 NORMAL;
attribute vec4 WEIGHTS;
attribute vec4 BONES;
uniform mat4 MATRIX_MVP;
uniform mat4 MATRIX_P;
uniform mat4 BONE_MATRICES[120];
uniform vec3 vertexLightPos[4];
uniform vec3 vertexLightColor[4];
uniform vec4 vertexLightRange;
varying vec2 uv0;
varying vec3 vVertexLightFront;
mat4 transformSkinMat() {
 mat4 result = WEIGHTS.x * BONE_MATRICES[int(BONES.x)];
 result = result + WEIGHTS.y * BONE_MATRICES[int(BONES.y)];
 result = result + WEIGHTS.z * BONE_MATRICES[int(BONES.z)];
 return result;
}
vec3 ShadeVertexPointLights (
  vec4 lightPosX, vec4 lightPosY, vec4 lightPosZ,
  vec3 lightColor0, vec3 lightColor1, vec3 lightColor2, vec3 lightColor3,
  vec4 lightAttenSq, vec3 pos, vec3 normal) {

  // to light vectors
  vec4 toLightX = lightPosX - pos.x;
  vec4 toLightY = lightPosY - pos.y;
  vec4 toLightZ = lightPosZ - pos.z;
  // squared lengths
  vec4 lengthSq = vec4(0.0);
  lengthSq += toLightX * toLightX;
  lengthSq += toLightY * toLightY;
  lengthSq += toLightZ * toLightZ;
  // NdotL
  vec4 ndotl = vec4(0.0);
  ndotl += toLightX * normal.x;
  ndotl += toLightY * normal.y;
  ndotl += toLightZ * normal.z;
  // correct NdotL
  vec4 corr = sqrt(lengthSq);
  ndotl = max (vec4(0,0,0,0), ndotl * corr);
  // attenuation
  vec4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
  vec4 diff = ndotl * atten;
  // final color
  vec3 col = vec3(0.0);
  col += lightColor0 * diff.x;
  col += lightColor1 * diff.y;
  col += lightColor2 * diff.z;
  col += lightColor3 * diff.w;
  return col;
}
void main() {
 vec4 pos = vec4(POSITION, 1.0);
 mat4 skinMat = MATRIX_MVP * transformSkinMat();
 pos = skinMat * pos;
 uv0 = TEXCOORD0;
 vVertexLightFront = ShadeVertexPointLights(
  vec4(vertexLightPos[0].x,vertexLightPos[1].x,vertexLightPos[2].x,vertexLightPos[3].x),
  vec4(vertexLightPos[0].y,vertexLightPos[1].y,vertexLightPos[2].y,vertexLightPos[3].y),
  vec4(vertexLightPos[0].z,vertexLightPos[1].z,vertexLightPos[2].z,vertexLightPos[3].z),
  vertexLightColor[0],vertexLightColor[1],vertexLightColor[2],vertexLightColor[3],
  vertexLightRange,pos.xyz,NORMAL);
 gl_Position = pos;
}
''';
String fsShader =
'''
precision mediump float;

varying vec2 uv0;
varying vec3 vVertexLightFront;
uniform sampler2D MainTexture;
void main() {
 gl_FragColor = (texture2D (MainTexture, uv0) * vec4(0.5,0.7,0.9, 1.0));
 gl_FragColor.a = 1.0;
 //gl_FragColor = vec4(1.0);
}
''';
//