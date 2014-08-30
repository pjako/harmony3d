library terrain;
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:harmony3d/harmony.dart';
import 'package:vector_math/vector_math.dart';
import 'package:mist/mist.dart';


@HandlesAsset('terrainData')
class TerrainDataHandler extends AssetHandler {
  Asset create() => new TerrainData();

  Asset load(String src, Loader loader) {
    var terrain = create();
    loader.getText(src).then((onValue) {
      Map map = JSON.decode(onValue);
      List<Future> wait = [];

      var height = Resources.load(map['height']);
      height.dependsOnThis(terrain);
      if(!height.isLoaded) wait.add(height.notifyOnLoad());

      var control = Resources.load(map['control']);
      control.dependsOnThis(terrain);
      if(!control.isLoaded) wait.add(control.notifyOnLoad());

      List<Texture> splats = [];
      List sps = map['splat'];
      int l = sps.length;
      terrain._splats = new List<Texture>(l);

      for(int i=0; i < l; i++) {
        var splatSrc = sps[i];
        if(splatSrc == 'null') continue;
        var splat = Resources.load(splatSrc);
        if(!splat.isLoaded) wait.add(splat.notifyOnLoad());
        terrain._splats[i] = splat;
      }

      terrain._scale = map['scale'];
      terrain._layer = map['layer'];
      terrain._size = map['size'];

      terrain._controlMap = control;
      terrain._heightMap = height;
      if(wait.isEmpty) {
        loadingDone(terrain);
        return;
      }

      Future.wait(wait).then((_) {
        loadingDone(terrain);
      });
    });
    return terrain;
  }
  bool unload(Asset asset) {
    return true;
  }
  Future store(Asset asset, String src, saveDevice) {
  }
}

class TerrainData extends Asset {
  int _size, _scale, _layer;
  List<Texture> _splats;
  Float32List heightMapSize;
  Float32List controlMapSize;
  Texture _controlMap;
  Texture _heightMap;

}



class Terrain extends CustomRenderer {
  Float32List _offsets;// = new Float32List(layer * 2);
  Float32List _scales;// = new Float32List(layer);
  //Float32List _terrainSize = new Float32List.fromList([200.0,200.0,600.0]);
  Float32List _terrainMinMax = new Float32List.fromList([-100.0,-100.0,100.0,100.0]);
  Float32List _sizeHeightMap = new Float32List.fromList([512.0,512.0]);

  @Serialize(SerializeType.object,customName: 'lightmap')
  Texture _lightMap;
  int _layer = 10;
  double _scale = 1.0;
  @Serialize(SerializeType.object,customName: 'terrainData')
  TerrainData _data;
  TerrainData get terrainData => _data;
  /*
   *
   */
  Terrain() {
    bounds = new Aabb3.minmax(new Vector3(-200.0,-200.0,-200.0),new Vector3(200.0,200.0,200.0));
    var mat = new Material()
    ..shader = _terrainShader;
    super.material = mat;
  }

  void set terrainData(TerrainData v) {
    _data = v;
    init();
  }

  Float32List heights;
  bool _isReady = false;

  bool get isReady {
   return _data != null;
  }

  void init() {
    this.transform.position = new Vector3.zero();
    if(_data != null) {
      if(_data.isLoaded) {
        if(_isReady == true) return;
        _isReady = true;
        print("start Terrain");
        super.mesh = _getTerrainMesh(_scale, _layer);
        Material mat = super.material;

        _offsets = new Float32List(_layer * 2);
        _scales = new Float32List(_layer);
        mat.setConstant('terrainMinMax', _terrainMinMax);
        mat.setConstant('size_HeightMap', _sizeHeightMap);
        mat.setConstant('offsets[0]', _offsets);
        mat.setConstant('scales[0]', _scales);
        mat.setTexture('_HeightMap', _data._heightMap);
        mat.setTexture('_Control', _data._controlMap);
        mat.setTexture('_LightMap', _lightMap);
        print(_data._splats);
        for(int i=0; i < _data._splats.length; i++) {
          mat.setTexture('_Splat$i', _data._splats[i]);
        }
        if(isReadyToRender != true) isReadyToRender = true;

      }
    }
  }

