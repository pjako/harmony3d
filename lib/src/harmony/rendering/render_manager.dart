part of harmony;


class MeshRMModul {

  void initMesh(dml.GraphicsDevice device, Mesh mesh) {
    //mesh.
    final indexBuffer = new dml.IndexBuffer(device);
    indexBuffer.upload(mesh._indexList, dml.UsagePattern.StaticDraw);
    final vertexBuffer = new dml.VertexBuffer(device);
    vertexBuffer.upload(mesh._vertexList, dml.UsagePattern.StaticDraw);
    final vertexArray = new dml.VertexArray(device);
    vertexArray.setIndexBuffer(indexBuffer);
    vertexArray.setVertexBuffer(0, vertexBuffer);
  }

  void deleteMesh(Mesh mesh) {

  }

  void setupToRenderMesh(dml.GraphicsContext context, Mesh mesh) {
    context.setVertexArray(mesh._vertexArray);
  }
}


// Representation of an Vertexattribute
class _VertexAttribute {
	static final _l = [];
	factory _VertexAttribute(String name, String format, int offset, int stride) {
		return _VertexAttribute.spawn(name, format, offset, stride);
	}
	_VertexAttribute.internal();
  static _VertexAttribute spawn(String name, String format, int offset, int stride) {
  	_VertexAttribute att;
  	if(_l.isEmpty) {
  		att = new _VertexAttribute.internal();
  	} else {
  		att = _l.removeLast();
  	}
  	att.name = name;
  	att.format = format;
  	att.offset = offset;
  	att.stride = stride;
  	return att;
  }


  /// Attribute name
	String name;
	/// Attribute format
	String format;
	/// Offset in bytes
	int offset;
	/// Stride offset in bytes
	int stride;
	void destroy() {
		_l.add(this);
	}
	String toString() => '$name$offset$stride$format';
}

/// Shaderattribute defined by
class ShaderAttributes {
	final int index;
	final String name;
	final int dataCount;

	static const ShaderAttributes POSITION = const ShaderAttributes(0,'POSITION',3);
	static const ShaderAttributes TEXCOORD0 = const ShaderAttributes(1,'TEXCOORD0',2);
	static const ShaderAttributes TEXCOORD1 = const ShaderAttributes(2,'TEXCOORD1',2);
	static const ShaderAttributes NORMAL = const ShaderAttributes(3,'NORMAL',3);
	static const ShaderAttributes TANGENT = const ShaderAttributes(4,'TANGENT',3);
	static const ShaderAttributes COLOR = const ShaderAttributes(5,'COLOR',1);
	static const List<ShaderAttributes> list = const [POSITION,TEXCOORD0,TEXCOORD1,NORMAL,TANGENT,COLOR];
	const ShaderAttributes(this.index,this.name,this.dataCount);
}


class _VertexBufferFormat {
	final List<_VertexAttribute> _attributes = [];
	String _hash;
	String get hash => _hash;
	int _bytesPerVertex = 0;
	int get bytesPerVertex => _bytesPerVertex;


	dml.InputLayout generateInputLayout() {
		final input = new dml.InputLayout();
		int index = 0;
		for(final shaderAtt in ShaderAttributes.list) {
			final att = _attributes.firstWhere((e) => e.name == shaderAtt.name, orElse: () => null);
			if(att == null) continue;
			input.attributes.add(
					new dml.VertexAttribute(_graphicsDevice,0,index,att.offset,att.stride,
							dml.DataType.Float32,shaderAtt.dataCount,true));
			index++;
		}
		return input;

		/*
		int r=0;
		for(final att in _attributes) {
			switch(att.name) {

			}
			input.attributes.add(new dml.VertexAttribute(_graphicsDevice,0,r,att.offset,att.stride,dml.DataType.Float32,null,true));
			r++;
		}*/
		/*
	  factory VertexAttribute(GraphicsDevice device,
          int vboSlot, int attributeIndex, int attributeOffset,
          int attributeStride, DataType dataType, int dataCount,
          bool normalizeData) {*/

	}

	void fromMap(Map map) {
		for(var att in _attributes) {
			att.destroy();
		}
		_attributes.clear();




    final attributes = map;//map['attributes'];
    List<String> names = attributes['names'];
    List<String> formats = attributes['formats'];
    List<int> offsets = attributes['offsets'];
    List<int> strides = attributes['strides'];
    var length = names.length;
    for(int i=0; i<length;i++) {
    	final att = new _VertexAttribute(names[i],formats[i],offsets[i],strides[i]);
    	_attributes.add(att);
    	//dml.
      /*_parameters.*/
    	//_attributes.add(new dml.VertexAttribute(_graphicsDevice,names[i],formats[i],offsets[i],strides[i]));
    }
    // sort smallest offset to biggest
    _attributes.sort((a,b) => a.offset > b.offset ? 1 : -1);
    StringBuffer buffer = new StringBuffer();
    for(final att in _attributes) {
    	buffer.write(att.toString());
    	//print(att.offset);
    }
    // stride is always the same for all attributes...
    _bytesPerVertex = _attributes.last.stride;

    _hash = buffer.toString();
	}

}

