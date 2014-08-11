precision highp float;
attribute vec3 POSITION;
attribute vec3 NORMAL;
attribute vec3 TEXCOORD0;
attribute vec3 TEXCOORD1;
attribute vec3 WEIGHTS;
attribute vec3 BONES;
uniform mat4 MATRIX_MVP;
uniform mat4 BONE_MATRICES[255];
varying vec2 uv0;
varying vec2 uv1;
mat4 transformSkinMat() {
 mat4 result = WEIGHTS.x * BONE_MATS[int(BONES.x)];
 result = result + WEIGHTS.y * BONE_MATS[int(BONES.y)];
 result = result + WEIGHTS.z * BONE_MATS[int(BONES.z)];
 return result;
}
void main() {
 uv0 = TEXCOORD0;
 uv1 = TEXCOORD1;
 gl_Position = MATRIX_MVP*transformSkinMat()*vec4(POSITION,0.0);
}
