name: BasicShader
description: A basic Shader
textures:
  color:
    format: rgb
    
subshader:
  Basic_Path:
    type: surface
    lit: false
    




#GLSL

#Basic_Path:START

void surface(Surface io) {
  vec3 color = color_texvalue(0.1,0.2);
}


#Fragment


#Basic_Path:END