class TextureManager {

}

class BufferPart {
	Mesh mesh;
	int offset;
	int size;
	VertexBuffer buffer;
}
class VertexBuffer {
	final List<BufferPart> usedParts = [], freeParts = [];
	final dml.VertexBuffer _vertBuffer;
	final dml.VertexArray _vertArray;
	final int size;
	int _curroffset = 0;
	final _VertexBufferFormat _format;
	final bytesPerVertex;
	final maxIndexable;
	VertexBuffer(dml.GraphicsDevice device, int size, _VertexBufferFormat format, this.maxIndexable) : this.size = size,
			this.bytesPerVertex = format.bytesPerVertex, this._format = format, this._vertBuffer = new dml.VertexBuffer(device),
			this._vertArray = new dml.VertexArray(device) {
		_vertBuffer.allocate(size*format._bytesPerVertex, dml.UsagePattern.DynamicDraw);
		_vertArray.setVertexBuffer(0,_vertBuffer);
		_vertArray.setInputLayout(_format.generateInputLayout());
	}

	bool addMesh(Mesh mesh) {
		final vetexData = mesh._vertexList;
		final byteSize = vetexData.elementSizeInBytes * vetexData.length;
		final jumpSize = 512;
		var _erg = byteSize / jumpSize;
		var _erg2 = _erg - _erg.floorToDouble();

		final endSize = _erg2 > 0.0 ? _erg.floor() * jumpSize + jumpSize : _erg.floor() * jumpSize;

		/*if(usedParts.isEmpty) {
			_vertBuffer.uploadSubData(0, vetexData);
			final part = new BufferPart()
				..mesh = mesh
				..offset = 0
				..size = endSize
				..buffer = this;
			mesh._bufferPart = part;
			mesh._vertexBufferOffset = 0;
			_curroffset = endSize;
			usedParts.add(part);
			return true;
		}*/
		if(freeParts.isNotEmpty) {
			// TODO: use a part that has been freed

		}

		//print('buffer remainingSize: ${size-_curroffset}  meshSize: $endSize ');

		// Return false if the mesh does not fit into the buffer...
		if(endSize > (size-_curroffset)) {
			return false;
		}
		_vertBuffer.uploadSubData(0, vetexData);
		final part = new BufferPart()
			..mesh = mesh
			..offset = _curroffset
			..size = endSize
			..buffer = this;
		mesh._bufferPart = part;
		mesh._vertexBufferOffset = _curroffset;
		mesh._vertexArray = _vertArray;
		_curroffset += endSize;
		usedParts.add(part);
		return true;


	}

}

class VertexBufferManager {
	final maxIndexable;
	final Map<String,dynamic> bufferMap = {};
	VertexBufferManager(this.maxIndexable);

	void createVertexMesh(Mesh mesh, _VertexBufferFormat format) {
		var vertBuffer = bufferMap[format.hash];
		if(vertBuffer == null) {
			// TODO: create new VertexBuffer with size maxIndexable
			//final vertArray = new dml.VertexArray(_graphicsDevice);
			//final vertBuffer = new dml.VertexBuffer(_graphicsDevice);
			//vertBuffer.allocate(maxIndexable*format._bytesPerVertex, dml.UsagePattern.DynamicDraw);
			//vertArray.setVertexBuffer(0,vertBuffer);
			//vertBuffer.uploadSubData(int,buffer);
			vertBuffer = new VertexBuffer(_graphicsDevice,maxIndexable*format._bytesPerVertex,format,maxIndexable);
			bufferMap[format.hash] = vertBuffer;

		} else if(vertBuffer is List) {

		}
		if(vertBuffer.addMesh(mesh)) {
			return;
		}


	}
}



class RenderPass {
  final int index;
  static const background = const RenderPass(0);
  static const geometry = const RenderPass(1);
  static const alphaTest = const RenderPass(2);
  static const transparent = const RenderPass(3);
  static const overlay = const RenderPass(4);
  const RenderPass(this.index);

  static parse(String pass) {
  	switch(pass) {
  		case('background'):
  		return background;
  		case('geometry'):
  		return geometry;
  		case('alphaTest'):
  		return alphaTest;
  		case('transparent'):
  		return transparent;
  		case('overlay'):
  		return overlay;
  	}
  	throw 'pass $pass does not exist';
  }
}

class CameraView {

}

