precision highp float;
attribute vec3 POSITION;
attribute vec3 NORMAL;
attribute vec3 TEXCOORD0;
attribute vec3 TEXCOORD1;
attribute vec3 WEIGHTS;
attribute vec3 BONES;
uniform mat4 MATRIX_MVP;
uniform mat4 BONE_MATRICES[255];
uniform vec3 vertexLightPos[4];
uniform vec3 vertexLightColor[4];
uniform vec4 vertexLightRange;
varying vec2 uv0;
varying vec2 uv1;
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
  vec4 lengthSq = 0;
  lengthSq += toLightX * toLightX;
  lengthSq += toLightY * toLightY;
  lengthSq += toLightZ * toLightZ;
  // NdotL
  vec4 ndotl = 0;
  ndotl += toLightX * normal.x;
  ndotl += toLightY * normal.y;
  ndotl += toLightZ * normal.z;
  // correct NdotL
  vec4 corr = rsqrt(lengthSq);
  ndotl = max (vec4(0,0,0,0), ndotl * corr);
  // attenuation
  vec4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
  vec4 diff = ndotl * atten;
  // final color
  vec3 col = 0;
  col += lightColor0 * diff.x;
  col += lightColor1 * diff.y;
  col += lightColor2 * diff.z;
  col += lightColor3 * diff.w;
  return col;
}
void main() {
 uv0 = TEXCOORD0;
 uv1 = TEXCOORD1;
 vVertexLightFront = ShadeVertexPointLights(
  vec4(vertexLightPos[0].x,vertexLightPos[1].x,vertexLightPos[2].x,vertexLightPos[3].x),
  vec4(vertexLightPos[0].y,vertexLightPos[1].y,vertexLightPos[2].y,vertexLightPos[3].y),
  vec4(vertexLightPos[0].z,vertexLightPos[1].z,vertexLightPos[2].z,vertexLightPos[3].z),
  vertexLightColor[0],vertexLightColor[1],vertexLightColor[2],vertexLightColor[3],
  vertexLightRange,POSITION,NORMAL);
 gl_Position = MATRIX_MVP*transformSkinMat()*vec4(POSITION,0.0);
}
