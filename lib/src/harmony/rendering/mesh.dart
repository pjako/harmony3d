part of harmony;


/*
class SkinnedMesh extends Mesh {


  void _fromJson(Map obj) {
  }

}
*/


class EditableMesh extends Mesh  {
  void set vertexArray(Float32List fl) {
    //_parameters.vertexArray = fl;

  }
  void set indexArray(Uint16List ul) {
    //_parameters.indexArray = ul;
  }
  void set attributes(List<MeshAttribute> attributes) {
    //_parameters.attributes.clear();
    //_parameters.attributes.addAll(attributes);
  }

  bool get isLoaded => true;

}
/// A 3D static mesh
class Mesh extends Asset  {
  String _name;
  // only exist for skinned meshes
  Skeleton _skeleton;

  BufferPart _bufferPart;

  int _vertexBufferOffset;
  int _vertexBufferSubSize;
  Float32List _vertexList;
  Uint16List _indexList;
  int vertexArrayOffset;
  dml.InputLayout _inputLayout;
  dml.VertexArray _vertexArray;
  dml.IndexBuffer _idxBuff;
  dml.VertexArray _vertBuff;

  //var _vertexArray, _indexArray;
  final List _attributes = [];


  //final MeshParameters _parameters = new MeshParameters();
  final Aabb3 _bounds = new Aabb3();
  // TODO: consider to move this to an worker.
  void _calculateBounds() {
    double minX, minY, minZ, maxX, maxY, maxZ;

    for(var att in /*_parameters.*/attributes) {
      if(att.name == 'POSITION') {
        var vertexArray = _parameters.vertexArray;
        int offset = (att.offset / 4).floor();
        int stride = (att.stride / 4).floor();
        minX = maxX = vertexArray[offset];
        minY = maxY = vertexArray[offset+1];
        minZ = maxZ = vertexArray[offset+2];
        for(int i=offset+stride;i < vertexArray.length;i+=stride) {
          double x = vertexArray[i];
          double y = vertexArray[i+1];
          double z = vertexArray[i+2];
          if(x <= minX) {
            minX = x;
          }else if(x > maxX) {
            maxX = x;
          }

          if(y <= minY) {
            minY = y;
          } else if(y > maxY) {
            maxY = y;
          }

          if(z <= minZ) {
            minZ = z;
          } else if(z > maxZ) {
            maxZ = z;
          }
        }
        _bounds.min.setValues(minX, minY, minZ);
        _bounds.max.setValues(maxX, maxY, maxZ);
        return;
      }
    }


  }

  Aabb3 getBounds(Aabb3 out) {
    out.copyFrom(_bounds);

  }
  Aabb3 get bounds => getBounds(new Aabb3());

  Aabb3 get _internalBounds => _bounds;
/*
  void _fromJson(Map obj) {
    {
      _parameters.debugString = this.assetId;
      //var buffer = base64decoder.decode(obj['bounds']);
      //var min = new Float32List.view(buffer, 0, 3);
      //var max = new Float32List.view(buffer, 3*Float32List.BYTES_PER_ELEMENT, 3);
      //_bounds.min.storage[0] = min[0];
      //_bounds.min.storage[1] = min[1];
      //_bounds.min.storage[2] = min[2];
      //_bounds.max.storage[0] = max[0];
      //_bounds.max.storage[1] = max[1];
      //_bounds.max.storage[2] = max[2];

      var verticesBuffer = base64decoder.decode(obj['vertices']);
      var indicesBuffer = base64decoder.decode(obj['indices']);

      var vertices = new Float32List.view(verticesBuffer);
      var indices = new Uint16List.view(indicesBuffer);

      _parameters.vertexArray = vertices;
      _parameters.indexArray = indices;
      _name = obj['name'];
    }

    {
      var attributes = obj['attributes'];
      List<String> names = attributes['name'];
      List<String> formats = attributes['format'];
      List<int> offsets = attributes['offset'];
      List<int> strides = attributes['stride'];
      var length = names.length;
      for(int i=0; i<length;i++) {
        _parameters.attributes.add(new MeshAttribute(names[i],formats[i],offsets[i],strides[i]));
      }
    }

    /// Sceletal values
    if(!obj.containsKey('boneTable')) return;
    var bones = obj['boneTable'];
    List<String> boneNames = bones['name'];
    List<int> boneIndex = bones['index'];
    print(boneNames);
    int boneCount = boneNames.length;
    //var skinned = new Uint8List.view( base64decoder.decode(bones['skinned']));
    var parents = bones['parent'];
    var offsetTransforms = base64decoder.decode(bones['offsetTransform']);
    var localTransforms = base64decoder.decode(bones['localTransform']);

    //var boneList = new List<Bone>(boneCount);
    _skeleton = new Skeleton(_name,boneCount);
    //TODO: FIX THIS
    _skeleton.globalOffsetTransform[0] = 1.0;
    _skeleton.globalOffsetTransform[6] = -1.0;
    _skeleton.globalOffsetTransform[9] = 1.0;
    _skeleton.globalOffsetTransform[15] = 1.0;
    int r = 0;


    for(int i=0; i < boneCount; i++) {
      String boneName = boneNames[i];
      Float32List offsetMat = new Float32List.view(offsetTransforms, 4 * 16 * r, 16);
      Float32List localMat = new Float32List.view(localTransforms, 4 * 16 * r, 16);

      bool zeroOffset = false;
      int parentId = parents[i];
      Bone parent;
      if(parentId != -1) parent = _skeleton.boneList[parentId];
      var bone = new Bone(boneName,parent,localMat,offsetMat,false,zeroOffset)
      .._boneIndex = boneIndex[i];
      _skeleton.boneList[i] = bone;
      _skeleton.bones[boneName] = bone;

    }



  }*/