class EngineSettings {
  static bool useSimd = false;
}
/// Rendermanager is in charge for how everything gets rendered and
/// tries to optimize sending data to the gpu as much as possible
class RenderManager {
	/// GraphicsDevice for sending Commands to the GPU
  final dml.GraphicsDevice _device;
  /// VertexBufferManager
  VertexBufferManager _vertexBufferManager;


  final ForwardRenderer _forwardRenderer = new ForwardRenderer();


  /// List of shaders that still needs to be compiled
  final List<Shader> _shaderNeedCompile = [];
  dml.Viewport _viewport;

  /// Opaque BlendState
  final _opaque = new dml.BlendState.opaque(_graphicsDevice);
  /// Additive BlendState
  final _additive = new dml.BlendState.additive(_graphicsDevice);
  /// Alpha BlendState
  final _alphaBlend = new dml.BlendState.alphaBlend(_graphicsDevice);
  /// Non premulitpied BlendState
  final _nonPremultiplied = new dml.BlendState.nonPremultiplied(_graphicsDevice);

  /// Ignore Depth
  final _depthNone = new dml.DepthState.none(_graphicsDevice);
  /// Read but not write depth
  final _depthRead = new dml.DepthState.depthRead(_graphicsDevice);
  /// Write & Read depth
  final _depthWrite = new dml.DepthState.depthWrite(_graphicsDevice);

  bool _doClear, _hasAmbient;
  double _lightingScale;
  Vector4 _ambientColor, _backgroundColor;
  /// Background Queue does not write depth, first pass
  final List<RenderJob> backgroundQueue = new List<RenderJob>(),
  /// GeometryQueue is for rendering solid geometry, writes & reads depth. Renders front to back
                        geometryQueue = new List<RenderJob>(),
  /// AlphaTestQueue is for rendering geometry that has some parts that are cut out. Renders front to back
                        alphaTestQueue = new List<RenderJob>(),
  /// TransparentQueue is for transparent objects, reads depth only. Renders Back to Front
                        transparent = new List<RenderJob>(),
  /// OverlayQueue ignores depth informatins for renderer.
                        overlayQueue = new List<RenderJob>();

  /// Current visible PointLights
  List<Light> _pointLights;
  /// Current visible SpotLights
  List<Light> _spotLights;
  /// Current visible DirectionalLights
  List<Light> _directionalLights;
  /// Global directional Lights
  /// TODO: should there be more then one?
  List<Light> _globalDirectionalLights;
  //final GlobalParameters _globalParameters = new GlobalParameters();
  Matrix4 _globalCameraMatrix;
  Aabb3 _sceneBounds;
  /// Currently used camera
  Camera _currentCamera;


  /// Initializes Mesh
  Future<Mesh> _initMesh(Mesh mesh, Map data) {
  	final _format = new _VertexBufferFormat();

    //final vertexBuffer = new Float32List.view(base64decoder.decode(data['vertices']));
    //final indexBuffer = new Uint16List.view(base64decoder.decode(data['indices']));
  	mesh._idxBuff = new dml.IndexBuffer(_graphicsDevice)
  	..upload(mesh._indexList, dml.UsagePattern.StaticDraw);
    _format.fromMap(data['attributes']);


    //_vertexBufferManager.createVertexMesh(mesh,_format);



    var vertexArray = new dml.VertexArray(_device);
    final vertxBuffer = new dml.VertexBuffer(_device);
    vertxBuffer.upload(mesh._vertexList, dml.UsagePattern.DynamicDraw);
    vertexArray.setVertexBuffer(0, vertxBuffer);
    vertexArray.setInputLayout(_format.generateInputLayout());

    mesh._vertexArray = vertexArray;
    mesh._vertexBufferOffset = 0;
    mesh._vertexBufferSubSize = mesh._indexList.length;



  	return new Future<Mesh>.value(mesh);
  }

  /// Initializes Shaders
  Future<Shader> _initShader(Shader shader, Map data) {
  	//print('init shader');
  	final properties = data['properties'];
  	final subshaders = data['subshaders'];

  	for(var subshader in subshaders) {
  		final pass = RenderPass.parse(subshader['renderpass']);
  		final shaderType = subshader['type'];
  		final vs = subshader['vs'];
  		final fs = subshader['fs'];
  		//print('Shader: ${shader.assetId} ------------------');
  		//print(vs);
  		//print(fs);
  		//print('LINK SHADER ------------------');
  		final vertShader = new dml.VertexShader(_device)
  		..source = vs;
  		final fragShader = new dml.FragmentShader(_device)
  		..source = fs;
  		final program = new dml.ShaderProgram(_device)
  		..fragmentShader = fragShader
  		..vertexShader = vertShader
  		..link('shader');
  		shader._passes[pass] = program;
  		//print('Shader END ------------------');
      //print(vs);
      //print(fs);
  		//subshaders: [{renderpass: alphaTest, type: surface, vs: '', fs: ''}]

  	}
  	return new Future<Shader>.value(shader);
  }

