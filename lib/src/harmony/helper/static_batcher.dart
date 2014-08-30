part of harmony;

class RenderBatch {

}
/// Static Batcher, not functional yet
class StaticBatcher {

  void createBatches(Scene scene, double batchAabb3Size) {
    Aabb3 bounds = scene._viewBounds;
    List nodes = [];
    /*double minX = scene._sceneBounds.min.storage[0];
    double minY = scene._sceneBounds.min.storage[1];
    double minZ = scene._sceneBounds.min.storage[2];

    double maxX = scene._sceneBounds.max.storage[0];
    double maxY = scene._sceneBounds.max.storage[1];
    double maxZ = scene._sceneBounds.max.storage[2];*/



    scene._staticSpatialMap.getOverlappingNodes(bounds, nodes, 0);
    Map<String, List<MeshRenderer>> batchMap = {};
    for(var renderer in nodes) {
      if(renderer is! MeshRenderer) continue;
      String key = renderer._material.assetId;
      var list = batchMap[key];
      if(list == null) {
        list = <MeshRenderer>[];
        batchMap[key] = list;
      }
      list.add(renderer);
    }
    for(List<MeshRenderer> rendererList in batchMap.values) {
      int length = rendererList.length;
      if(length <= 1) continue;
      batch(rendererList);
    }


  }


  void batch(List<MeshRenderer> renderers) {
  	/*
    int instaceCount = renderers.length;
    var firstInstance = renderers.first;
    Material material = firstInstance._material;
    Mesh mesh = firstInstance._mesh;
    int stride = mesh._parameters.stride;
    int posOffset = mesh._parameters.positionOffset;
    int posOffestEnd = posOffset + 3;

    Uint16List indexArray = mesh._parameters.indexArray;
    int indexLength = indexArray.length;
    Float32List vertexArray = mesh._parameters.vertexArray;
    int vertexLength = vertexArray.length;

    Uint16List batchIndexArray = new Uint16List(indexArray.length * instaceCount);
    Float32List batchVertexArray = new Float32List(vertexArray.length * instaceCount);

    int vertexArrayPosition = 0;
    int indexOffsetPerInstace = vertexLength ~/ stride;
    int indexOffset = 0;

    for(var renderer in renderers) {
      for(int i=0; i < vertexLength; i++) {
        batchIndexArray[i] = indexArray[i] + indexOffset;
      }
      Vector3 position = renderer.transform._internalPosition;
      Quaternion rotation = renderer.transform._internalRotation;
      double offsetX = position.storage[0];
      double offsetY = position.storage[1];
      double offsetZ = position.storage[2];

      double rotX = rotation.storage[0];
      double rotY = rotation.storage[1];
      double rotZ = rotation.storage[2];
      double rotW = rotation.storage[3];
      for(int i=0; i < vertexLength; i+=stride) {
        for(int r=0; r < stride; r++) {
          // if non Position Data.
          if(r < posOffset || posOffestEnd < r) {
            batchVertexArray[vertexArrayPosition] = vertexArray[i+r];
            vertexArrayPosition++;
            continue;
          }
          int idx = i+r;
          double posX = vertexArray[idx];
          double posY = vertexArray[idx+1];
          double posZ = vertexArray[idx+2];

          double tiw = rotW;
          double tiz = -rotZ;
          double tiy = -rotY;
          double tix = -rotX;
          double tx = tiw * posX + tix * 0.0 + tiy * posZ - tiz * posY;
          double ty = tiw * posY + tiy * 0.0 + tiz * posX - tix * posZ;
          double tz = tiw * posZ + tiz * 0.0 + tix * posY - tiy * posX;
          double tw = tiw * 0.0 - tix * posX - tiy * posY - tiz * posZ;
          double result_x = tw * rotX + tx * rotW + ty * rotZ - tz * rotY;
          double result_y = tw * rotY + ty * rotW + tz * rotX - tx * rotZ;
          double result_z = tw * rotZ + tz * rotW + tx * rotY - ty * rotX;
          batchVertexArray[vertexArrayPosition] = result_x + offsetX;
          batchVertexArray[vertexArrayPosition+1] = result_y + offsetY;
          batchVertexArray[vertexArrayPosition+2] = result_z + offsetZ;
          vertexArrayPosition += 3;
          r += 2;
        }
      }
      indexOffset += indexOffsetPerInstace;
    }*/
  }


}