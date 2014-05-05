part of game_core;

/*
class RenderPass {
  final int index;
  const RenderPass(this.index);

  static const background = const RenderPass(0);
  static const geometry = const RenderPass(1);
  static const alphaTest = const RenderPass(2);
  static const transparent = const RenderPass(3);
  static const overlay = const RenderPass(4);

  static RenderPass parse(String pass) {
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

  }

}
class LightParameters {
  Vector3 lightColor;
  Vector3 lightPosition;
  Matrix4 lightViewInverseTransposeFalloff;
}
*/






class RenderManager {
  //static RenderManager _current = new RenderManager();
  //RenderDevice _renderDevice;
  bool _doClear, _hasAmbient;
  double _lightingScale;
  Vector4 _ambientColor, _backgroundColor;
  final List<RenderJob> backgroundQueue = new List<RenderJob>(),
                        geometryQueue = new List<RenderJob>(),
                        alphaTestQueue = new List<RenderJob>(),
                        transparent = new List<RenderJob>(),
                        overlayQueue = new List<RenderJob>();
  List<Light> _pointLights;
  List<Light> _spotLights;
  List<Light> _directionalLights;
  List<Light> _globalDirectionalLights;
  final GlobalParameters _globalParameters = new GlobalParameters();
  Matrix4 _globalCameraMatrix;
  Aabb3 _sceneBounds;
  Camera _currentCamera;

  

  static _prepareRenderer(Renderer renderer) {
    _renderManager._updateRenderer(renderer);
  }


  void _updateRenderer(Renderer renderer) {
    List<RenderJob> jobs = renderer._renderJobs;
    for(var job in jobs) {
      job.destroy();
    }
    jobs.clear();

    var materialParameters = renderer.sharedMaterial._parameters;
    var shaderParameters = renderer.sharedMaterial.shader._parameters;

    for(Subshader subshader in renderer.sharedMaterial.shader._subshaders) {
      var job = new RenderJob();
      job.shader = subshader;
      job.materialParameters = materialParameters;
      job.renderParameters = renderer._parameters;
      job.meshParameters = renderer._mesh._parameters;
      jobs.add(job);
      _renderDevice.prepareRenderJob(job);
    }


  }
  
  void _onResize() {
    _renderDevice.resize(Screen.width,Screen.height);
    //_currentCamera.aspectRatio
    
  }

  void _updateMaterial(Material material) {

  }

  void _updateShader(Shader shader) {

  }

  void _updateTexture(Shader shader) {

  }


  void _render(Scene scene) {
    backgroundQueue.clear();
    geometryQueue.clear();
    alphaTestQueue.clear();
    transparent.clear();
    overlayQueue.clear();
    //Scene scene = Scene.current;
    Camera camera = Camera.current;
    _currentCamera = camera;
    Vector4 ambientColor = _ambientColor;
    final RenderDevice device = _renderDevice;

    camera._prepareForRendering();
    _prepareRenderers( Camera.current, Scene.current);


    _globalParameters.cameraPosition = new Vector3(camera.transform._worldMatrix[12],
    camera.transform._worldMatrix[13], camera.transform._worldMatrix[14]);
    _globalParameters.projection = camera._projectionMatrix;
    _globalParameters.viewMatrix = camera._viewMatrix;


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
    /*
    if(_doClear) {
      //_gDevice.clear(0.0, 0.0, 0.0, 1.0, 1.0);
    } else if(_hasAmbient) {
      _gDevice.clear(null, 1.0, 1.0);
    } else {
      _gDevice.clear(new Vector4.zero(), 1.0, 1.0);
    }*/
    device.clear(camera.backgroundColor, 1.0, 1.0);


    device.setDepthMode(DepthMode.depthWrite);
    device.setBlendMode(BlendMode.opaque);
    if(backgroundQueue.isNotEmpty) {
      //print('baaackground!');
      device.drawQueue(backgroundQueue, _globalParameters, -1);
    }

    if(geometryQueue.isNotEmpty) {
      //print('geometryQueue!');
      //var last = geometryQueue.removeLast();
      //print('Last: ${last.shader.name}');
      //geometryQueue.insert(0, last);
      device.drawQueue(geometryQueue, _globalParameters, -1);
    }

    if(alphaTestQueue.isNotEmpty) {
      //print('alphaTestQueue!');
      device.drawQueue(alphaTestQueue, _globalParameters, -1);
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
    if(_doClear && _clearColor[3] != 0.0) {
      _drawAmbientPass(ambientColor);
    } else {
        // Here we may need a fill pass because only a handful of materials may glow
      _gDevice.drawQueue(fillZQueue, _globalParameters, -1);

      _gDevice.drawQueue(glowQueue, _globalParameters, -1);
    }


    // diffuse pass
    if(diffuseQueue.isNotEmpty) {
      _gDevice.drawQueue(diffuseQueue, _globalParameters, -1);
    }

    // decals
    if(decalQueue.isNotEmpty) {
      _gDevice.drawQueue(decalQueue, _globalParameters, -1);
    }
    if (drawDecalsFn)
    {
      drawDecalsFn();
    }

    // transparent objects
    if(transparentQueue.isNotEmpty) {
      _gDevice.drawQueue(transparentQueue, _globalParameters, -1);
    }

    if (drawTransparentFn)
    {
      drawTransparentFn();
    }

    if (drawDebugFn)
    {
      drawDebugFn();
    }
    */

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
    if(EngineConfig.useSimd) {
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
    switch(job.shader.pass) {
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
    List globalLights = scene._globalLights;
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