  /// Initializes Renderer
  void _initRenderer(Renderer renderer) {
    List<RenderJob> jobs = renderer._renderJobs;
    for(var job in jobs) {
    	RenderJob.destroy(job);
    }
    jobs.clear();

    final shader = renderer.sharedMaterial.shader;
    shader._passes.forEach((pass,program) {
    	var job = new RenderJob();
      job.material = renderer.sharedMaterial;
      job.program = program;
      job.pass = pass;
      job.mesh = renderer.mesh;
      job.renderer = renderer;
      jobs.add(job);
    });
  }

  dml.SamplerState _samplerState;


  RenderManager(this._device) {
  	_samplerState = new dml.SamplerState.linearWrap(_device);
  	_vertexBufferManager = new VertexBufferManager(65536/*_device.capabilities.hasUnsignedIntIndices*/);
    _canvasSizeHeight = _device.canvasHeight;
    _canvasSizeWidth = _device.canvasWidth;
    _fbSizeWidth = _device.frontBufferWidth;
    _fbSizeHeight = _device.frontBufferHeight;
    _realSizeWidth = _device.realWidth;
    _realSizeHeight = _device.realHeight;
    _viewport = new dml.Viewport()
    ..height = _canvasSizeHeight
    ..width = _canvasSizeWidth
    ..aspectRatio = _realSizeWidth / _realSizeHeight
    ..x = 0
    ..y = 0;
  }

  int _canvasSizeWidth, _canvasSizeHeight;
  int _fbSizeWidth, _fbSizeHeight;
  int _realSizeWidth, _realSizeHeight;


  final Map<Material,List<Renderer>> _renderSortMap = {};
  int _f = 0;