  static final Vector3 _pos = new Vector3.zero();
  void renderUpdate(Camera camera) {
    var baseScale = _scale;
    // At this state the camera Transform is always up to date
    var camPos = camera.transform.getPosition(_pos);
    double x = camPos.x;
    double y = camPos.y;
    double z = camPos.z;
    var scale_ = baseScale * pow(2.0,(log(max(1.0, y / 2000.0)) / LN2).floorToDouble());
    for(int i=0; i < _layer; i++) {
      int idx = i * 2;
      double doubleScale = scale_ * 2.0;
      _offsets[idx] = ((x / doubleScale).floorToDouble() + 0.5) * doubleScale;
      _offsets[idx+1] = ((z / doubleScale).floorToDouble() + 0.5) * doubleScale;
      _scales[i] = scale_;
      scale_ *= 2.0;
    }
  }

  void set mesh(v) {}
  Mesh get mesh => null;
}


final Map<String,EditableMesh> _terrainMeshes = {};

EditableMesh _getTerrainMesh(double scale, int layer) {
  String hash = '$scale : $layer';
  if(_terrainMeshes.containsKey(hash)) {
    return _terrainMeshes[hash];
  }

  bool terrainhq = false;
  double baseScale;
  int numLayers;
  int ringWidth;
  if(terrainhq) {
    baseScale = scale;//0.5;
    numLayers = layer;
    ringWidth = 15;
  } else {
    baseScale = scale;//1.0;
    numLayers = layer;
    ringWidth = 7;
  }



  var pos2 = [];

  List<int> idx = new List<int>();
  var posn = [];
  var RING_WIDTH = ringWidth;
  var ringSegments = [
    [  1,  0,  0,  1 ],
    [  0, -1,  1,  0 ],
    [ -1,  0,  0, -1 ],
    [  0,  1, -1,  0 ]
  ];
  //double minX, minY, maxX,
  var scale_ = baseScale;
  for(int layer=0; layer < numLayers; layer++) {
    var nextLayer = min(layer + 1, numLayers - 1);
    for(var segment in ringSegments) {
      var rowStart = [];
      var segStart = layer > 0 ? RING_WIDTH + 0 : 0;
      var segWidth = layer > 0 ? RING_WIDTH + 1 : RING_WIDTH * 2 + 1;
      var segLength = layer > 0 ? RING_WIDTH * 3 + 1 : RING_WIDTH * 2 + 1;
      for( int i=0; i <=segLength; i++) {
        rowStart.add( (posn.length ~/ 3));
        var modeli = segStart - i;
        //Draw main part of ring.
        //TODO: Merge vertices between segments.
        for(int j=0; j <= segWidth; j++) {
          var modelj = segStart + j;
          var segi = segment[0] * modeli + segment[1] * modelj;
          var segj = segment[2] * modeli + segment[3] * modelj;
          //pos2.add(segj + 128);
          //pos2.add(segi + 128);
          //pos2.add(layer + 128);
          posn.add(segj.toDouble());
          posn.add(segi.toDouble());
          posn.add(layer.toDouble());
          var m = [ 0, 0, 0, 0 ];
          if(i > 0 && j > 0) {
            var start0 = (rowStart[i-1] + (j-1));
            var start1 = (rowStart[i]   + (j-1));
            if((i + j) % 2 == 1) {
              idx.add( start0 + 1);
              idx.add( start0 + 0);
              idx.add( start1 + 0);

              idx.add( start0 + 1);
              idx.add( start1 + 0);
              idx.add( start1 + 1);
            } else {
              idx.add( start0 + 0);
              idx.add( start1 + 0);
              idx.add( start1 + 1);

              idx.add( start0 + 0);
              idx.add( start1 + 1);
              idx.add( start0 + 1);
            }
          }
        }
      }
    }
    scale_ *= 2;
  }
  var customMesh = new EditableMesh();
  print(posn);
  customMesh.vertexArray = new Float32List.fromList(posn);
  customMesh.indexArray = new Uint16List.fromList(idx);
  customMesh.attributes = [new MeshAttribute('position','float3',0,3*4)];
  _terrainMeshes[hash] = customMesh;
  return customMesh;
}

var terrainMaterial = new Material()
..shader = _terrainShader;

var _terrainShader = new Shader.fromGLSL(_terrainVert, _terrainFrag, RenderPass.geometry, "terrainShader");

