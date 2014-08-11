library shader_builder;

void main() {
  print(buildVertexShader(skinned: true, maxBones: 120, textureCoords: ['uv0']));
}

String buildFragmentShader() {

}

String buildVertexShader({
  bool vertexLight: true,
  bool skinned: false,
  int maxBones: 50,
  int bonesPerVertex: 3,
  List<String> textureCoords,
  bool isHp: true,
  bool modelMat: false,
  bool perspectiveMat: false,
  bool modelViewMat: false}) {
  if(textureCoords == null) textureCoords = [];
  StringBuffer buffer = new StringBuffer();
  if(isHp) buffer.write('precision highp float;\n');

  ///
  /// Attributes
  ///

  buffer.write('attribute vec3 POSITION;\n');
  buffer.write('attribute vec3 NORMAL;\n');
  for(int i=0; i < textureCoords.length; i++) {
    buffer.write('attribute vec2 TEXCOORD${i};\n');
  }
  if(skinned) {
    buffer.write('attribute vec3 WEIGHTS;\n');
    buffer.write('attribute vec3 BONES;\n');
  }

  ///
  /// Uniforms
  ///

  buffer.write('uniform mat4 MATRIX_MVP;\n');
  if(modelMat || skinned) buffer.write('uniform mat4 MATRIX_M;\n');
  if(modelViewMat) buffer.write('uniform mat4 MATRIX_MV;\n');
  if(perspectiveMat) buffer.write('uniform mat4 MATRIX_P;\n');

  if(skinned) buffer.write('uniform mat4 BONE_MATRICES[$maxBones];\n');

  if(vertexLight) buffer.write(vertexLightsUniforms);

  ///
  /// Varying
  ///

  for(int i=0; i < textureCoords.length; i++) {
    buffer.write('varying vec2 ${textureCoords[i]};\n');
  }

  if(vertexLight) buffer.write(vertexLightsVarying);

  ///
  /// Functions
  ///

  if(skinned) buffer.write(skinningFunction(bonesPerVertex));

  if(vertexLight) buffer.write(phongLight2);

  ///
  /// Main
  ///

  buffer.write('void main() {\n');
  buffer.write(' vec4 pos = vec4(POSITION, 1.0);\n');
  if(skinned) {
    buffer.write(' mat4 skinMat = MATRIX_M * $skinningFunctionName();\n');
    buffer.write(' pos = skinMat * pos;\n');
  }
  for(int i=0; i < textureCoords.length; i++) {
    buffer.write(' ${textureCoords[i]} = TEXCOORD${i};\n');
  }
  if(vertexLight) buffer.write(vertexPhongLightCall);

  buffer.write(' gl_Position = MATRIX_MVP*pos;\n');
  buffer.write('}');
  return buffer.toString();

  //buffer.write('');

}


const String skinningFunctionName = 'transformSkinMat';
String skinningFunction(int boneCount) {
  StringBuffer buffer = new StringBuffer();
  buffer.write('mat4 transformSkinMat() {\n');
  buffer.write(' mat4 result = WEIGHTS.x * BONE_MATRICES[int(BONES.x)];\n');
  if(boneCount > 1) {
    buffer.write(' result = result + WEIGHTS.y * BONE_MATRICES[int(BONES.y)];\n');
    if(boneCount > 2) {
      buffer.write(' result = result + WEIGHTS.z * BONE_MATRICES[int(BONES.z)];\n');
      if(boneCount > 3) {
        buffer.write(' result = result + WEIGHTS.w * BONE_MATRICES[int(BONES.w)];\n');
      }
    }
  }
  buffer.write(' return result;\n}\n');
  return buffer.toString();
}



String baseVertexSource =
'''
precision highp float;

attribute vec3 POSITION;
attribute vec3 NORMAL;
attribute vec2 TEXCOORD0;
attribute vec3 WEIGHTS;
attribute vec3 BONES;

uniform mat4 MATRIX_MVP;
uniform mat4 BONE_MATRICES[30];

varying vec2 uv_MainTexture;


mat4 accumulateSkinMat() {
 mat4 result = WEIGHTS.x * BONE_MATRICES[int(BONES.x)];
 result = result + WEIGHTS.y * BONE_MATRICES[int(BONES.y)];
 result = result + WEIGHTS.z * BONE_MATRICES[int(BONES.z)];
 return result;
}

void main() {
 // TexCoord
 uv_MainTexture = TEXCOORD0;

 mat4 tMatrix = MATRIX_MVP * accumulateSkinMat();
 gl_Position = tMatrix*vec4(POSITION,1.0);
}
''';



String vertexLightsUniforms =
'''
uniform vec3 vertexLightPos[4];
uniform vec3 vertexLightColor[4];
uniform vec4 vertexLightRange;
''';

String vertexLightsVarying = 'varying vec3 vVertexLightFront;\n';

String phongLight =
'''
void  (vec3 lightColor, vec3 lightPos, float lightDistance, vec3 vertPos, vec3 vertexNormal, float atten) {
 vec3 lightVector = normalize(lightPos - POSITION);
 float ndl = max(0.0, dot(NORMAL, lightVector));


 vec3 localVector = lightPos - POSITION;
 vec3 h = normalize (lightDir + viewDir);
 float diff = max (0, dot (NORMAL, lightDir));
 VERTEX_LIGHT_FRONT += lightColor * diff;

 float distance =  1.0 - min( ( length( localVector ) / lightDistance ), 1.0 );

 localVector = normalize( localVector );",
 float dotProduct = dot( vertexNormal, lVector );",

 vec3 pointLightWeighting = vec3( max( dotProduct, 0.0 ) );",

 VERTEX_LIGHT_FRONT += lightColor * pointLightWeighting * distance;
}
''';

String phongLight2 =
'''
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
''';

String vertexPhongLightCall =
'''
 vVertexLightFront = ShadeVertexPointLights(
  vec4(vertexLightPos[0].x,vertexLightPos[1].x,vertexLightPos[2].x,vertexLightPos[3].x),
  vec4(vertexLightPos[0].y,vertexLightPos[1].y,vertexLightPos[2].y,vertexLightPos[3].y),
  vec4(vertexLightPos[0].z,vertexLightPos[1].z,vertexLightPos[2].z,vertexLightPos[3].z),
  vertexLightColor[0],vertexLightColor[1],vertexLightColor[2],vertexLightColor[3],
  vertexLightRange,pos.xyz,NORMAL);
''';


/*
'''
precision highp float;

attribute vec3 POSITION;
attribute vec3 NORMAL;
attribute vec2 TEXCOORD0;
attribute vec3 WEIGHTS;
attribute vec3 BONES;

uniform mat4 MATRIX_MVP;
uniform mat4 BONE_MATS[30];

varying vec2 uv_MainTexture;


mat4 accumulateSkinMat() {
 mat4 result = WEIGHTS.x * BONE_MATS[int(BONES.x)];
 result = result + WEIGHTS.y * BONE_MATS[int(BONES.y)];
 result = result + WEIGHTS.z * BONE_MATS[int(BONES.z)];
 return result;
}

void main() {
 mat4 tMatrix = MATRIX_MVP * accumulateSkinMat();
 // TexCoord
 uv_MainTexture = TEXCOORD0;
 gl_Position = tMatrix*vec4(POSITION,0.0);
}
''';
*/