  /// Render the Scene
  void _render() {

  	/// Reset all render queues
    backgroundQueue.clear();
    geometryQueue.clear();
    alphaTestQueue.clear();
    transparent.clear();
    overlayQueue.clear();

    final dml.GraphicsDevice device = _device;
    final dml.GraphicsContext context = _device.context;
    //print('render... $_f');
    //_f++;
    //return;
    if(_device.isContextLost) {
    	// TODO: Handle context lost...
    	print('Context LOST!');
    }
    /// Test if Canvas has been resized
    if(_device.realWidth != _realSizeWidth || _device.realWidth != _realSizeWidth) {
      // On Browsers the canvas got changed via css
      _realSizeWidth = _device.realWidth;
      _realSizeHeight = _device.realHeight;
      _viewport.aspectRatio = _realSizeWidth / _realSizeHeight;

    }

    if(_canvasSizeHeight != _device.canvasHeight) {
      _canvasSizeHeight = _device.canvasHeight;
      _viewport.height = _canvasSizeHeight;
    }

    if(_canvasSizeWidth != _device.canvasWidth) {
      _canvasSizeWidth = _device.canvasWidth;
      _viewport.width = _canvasSizeWidth;
    }

    //print('Scene camera: ${Camera._current}');

    /// Update visible Objects of the current active Camera
    final renderCamera = Camera._current;

    /// If there is no camera we have nothing to render
    if(renderCamera == null) return;

    /// Always render the current scene
    final scene = Scene.current;
    scene._updateVisibleNodes(renderCamera);
    renderCamera._prepareForRendering();

    _prepareRenderers(renderCamera, scene);
    _prepareLights(renderCamera, scene);

   // print(geometryQueue.length);



    context.setViewport(_viewport);
    context.clearColorAndDepthBuffer(renderCamera.backgroundColor[0],
    		renderCamera.backgroundColor[1], renderCamera.backgroundColor[2], 1.0, 1.0);

    //device.clear(camera.backgroundColor, 1.0, 1.0);
    context.setPrimitiveTopology(dml.PrimitiveTopology.Triangles);


    context.setDepthState(_depthWrite);
    context.setBlendState(_opaque);

    final Map<String,dynamic> currentConstants = {};
    final List<dynamic> currentTextures = new List<dynamic>(5);

    var lastUsedVertexArray;
    var lastUsedIndexBuffer;
    var lastUsedShaderProgram;
    var lastUsedMaterial;



    final drawJobs = (List<RenderJob> renderJobs) {
    	for(final renderJob in renderJobs) {
    		final renderConstants = renderJob.renderer._rendererConstants;
    		final mesh = renderJob.mesh;
    		final material = renderJob.material;
    		final shaderProgram = renderJob.program;
    		final wm = renderConstants.worldMatrix;
    		final wvp = renderConstants.worldViewProjection;

    		final vertexArray = mesh._vertexArray;
    		final indexBuffer = mesh._idxBuff;
    		final indexCount = mesh._indexList.length;
    		final drawOffset = mesh._vertexBufferOffset;

    		if(shaderProgram != lastUsedShaderProgram) {
    			context.setShaderProgram(shaderProgram);
    			lastUsedShaderProgram = shaderProgram;
    		}
    		context.setConstant('MATRIX_MVP', wvp.storage);
    		context.setConstant('cameraTransform', wvp.storage);


    		//renderJob.material._textures


    		//context.setTexture(0, null);




    		final uniforms = material._uniforms;
    		shaderProgram.forEachUniform((u) {
    			final name = u.name;
    			final constant = uniforms[name];
    			if(constant == null) {
    				switch(name) {
    					case('lightmapTilingOffset'):
    						break;
    					case('BONE_MATRICES[0]'):
    						break;
    				}
    				return;
    			}
    			if(currentConstants[name] != constant) {
    				currentConstants[name] = constant;
    				context.setConstant(name, constant);
    			}

    			//print(u.name);
    		});

    		/*
    		if(renderJob.renderer is MeshRenderer) {
    			print(scene._lightmaps[renderJob.renderer._lightmapIndex].isLoaded);
    		}*/





    		shaderProgram.forEachSampler((s) {
    			final tex = material._textures[s.name];
    			if(tex == null) {
    				// Test if it
    				final renderer = renderJob.renderer;
    				if(renderer is MeshRenderer) {
    					if(renderer._lightmapIndex == null) return;
    					final lightmap = scene._lightmaps[renderer._lightmapIndex];

        			final glTexture = lightmap._texture;
        			final unit = s.textureUnit;
        			if(currentTextures[unit] == glTexture) return;
        			currentTextures[unit] = glTexture;
        			context.setTexture(unit, glTexture);
        			context.setSampler(unit, _samplerState);
        			context.setConstant('lightmapTilingOffset', renderer._lightmapTiling.storage);
        			//print(renderer._lightmapTiling);
        			// TODO: Write Tiling informations!

    					//print('Do we have lightmaps? ${s.name}  ${scene._lightmaps[renderer._lightmapIndex]}');

    					// Do we have a light texture?
    				}

    				//print('missing texture: ${s.name}');
    				final other = material._textures.values.first;
    				final unit = s.textureUnit;
    				//print('${other._texture} + $unit');
      			context.setTexture(unit, other._texture);
      			context.setSampler(unit, _samplerState);
    				return;
    			}
    			final glTexture = tex._texture;
    			final unit = s.textureUnit;
    			if(currentTextures[unit] == glTexture) return;
    			currentTextures[unit] = glTexture;
    			context.setTexture(unit, glTexture);
    			context.setSampler(unit, _samplerState);
					//print('${s.name} ${unit}');
    		});



    		//material._textures.forEach(f)


				// set indexbuffer before vertexArray, vertexArray gets deleted otherwise
    		//
    		/*if(lastUsedIndexBuffer != indexBuffer) {
    			context.setIndexBuffer(indexBuffer);
    			lastUsedIndexBuffer = indexBuffer;
    		}*/

    		if(lastUsedVertexArray != vertexArray) {
    			context.setVertexArray(vertexArray);
    			lastUsedVertexArray = vertexArray;
    		}
    		if(lastUsedIndexBuffer != indexBuffer) {
    			vertexArray.setIndexBuffer(indexBuffer);
    			lastUsedIndexBuffer = indexBuffer;
    		}



    		//print('indexCount: $indexCount offset: $drawOffset');
    		context.drawIndexed(indexCount, drawOffset);

    	}
    };

    /*
    if (shadowMaps) {
      var sceneBounds = _sceneBounds;
      var minExtentsHigh = (Math.max((sceneExtents[3] - sceneExtents[0]),
                                     (sceneExtents[4] - sceneExtents[1]),
                                     (sceneExtents[5] - sceneExtents[2])) / 6.0);

      shadowMaps.lowIndex = 0;
      shadowMaps.highIndex = 0;
      this.drawShadowMaps(gd, globalTechniqueParameters, this.pointLights, shadowMaps, minExtentsHigh);
      this.drawShadowMaps(gd, globalTechniqueParameters, this.spotLights, shadowMaps, minExtentsHigh);
      this.drawShadowMaps(gd, globalTechniqueParameters, this.localDirectionalLights, shadowMaps, minExtentsHigh);
      shadowMaps.blurShadowMaps();
    }
    */
    /*
     if (postFXsetupFn)
        {
            usingRenderTarget = gd.beginRenderTarget(this.finalRenderTarget);
        }
    */


    if(backgroundQueue.isNotEmpty) {
      //print('baaackground!');
    	//drawJobs(backgroundQueue);
      //device.drawQueue(backgroundQueue, _globalParameters, -1);
    }

    // For now this is only simple forward rendering
    if(geometryQueue.isNotEmpty) {
    	/*geometryQueue.sort((a,b) {
    		if(a.sortKey < b.sortKey) {
    			return 1;
    		} else if(a.sortKey > b.sortKey) {
    			return -1;
    		}
    		return 0;
    	});*/
    	drawJobs(geometryQueue);
    	//drawJobs([geometryQueue.first]);
      //print('geometryQueue!');
      //var last = geometryQueue.removeLast();
      //print('Last: ${last.shader.name}');
      //geometryQueue.insert(0, last);
      //device.drawQueue(geometryQueue, _globalParameters, -1);
    }

    //context.renderingDone();
    return;


    if(alphaTestQueue.isNotEmpty) {
      //print('alphaTestQueue!');
      //device.drawQueue(alphaTestQueue, _globalParameters, -1);
    }

    //device.setDepthMode(DepthMode.depthRead);
    device.setBlendMode(BlendMode.additive);
    if(transparent.isNotEmpty) {
      //print('transparent!');
      device.drawQueue(transparent, _globalParameters, -1);
    }

    if(overlayQueue.isNotEmpty) {
      //print('overlayQueue!');
      device.drawQueue(overlayQueue, _globalParameters, -1);
    }
    device.debugDraw(camera._viewProjectionMatrix);

    /*
    if (usingRenderTarget)
    {
      gd.endRenderTarget();
      var finalTexture = this.finalTexture;

      postFXsetupFn(gd, finalTexture);

      gd.setStream(this.quadVertexBuffer, this.quadSemantics);
      gd.draw(this.quadPrimitive, 4);
    }*/


  }