    Future _fromJson(Map obj) {
      _vertexList = new Float32List.view(base64decoder.decode(obj['vertices']));
      _indexList = new Uint16List.view(base64decoder.decode(obj['indices']));
      //var indicesBuffer = base64decoder.decode(obj['indices']);
    	final future = _renderManager._initMesh(this, obj);

    {
      //_parameters.debugString = this.assetId;
      var buffer = base64decoder.decode(obj['bounds']);
      var min = new Float32List.view(buffer, 0, 3);
      var max = new Float32List.view(buffer, 3*Float32List.BYTES_PER_ELEMENT, 3);
      _bounds.min.storage[0] = min[0];
      _bounds.min.storage[1] = min[1];
      _bounds.min.storage[2] = min[2];
      _bounds.max.storage[0] = max[0];
      _bounds.max.storage[1] = max[1];
      _bounds.max.storage[2] = max[2];



      //var verticesBuffer = base64decoder.decode(obj['vertices']);
      //var indicesBuffer = base64decoder.decode(obj['indices']);

      //var vertices = new Float32List.view(verticesBuffer);
      //var indices = new Uint16List.view(indicesBuffer);

      /*_parameters.*///_vertexList = vertices;
      /*_parameters.*///_indexList = indices;
      _name = obj['name'];
    }

    /// Sceletal values
    if(!obj.containsKey('bones')) return future;
    var bones = obj['bones'];
    List<String> boneNames = bones['name'];
    print(boneNames);
    int boneCount = boneNames.length;
    var positions = base64decoder.decode(bones['position']);
    var rotations = base64decoder.decode(bones['rotation']);
    var skinned = new Uint8List.view( base64decoder.decode(bones['skinned']));
    var parents = bones['parent'];
    var bindPoses = base64decoder.decode(bones['bindpose']);
    //var localOffsetTransforms = base64decoder.decode(bones['localOffset']);

    //var boneList = new List<Bone>(boneCount);
    _skeleton = new Skeleton(_name,boneCount);
    //TODO: FIX THIS
    _skeleton.globalOffsetTransform[0] = 1.0;
    _skeleton.globalOffsetTransform[4] = 1.0;
    _skeleton.globalOffsetTransform[9] = 1.0;
    _skeleton.globalOffsetTransform[15] = 1.0;
    int r = 0;


    for(int i=0; i < boneCount; i++) {
      String boneName = boneNames[i];

      bool isSkinned = skinned[i] == 1 ? true : false;
      Float32List bindposeMat;
      bool zeroOffset = false;
      if(isSkinned) {
        bindposeMat = new Float32List.view(bindPoses, 4 * 16 * r, 16);
        //new Matrix4.fromBuffer(bindPoses, 4 * 16 * r);
        r++;
      } else {
        print('$boneName notSkinned: ${skinned[i]}');
        //bindposeMat =
        /*var m = new Matrix4.zero()
        ..setFromTranslationRotation(new Vector3.fromBuffer(positions, 4*3*i), new Quaternion.fromBuffer(rotations, 4*4*i));*/

        print('not skinned: $boneName');
        bindposeMat = new Matrix4.identity().storage;
      }
      //Float32List pos = new Float32List.view(positions, 4 * 3 * i, 3);
      //Float32List rot = new Float32List.view(rotations, 4 * 4 * i, 4);
      //var localMat = matrix4FromTranslationRotation(pos,rot);
      //var localMat = new Float32List.view(localOffsetTransforms, i*4*15, 16);
      int parentId = parents[i];
      Bone parent;
      if(parentId != -1) parent = _skeleton.boneList[parentId];
      var bone = new Bone(boneName,parent,bindposeMat,isSkinned)
      ..boneIndex = i;
      _skeleton.boneList[i] = bone;
      _skeleton.bones[boneName] = bone;

    }
    return future;
  }
}



Float32List matrix4FromTranslationRotation(Float32List arg0, Float32List arg1) {
  double x = arg1[0];
  double y = arg1[1];
  double z = arg1[2];
  double w = arg1[3];
  double x2 = x + x;
  double y2 = y + y;
  double z2 = z + z;
  double xx = x * x2;
  double xy = x * y2;
  double xz = x * z2;
  double yy = y * y2;
  double yz = y * z2;
  double zz = z * z2;
  double wx = w * x2;
  double wy = w * y2;
  double wz = w * z2;
  Float32List storage = new Float32List(16);
  storage[0] = 1.0 - (yy + zz);
  storage[1] = xy + wz;
  storage[2] = xz - wy;
  storage[3] = 0.0;
  storage[4] = xy - wz;
  storage[5] = 1.0 - (xx + zz);
  storage[6] = yz + wx;
  storage[7] = 0.0;
  storage[8] = xz + wy;
  storage[9] = yz - wx;
  storage[10] = 1.0 - (xx + yy);
  storage[11] = 0.0;
  storage[12] = arg0[0];
  storage[13] = arg0[1];
  storage[14] = arg0[2];
  storage[15] = 1.0;
  return storage;
}