var _terrainMap = {
'properties' : [{'tagName' : 'Splat 0', 'varName' : '_Splat0', 'type' : 'texture2d', 'defaultValue' : 'white'},
                {'tagName' : 'Splat 1', 'varName' : '_Splat1', 'type' : 'texture2d', 'defaultValue' : 'white'},
                {'tagName' : 'Splat 2', 'varName' : '_Splat2', 'type' : 'texture2d', 'defaultValue' : 'white'},
                {'tagName' : 'Splat 3', 'varName' : '_Splat3', 'type' : 'texture2d', 'defaultValue' : 'white'},
                {'tagName' : 'Splat 4', 'varName' : '_Splat4', 'type' : 'texture2d', 'defaultValue' : 'white'}],
'subshaders' : [{'renderpass' : 'geometry', 'type' : 'surface', 'vs' : _terrainVert, 'fs' : _terrainFrag}]
};


String _terrainVert =
"""
#ifdef GL_ES
precision highp float;
#endif
const int NUM_LAYERS = 10;
const float RING_WIDTH = 7.0;

attribute vec3 position;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 cameraPosition;

uniform sampler2D _HeightMap;
uniform vec2 size_HeightMap;
uniform vec4 terrainMinMax;

uniform vec2 offsets[NUM_LAYERS];
uniform float scales[NUM_LAYERS];
varying vec3 worldPosition;
varying vec4 eyePosition;


vec2 worldToMapSpace(vec2 coord, vec2 size, vec2 scale) {
  return (coord / scale + 0.5) / size;
}

float catmullRom(float pm1, float p0, float p1, float p2, float x) {
  float x2 = x * x;
  return 0.5 * (
    pm1 * x * ((2.0 - x) * x - 1.0) +
    p0 * (x2 * (3.0 * x - 5.0) + 2.0) +
    p1 * x * ((4.0 - 3.0 * x) * x + 1.0) +
    p2 * (x - 1.0) * x2);
}
float texHeight(sampler2D samp, vec2 uv) {
  vec4 rgba = texture2D(samp, uv).xyzw * 255.0;
  //const vec4 bitSh = vec4(1.0/(256.0*256.0*256.0), 1.0/(256.0*256.0), 1.0/256.0, 1.0);
  const vec4 bitSh = vec4( 1.0, 1.0/256.0, 1.0/(256.0*256.0), 1.0/(256.0*256.0*256.0));
  return(dot(rgba, bitSh));
}

// Cubic sampling in one dimension.
float textureCubicU(sampler2D samp, vec2 uv00, float texel, float offsetV, float frac) {
  return catmullRom(
      texHeight(samp, uv00 + vec2(-texel, offsetV)),
      texHeight(samp, uv00 + vec2(0.0, offsetV)),
      texHeight(samp, uv00 + vec2(texel, offsetV)),
      texHeight(samp, uv00 + vec2(texel * 2.0, offsetV)),
      frac);
}

// Cubic sampling in two dimensions, taking advantage of separability.
float textureBicubic(sampler2D samp, vec2 uv00, vec2 texel, vec2 frac) {
  return catmullRom(
      textureCubicU(samp, uv00, texel.x, -texel.y, frac.x),
      textureCubicU(samp, uv00, texel.x, 0.0, frac.x),
      textureCubicU(samp, uv00, texel.x, texel.y, frac.x),
      textureCubicU(samp, uv00, texel.x, texel.y * 2.0, frac.x),
      frac.y);
}


vec2 terrainTexturePos(vec2 worldPos) {
  vec2 pos = worldPos - terrainMinMax.xy;
  vec2 max = terrainMinMax.zw - terrainMinMax.xy;
  return pos / max;
}

float getHeight(vec2 worldPosition) {
  vec2 heightUv = terrainTexturePos(worldPosition);
  vec2 texel = 1.0 / size_HeightMap;

  // Find the bottom-left texel we need to sample.
  vec2 heightUv00 = (floor(heightUv * size_HeightMap + 0.5) - 0.5) / size_HeightMap;

  // Determine the fraction across the 4-texel quad we need to compute.
  vec2 frac = (heightUv - heightUv00) * size_HeightMap;

  // Compute an interpolated coarse height value.
  float coarseHeight = textureBicubic(_HeightMap, heightUv00, texel, frac) * 1.0;//tHeightScale.z;
  return coarseHeight;
}

void main() {
  int layer = int(position.z);
  vec2 layerOffset = offsets[layer];
  float layerScale = scales[layer];

  vec3 cameraPos = cameraPosition.xyz;

  worldPosition = (position * layerScale + vec3(layerOffset, 0.0))  * 0.015;

  // Work out how much morphing we need to do.
  vec3 manhattan = abs(worldPosition - cameraPos);
  float morphDist = max(manhattan.x, manhattan.y) / layerScale;
  float morph = min(1.0, max(0.0, morphDist / (RING_WIDTH / 2.0) - 3.0));

  // Compute the morph direction vector.
  vec2 layerPosition = worldPosition.xy / layerScale;
  vec2 morphVector = mod(layerPosition.xy, 2.0) * (mod(layerPosition.xy, 4.0) - 2.0);
  vec3 morphTargetPosition = vec3(worldPosition.xy + layerScale * morphVector, 0.0);

  // Get the unmorphed and fully morphed terrain heights.
  worldPosition.z = getHeight(worldPosition.xy);
  morphTargetPosition.z = getHeight(morphTargetPosition.xy);

  // Apply the morphing.
  worldPosition = mix(worldPosition, morphTargetPosition, morph);
  //worldPosition = worldPosition.xyz;

  eyePosition = modelViewMatrix * vec4(worldPosition.yzx, 1.0);
  gl_Position = projectionMatrix * eyePosition;
}
""";
var _terrainFrag =
"""
#extension GL_OES_standard_derivatives : enable
precision highp float;

uniform vec3 cameraPosition;

uniform sampler2D _LightMap;
uniform sampler2D _Control;
uniform vec4 terrainMinMax;

// Default Texture
uniform sampler2D _Splat0;
uniform sampler2D _Splat1;
uniform sampler2D _Splat2;
uniform sampler2D _Splat3;
uniform sampler2D _Splat4;

varying vec4 eyePosition;
varying vec3 worldPosition;

vec2 terrainTileTexturePos(vec2 worldPos, vec2 size, vec2 scale) {
  vec2 pos = worldPos - terrainMinMax.xy;
  return (pos / scale - 1.0) / size;
}


vec2 terrainTexturePos(vec2 worldPos) {
  vec2 pos = (worldPos - terrainMinMax.xy);
  pos.x -= 0.5;
  pos.y -= 0.5;
  //pos.x *= -1.0;
  //pos.y *= -1.0;
  //pos.y -= 10.5;
  vec2 max = terrainMinMax.zw - terrainMinMax.xy;
  return vec2(pos.y,pos.x) / max;
}

vec2 worldToMapSpace(vec2 coord, vec2 size, vec2 scale) {
  return (coord / scale + 0.5) / size;
}

mat2 inverse(mat2 m) {
  float det = m[0][0] * m[1][1] - m[0][1] * m[1][0];
  return mat2(m[1][1], -m[1][0], -m[0][1], m[0][0]) / det;
}

float bias_fast(float a, float b) {
  return b / ((1.0/a - 2.0) * (1.0-b) + 1.0);
}

float gain_fast(float a, float b) {
  return (b < 0.5) ?
    (bias_fast(1.0 - a, 2.0 * b) / 2.0) :
    (1.0 - bias_fast(1.0 - a, 2.0 - 2.0 * b) / 2.0);
}

void main() {
  gl_FragColor.a = 1.0;

  vec2 uv_Terrain = terrainTexturePos(worldPosition.xy);
  vec4 splat_control = texture2D(_Control, uv_Terrain.yx);
  vec4 col;
  vec2 tileUv = terrainTileTexturePos(worldPosition.xy,vec2(512.0),vec2(0.01));
  col  = texture2D(_Splat0, tileUv);
  col += splat_control.r * texture2D(_Splat1, tileUv);
  col += splat_control.g * texture2D(_Splat2, tileUv);
  col += splat_control.b * texture2D(_Splat3, tileUv);
  col += splat_control.a * texture2D(_Splat4, tileUv);
  vec4 lightmapValue = texture2D(_LightMap, uv_Terrain);
  col.rgb *= lightmapValue.rgb * (lightmapValue.a * 6.5);
  gl_FragColor.rgb = col.rgb;
}""";