  static _prepareRenderer(Renderer renderer) {
  	//print('PREPARE RENDERER!');
    _renderManager._initRenderer(renderer);
  }
  /*
  void _drawAmbientPass(Vector4 ambientColor) {

  }

  void _drawShadowMaps(List<Light> lights, shadowmaps, double minBoundHight) {
    for(var light in lights) {
      if (light.shadows && light.lightType != LightType.ambient) {
        shadowMaps.drawShadowMap(_globalCameraMatrix, minBoundHight, light._parameters);
      }

    }

    drawShadowMaps(gd, globalTechniqueParameters, lightInstances, shadowMaps, minExtentsHigh)
    {
        var numInstances = lightInstances.length;
        if (!numInstances)
        {
            return;
        }

        var lightInstance, light;
        var l;
        var globalCameraMatrix = this.globalCameraMatrix;
        //var minPixelCountShadows = this.minPixelCountShadows;

        l = 0;
        do
        {
            lightInstance = lightInstances[l];
            if (!lightInstance.numVisibleDrawParameters)
            {
                l += 1;
                continue;
            }
            light = lightInstance.light;

            // TODO: pixel count test
            if (light.shadows &&
                !light.ambient /*&&
                lightInstance.pixelCount >= minPixelCountShadows*/)
            {
                shadowMaps.drawShadowMap(globalCameraMatrix, minExtentsHigh, lightInstance);
            }

            l += 1;
        }
        while (l < numInstances);
    }
  }*/


  void _prepare() {
    Scene scene = Scene.current;
    Camera camera = Camera.current;
    List<Light> globalLight = scene._globalLights;
    double ambientR, ambientG, ambientB;
    //Scene.current._updateVisibleGameObjects(camera);



    _globalParameters.projection = camera._projectionMatrix;
    _globalParameters.viewProjection = camera._viewProjectionMatrix;
    _globalParameters.eyePosition = camera.transform._internalPosition;




    _prepareRenderers(camera, scene);
    _prepareLights(camera, scene);

    for(Light light in globalLight) {
      if(light.enabled && light.lightType == LightType.ambient) {
        ambientR = light.color.storage[0] * _lightingScale;
        ambientG = light.color.storage[1] * _lightingScale;
        ambientB = light.color.storage[2] * _lightingScale;
      }
    }
    if(ambientR != null) {
      _ambientColor.setValues(ambientR, ambientG, ambientB);
    } else {
      // disable ambient light
    }

    for(var pointLight in _pointLights) {
      var worldView = pointLight.transform._internalWorld;
      LightParameters params = pointLight._parameters;
      params.lightColor.storage[0] = pointLight.color.storage[0] * _lightingScale;
      params.lightColor.storage[1] = pointLight.color.storage[1] * _lightingScale;
      params.lightColor.storage[2] = pointLight.color.storage[2] * _lightingScale;
      pointLight.transform.getPosition(params.lightPosition);

      /*
      lightViewInverseTranspose = md.m43InverseTransposeProjection(worldView, light.halfExtents,
          lightViewInverseTranspose);
      lightFalloff[0] = lightViewInverseTranspose[8];
      lightFalloff[1] = lightViewInverseTranspose[9];
      lightFalloff[2] = lightViewInverseTranspose[10];
      lightFalloff[3] = lightViewInverseTranspose[11];

      lightViewInverseTranspose[8] = 0;
      lightViewInverseTranspose[9] = 0;
      lightViewInverseTranspose[10] = 0;
      lightViewInverseTranspose[11] = 1.0;

      lightViewInverseTransposeFalloff = techniqueParameters.lightViewInverseTransposeFalloff;
      lightViewInverseTransposeFalloff.setData(lightViewInverseTranspose, 0, 12);
      lightViewInverseTransposeFalloff.setData(lightFalloff, 12, 4);
      */

    }
    for(var spotLight in _spotLights) {
      LightParameters params = spotLight._parameters;
      params.lightColor.storage[0] = spotLight.color.storage[0] * _lightingScale;
      params.lightColor.storage[1] = spotLight.color.storage[1] * _lightingScale;
      params.lightColor.storage[2] = spotLight.color.storage[2] * _lightingScale;
      spotLight.transform.getPosition(params.lightPosition);
      /*
      var frustum = light.frustum;
      var frustumNear = light.frustumNear;
      var invFrustumNear = 1.0 / (1 - frustumNear);
      lightView = md.m33MulM43(frustum, worldView, lightView);
      lightViewInverse = md.m43Inverse(lightView, lightViewInverse);
      lightProjection[8] = invFrustumNear;
      lightProjection[11] = -(frustumNear * invFrustumNear);
      lightViewInverseProjection = md.m43Mul(lightViewInverse, lightProjection, lightViewInverseProjection);
      lightViewInverseTranspose = md.m43Transpose(lightViewInverseProjection, lightViewInverseTranspose);

      lightFalloff[0] = lightViewInverseTranspose[8];
      lightFalloff[1] = lightViewInverseTranspose[9];
      lightFalloff[2] = lightViewInverseTranspose[10];
      lightFalloff[3] = lightViewInverseTranspose[11];

      lightViewInverseTransposeFalloff = techniqueParameters.lightViewInverseTransposeFalloff;
      lightViewInverseTransposeFalloff.setData(lightViewInverseTranspose, 0, 12);
      lightViewInverseTransposeFalloff.setData(lightFalloff, 12, 4);
      */
    }
    /*
    for(var directionalLight in _localDirectionalLight) {

    }*/
    if(_globalDirectionalLights.isNotEmpty) {
      if (directionalLightsUpdateVisibleRenderables(gd)) {
        var bounds = scene._bounds;
        var sceneDirectionalLightDistance = (-1e5) * ((bounds.max.storage[0] - bounds.min.storage[0]) +
                                                      (bounds.max.storage[1] - bounds.min.storage[1]) +
                                                      (bounds.max.storage[2] - bounds.min.storage[2]));
        var halfExtents = new Vector3(bounds.max.storage[0] - bounds.min.storage[0],
                                      bounds.max.storage[1] - bounds.min.storage[1],
                                      bounds.max.storage[2] - bounds.min.storage[2]);
        lightFalloff[0] = lightViewInverseTranspose[8];
        lightFalloff[1] = lightViewInverseTranspose[9];
        lightFalloff[2] = lightViewInverseTranspose[10];
        lightFalloff[3] = lightViewInverseTranspose[11];

        lightViewInverseTranspose[8] = 0.0;
        lightViewInverseTranspose[9] = 0.0;
        lightViewInverseTranspose[10] = 0.0;
        lightViewInverseTranspose[11] = 1.0;

        lightViewInverseTransposeFalloff = this.lightViewInverseTransposeFalloff;
        lightViewInverseTransposeFalloff.setData(lightViewInverseTranspose, 0, 12);
        lightViewInverseTransposeFalloff.setData(lightFalloff, 12, 4);
        for(var directionalLight in _globalDirectionalLights) {
          LightParameters params = directionalLight._parameters;
          params.lightColor.storage[0] = directionalLight.color.storage[0] * _lightingScale;
          params.lightColor.storage[1] = directionalLight.color.storage[1] * _lightingScale;
          params.lightColor.storage[2] = directionalLight.color.storage[2] * _lightingScale;
          directionalLight.transform.getPosition(params.lightPosition);
          /*
          md.v3Normalize(light.direction, lightAt);
          origin = md.v3ScalarMul(lightAt, sceneDirectionalLightDistance);
          techniqueParameters.lightOrigin = md.m43TransformPoint(viewMatrix, origin,
              techniqueParameters.lightOrigin);
          */
        }
      }
    }
  }

  void _prepareRenderers(Camera camera, Scene scene) {
    List<Renderer> renderers = scene._visibleRenderers;
    double sortDistance;
    var invMaxDistance = (0.0 < scene._maxDistance ? (1.0 / scene._maxDistance) : 0.0);
    if(EngineSettings.useSimd) {
      for(Renderer renderer in renderers) {
        if(!renderer._isReadyToRender) continue;
        renderer._renderUpdateSIMD(camera);
        sortDistance = renderer._distance;
        // Make sure it is lower than 1.0 to avoid changing the integer part of sortKey
        if (0.0 < sortDistance) {
          sortDistance *= invMaxDistance;
          if (0.999 < sortDistance) {
            sortDistance = 0.999;
          }
        } else {
          // Make sure it is positive to avoid changing the
          // integer part of sortKey
          sortDistance = 0.0;
        }
        for(RenderJob job in renderer._renderJobs) {
          _pushRenderJobToRenderQueue(job);
        }
      }
    } else {
      for(Renderer renderer in renderers) {
        if(!renderer._isReadyToRender) continue;
        renderer._renderUpdate(camera);
        sortDistance = renderer._distance;
        // Make sure it is lower than 1.0 to avoid changing the integer part of sortKey
        if (0.0 < sortDistance) {
          sortDistance *= invMaxDistance;
          if (0.999 < sortDistance) {
            sortDistance = 0.999;
          }
        } else {
          // Make sure it is positive to avoid changing the
          // integer part of sortKey
          sortDistance = 0.0;
        }
        for(RenderJob job in renderer._renderJobs) {
          _pushRenderJobToRenderQueue(job);
        }
      }
    }


    /*
    for(var drawParameters in parameters) {
    int passIndex = drawParameters.passIndex;
    if (passIndex <= RenderPass.ambient.index) {
    drawParameters.sortKey = ((drawParameters.sortKey | 0) + sortDistance);
    } else if (passIndex == RenderPass.transparent) {
    drawParameters.sortKey = sortDistance;
    }
    // adds the paramaters to fitting pass

    addToPass(passIndex);
    }
    var diffuseDrawParameters = renderer._diffuseDrawParameters;
    if(diffuseDrawParameters != null) {
    for(var drawParameters in diffuseDrawParameters) {
    drawParameters.removeInstances();
    }

    }
    var shadowParameters = rendere
    var shadowParameters = rendere
    var shadowParameters = rendere
    var shadowParameters = rendere
    var shadowParameters = renderer._diffuseShadowParameters;
    if (shadowParameters != null) {
    for(var drawParameters in shadowParameters) {
    drawParameters.removeInstances();
    }

    }*/
  }

  void _pushRenderJobToRenderQueue(RenderJob job) {
    switch(job.pass) {
      case(RenderPass.background):
        //job.sortKey = ((job.sortKey | 0) + sortDistance);
        backgroundQueue.add(job);
      break;
      case(RenderPass.geometry):
        //job.sortKey = ((job.sortKey | 0) + sortDistance);
        geometryQueue.add(job);
      break;
      case(RenderPass.alphaTest):
        //job.sortKey = ((job.sortKey | 0) + sortDistance);
        alphaTestQueue.add(job);

      break;
      case(RenderPass.transparent):
        //job.sortKey = ((job.sortKey | 0) + sortDistance);
        transparent.add(job);

      break;
      case(RenderPass.overlay):
        //job.sortKey = ((job.sortKey | 0) + sortDistance);
        overlayQueue.add(job);
      break;
    }

  }

  void _prepareLights(Camera camera, Scene scene) {
    List<Light> visibleLights = scene._visibleLights;
    if(visibleLights.isNotEmpty) {
      for(int i=0; i < visibleLights.length; i++) {
        Light light = visibleLights[i];
        if(_isLightRelevantToRenderers(light, scene)) {
          switch(light.lightType) {
            case(LightType.point):
              _pointLights.add(light);
              break;
            case(LightType.spot):
              _spotLights.add(light);
              break;
            case(LightType.directional):
              _directionalLights.add(light);
              break;
          }
        } else {
          visibleLights.removeAt(i);
          i--;
        }
      }

    }
    List globalLights = scene._globalDirectionalLights;//scene._globalLights;
    if(globalLights.isNotEmpty) {
      for(Light globalLight in globalLights) {
        if(globalLight.enabled && globalLight.lightType == LightType.directional) {
          _globalDirectionalLights.add(globalLight);
        }

      }
    }
  }

  bool _isLightRelevantToRenderers(Light light, Scene scene) {

  }

}