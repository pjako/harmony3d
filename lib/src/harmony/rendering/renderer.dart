part of harmony;






class CustomComponentSystem {

}




class RenderJob {
  num sortKey;
  dml.ShaderProgram program;
  Material material;
  Renderer renderer;
  RenderPass pass;
  Mesh mesh;
  //Aabb3 worldBounds;


  factory RenderJob() {
  	var job;
  	if(_l.isNotEmpty) {
  		job = _l.removeLast();
  	} else {
  		job = new RenderJob._internal();
  	}
  	return job;
  }
  RenderJob._internal();

  static destroy(RenderJob job) {
  	job.sortKey = null;
  	job.program = null;
  	job.material = null;
  	job.pass = null;
  	job.mesh = null;
  	_l.add(job);

  }
  static final _l = [];
}


abstract class CustomRenderer extends Renderer {


  Aabb3 get bounds => _bounds;
  void set bounds(var b) {
    _bounds.copyFrom(b);
  }


  void _renderUpdate(Camera camera) {
    super._renderUpdate(camera);
    renderUpdate(camera);
  }
  void _testLoad(_) {
  }

  void renderUpdate(Camera camera) {

  }

  void set isReadyToRender(bool b) {
    _isReadyToRender = b;
    if(b != true) return;
    RenderManager._prepareRenderer(this);
  }
  bool get isReadyToRender => _isReadyToRender;


}

class RendererConstants {
	Renderer renderer;
	Matrix4 worldMatrix;
	Matrix4 worldViewProjection;
	Aabb3 worldBounds;
	RendererConstants();
}
/// The renderer component is the base class to 3D rendering objects
/// Use Meshrenderer or Skinnedrenderer to render.
class Renderer extends Component {
  final Matrix4 _worldViewProjection = new Matrix4.zero();
  final List<RenderJob> _renderJobs = [];
  final RendererConstants _rendererConstants = new RendererConstants();

  bool _partOfBatch;
  RenderBatch _batch;
  Float32x4List _simdWorldViewProjection;
  double _distance;
  @Serialize(SerializeType.asset, customName: 'meshes')
  Mesh _mesh;
  @Serialize(SerializeType.asset, customName: 'materials')
  Material _material;
  final Aabb3 _bounds = new Aabb3();
  bool _isReadyToRender = false;

  /// Shared Material with other Renderer
  /// Changes in the material will affect all renderers that use this material.
  Material get sharedMaterial => _material;
  //Material _sharedMaterial;

  /// Material, calling this will create an seperate material
  /// But currently does the same thing as Shared Material
  Material get material => _material;
  void set material(Material newMat) {
    _isReadyToRender = false;
    _material.removeDepenency(this);
    _material = newMat;
    //_sharedMaterial = newMat;
    if(_material.isLoaded) {
      _testLoad(null);
      return;
    }
    _material.notifyOnLoad().then(_testLoad);
  }
  /// tests if all renderdata are ready to render
  void _testLoad(_) {
    if(_isReadyToRender == true) return;
    if(_material == null || _mesh == null) return;
    _isReadyToRender = _material.isLoaded && _mesh.isLoaded;
    if(_isReadyToRender) {
      RenderManager._prepareRenderer(this);
    }
  }

  /// Mesh that this Renderer uses
  Mesh get mesh => _mesh;
  void set mesh(Mesh newMesh) {
    _isReadyToRender = false;
    _mesh.removeDepenency(this);
    _mesh = newMesh;
    if(_mesh.isLoaded) {
      _testLoad(null);
      return;
    }
    _mesh.notifyOnLoad().then(_testLoad);
  }

  Renderer() {

    //_parameters.worldViewProjection = _worldViewProjection;
    _simdWorldViewProjection = new Float32x4List.view(_worldViewProjection.storage.buffer);
  }

  Aabb3 get _internalBounds => _bounds;

  void _preInit() {
    gameObject._renderer = this;
  }

  /// Prepare renderer for rendering
  void _renderUpdate(Camera camera) {
    // we use this to update the worldMatrix and get the world matrix without making a copy
    transform._updateWorldMatrix();
    var worldMat = transform._worldMat;
    _rendererConstants.worldMatrix = worldMat;
    _rendererConstants.worldViewProjection = _worldViewProjection;
    _mulVPWithW(_worldViewProjection.storage, camera._viewProjectionMatrix.storage, worldMat.storage);

  }

  void _render(RenderManager render, Camera camera) {

  }



  void _renderUpdateSIMD(Camera camera) {
    //transform._updateWorldMatrixSIMD();

    //var worldMat = transform._simdWorldTransform;
    //var viewProjMat = camera._simdViewProjectionMatrix;
    //Matrix44SIMDOperations.multiply(_simdWorldViewProjection, 0, viewProjMat, 0, worldMat, 0);

    _renderUpdate(camera);
  }

}

