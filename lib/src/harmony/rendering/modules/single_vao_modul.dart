/*class SVAO {
  gl.InputLayout inputLayout;
  final gl.VertexBuffer vertexBuffer;
  final gl.VertexArray vertexArray;
  
  SVAO(gl.GraphicsDevice device, int size, this.inputLayout) : vertexBuffer = new gl.VertexBuffer(device) , vertexArray = new gl.VertexArray(device) {
    vertexBuffer.allocate(size, gl.UsagePattern.DynamicDraw);
    vertexArray.setVertexBuffer(0, vertexBuffer);
  }
}

class SingleVAORenderModule {
  /// Position (3) UV1 (2) Normals (3)
  SVAO pun;
  /// Position (3) UV1 (2) Normals (3) Tangents (3)
  SVAO punt;
  /// Position (3) UV1 (2) Normals (3) BoneID (1)
  SVAO punb;
  /// Position (3) UV1 (2) Normals (3) Tangents (3) BoneID (1)
  SVAO puntb;
  
  /// Position (3) UV1 (2) UV2 (2) Normals (3)
  SVAO puun;
  
  /// Position (3) UV1 (2) UV2 (2) Normals (3) Tangents (3)
  SVAO puunt;
  
  // Position (3) UV1 (2) UV2 (2) Normals (3) Color (1)
  SingleVAORenderModule() {
    
  }
  
  void init() {
    
  }

  
  void initMesh(Mesh mesh) {
    
  }
  
  void deleteMesh(Mesh mesh) {
    
  }
  
  void setupForRenderMesh(gl.GraphicsContext context, Mesh mesh) {
    final vao = mesh._vertexArray;
    vao.setIndexBuffer(mesh._idxBuff);
    context.setVertexArray(vao);
    
    context.drawIndexed(numIndices, indexOffset)
  }
  
}*/