/// Matrix4x4 multiplication optimized for WORLDMATRIX*VIEWPERSPECTIVEMMATRIX
/// [a] is a view perspective matrix 4x4
/// [b] is a world matrix 4x4
void _mulVPWithW(Float32List out, Float32List a, Float32List b) {
  final a00 = a[0], a01 = a[1], a02 = a[2], a03 = a[3];
  final a10 = a[4], a11 = a[5], a12 = a[6], a13 = a[7];
  final a20 = a[8], a21 = a[9], a22 = a[10], a23 = a[11];
  final a30 = a[12], a31 = a[13], a32 = a[14], a33 = a[15];

  var b0  = b[0], b1 = b[1], b2 = b[2];
  out[0] = b0*a00 + b1*a10 + b2*a20;
  out[1] = b0*a01 + b1*a11 + b2*a21;
  out[2] = b0*a02 + b1*a12 + b2*a22;
  out[3] = b0*a03 + b1*a13 + b2*a23;

  b0 = b[4]; b1 = b[5]; b2 = b[6];
  out[4] = b0*a00 + b1*a10 + b2*a20;
  out[5] = b0*a01 + b1*a11 + b2*a21;
  out[6] = b0*a02 + b1*a12 + b2*a22;
  out[7] = b0*a03 + b1*a13 + b2*a23;

  b0 = b[8]; b1 = b[9]; b2 = b[10];
  out[8] = b0*a00 + b1*a10 + b2*a20;
  out[9] = b0*a01 + b1*a11 + b2*a21;
  out[10] = b0*a02 + b1*a12 + b2*a22;
  out[11] = b0*a03 + b1*a13 + b2*a23;

  b0 = b[12]; b1 = b[13]; b2 = b[14];
  out[12] = b0*a00 + b1*a10 + b2*a20 + a30;
  out[13] = b0*a01 + b1*a11 + b2*a21 + a31;
  out[14] = b0*a02 + b1*a12 + b2*a22 + a32;
  out[15] = b0*a03 + b1*a13 + b2*a23 + a33;
}

/*
class MeshRendererSystem extends ComponentSystem {
  MeshRendererSystem(mist.ClassInfo info) : super(info);

  Map encodeComponents(List<Component> components, Map<int, dynamic> objects) {
    throw new UnimplementedError();
  }

  Component reset(Component component) {
    final MeshRenderer renderer = component as MeshRenderer;
    component._enabled = true;
    removeId(renderer);
    if(renderer._mesh != null) {
      renderer._mesh.removeDepenency(component);
      renderer._mesh = null;
    }
    if(renderer._material != null) {
      renderer._material.removeDepenency(component);
      renderer._material = null;
    }
    if(renderer._sharedMaterial != null) {
      renderer._sharedMaterial.removeDepenency(component);
      renderer._sharedMaterial = null;
    }
    return component;
  }

  void decode(List<Component> components, Map<String,dynamic> componentsData, Map<int, dynamic> objects) {
    int count = components.length;
    var boundsBuffer = new Float32List.view( base64decoder.decode(componentsData['bounds']) );
    var lightmapTilingOffsetBuffer = new Float32List.view( base64decoder.decode(componentsData['lightmapTilingOffsets']) );
    var lightmapIndexies = componentsData['lightmapIndexies'];
    List materials = componentsData['materials'];
    List lightMaps = componentsData['lightmaps'];
    var meshes = componentsData['meshes'];

    for(int i=0; i<count; i++) {
      int b = i * 6;
      int l = i * 4;

      MeshRenderer meshRenderer = components[i] as MeshRenderer;

      meshRenderer._bounds.min.storage[0] = boundsBuffer[b];
      meshRenderer._bounds.min.storage[1] = boundsBuffer[b+1];
      meshRenderer._bounds.min.storage[2] = boundsBuffer[b+2];
      meshRenderer._bounds.max.storage[0] = boundsBuffer[b+3];
      meshRenderer._bounds.max.storage[1] = boundsBuffer[b+4];
      meshRenderer._bounds.max.storage[2] = boundsBuffer[b+5];

      meshRenderer.mesh = objects[meshes[i]];

      meshRenderer.material = objects[materials[i]];


      meshRenderer._parameters.lightmapTilingOffset.storage[0] = lightmapTilingOffsetBuffer[l];
      meshRenderer._parameters.lightmapTilingOffset.storage[1] = lightmapTilingOffsetBuffer[l+1];
      meshRenderer._parameters.lightmapTilingOffset.storage[2] = lightmapTilingOffsetBuffer[l+2];
      meshRenderer._parameters.lightmapTilingOffset.storage[3] = lightmapTilingOffsetBuffer[l+3];
      var lightmapId = lightmapIndexies[i];
      var hasLightMaps = lightmapId != -1;
      if(hasLightMaps) {
        meshRenderer._addLightmap(objects[lightMaps[lightmapId]]);
      }
      meshRenderer._parameters.lightmapIndex = lightmapId;
      meshRenderer._parameters.usesLightmaps = hasLightMaps;
    }

  }
}
 */


