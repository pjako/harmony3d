part of harmony;


class RenderInfo {
  //final List<RenderJob> renderJobs = [];
}

class ForwardRenderInfo {

}

class DefferedRenderInfo {

}
class ShadowMapping {

}



class ForwardRenderer {
	ShadowMapping shadowMaps;
  final List<RenderJob> backgroundQueue = new List<RenderJob>(),
                        geometryQueue = new List<RenderJob>(),
                        alphaTestQueue = new List<RenderJob>(),
                        transparent = new List<RenderJob>(),
                        overlayQueue = new List<RenderJob>();

  void prepareRenderers(final List<Renderer> renderers, final Camera camera) {
    /*var passIndex;
    var passesSize = this.passesSize;
    var passes = this.passes;
    var numPasses = this.numPasses;
    for (passIndex = 0; passIndex < numPasses; passIndex += 1) {
        passesSize[passIndex] = 0;
    }*/

    //var visibleRenderables = scene.getCurrentVisibleRenderables();
    //this.visibleRenderables = visibleRenderables;
    //var numVisibleRenderables = visibleRenderables.length;
    if (renderers.isNotEmpty) {
      //var n, renderable, rendererInfo, passSize;
      //var drawParametersArray, numDrawParameters, drawParametersIndex, drawParameters, sortDistance;
      //var transparentPassIndex = this.passIndex.transparent;
      //var ambientPassIndex = this.passIndex.ambient;
      var maxDistance = scene._maxDistance;
      var invMaxDistance = (0.0 < maxDistance ? (1.0 / maxDistance) : 0.0);
      for(final Renderer renderer in renderers) {
        double sortDistance = renderer._distance;

        RenderInfo rendererInfo = renderer._renderInfo;
        if (rendererInfo == null) {
            rendererInfo = createRenderInfo(renderable);
        }

        if (rendererInfo.far) {
          renderer._distance = 1.e38;
        }

        renderable.renderUpdate(camera);



        if (0.0 < sortDistance) {
          sortDistance *= invMaxDistance;
          // Make sure it is lower than 1.0 to avoid changing the integer part of sortKey
          if (0.999 < sortDistance) {
              sortDistance = 0.999;
          }
        } else {
          // Make sure it is positive to avoid changing the
          // integer part of sortKey
          sortDistance = 0.0;
        }

        for(var renderJob in renderer._renderJobs) {
          int passIndex = renderJob.pass.index;
          if (passIndex <= ambientPassIndex) {
              /* tslint:disable:no-bitwise */
            renderJob.sortKey = ((drawParameters.sortKey | 0) + sortDistance);
              /* tslint:enable:no-bitwise */
          } else if (passIndex == RenderPass.transparent) {
            drawParameters.sortKey = sortDistance;
          }
          passSize = passesSize[passIndex];
          passes[passIndex][passSize] = drawParameters;
          passesSize[passIndex] = (passSize + 1);

        }
      }

      }
    for (passIndex = 0; passIndex < numPasses; passIndex += 1) {
	    passes[passIndex].length = passesSize[passIndex];
    }
  }







    /*
  final _l = [];
  void prepareLights(Scene scene) {
    var pointLights = this.pointLights;
    var spotLights = this.spotLights;
    var localDirectionalLights = this.localDirectionalLights;
    var globalDirectionalLights = this.globalDirectionalLights;

    var numPoint = 0;
    var numSpot = 0;
    var numLocalDirectional = 0;
    var numGlobalDirectional = 0;

    var visibleLights = scene.getCurrentVisibleLights();
    var numVisibleLights = visibleLights.length;
    var lightInstance, light, l;
    final List<Light> lights = null;
    for(final light in lights) {
      if(_lightVisibleToRenderers()) {
        switch(light.lightType) {
          case(LightType.spot):
            break;
          case(LightType.point):
            break;
          case(LightType.directional)
        }
      }
    }



    if (numVisibleLights)
    {
        //var widthToPixel = (0.5 * gd.width);
        //var heightToPixel = (0.5 * gd.height);
        //var minPixelCount = this.minPixelCount;
        //var minPixelCountShadows = this.minPixelCountShadows;
        //var screenExtents;

        l = 0;
        do
        {
            lightInstance = visibleLights[l];
            light = lightInstance.light;
            if (light)
            {
                if (!light.global)
                {
                    lightInstance.shadows = false;

                    if (this.lightFindVisibleRenderables(gd, lightInstance, scene))
                    {
                        if (light.spot)
                        {
                            spotLights[numSpot] = lightInstance;
                            numSpot += 1;
                        }
                        else if (light.point)
                        {
                            // this includes local ambient lights
                            pointLights[numPoint] = lightInstance;
                            numPoint += 1;
                        }
                        else if (light.directional)
                        {
                            // this includes local ambient lights
                            localDirectionalLights[numLocalDirectional] = lightInstance;
                            numLocalDirectional += 1;
                        }
                        // this renderer does not support fog lights yet
                    }
                    else
                    {
                        numVisibleLights -= 1;
                        if (l < numVisibleLights)
                        {
                            visibleLights[l] = visibleLights[numVisibleLights];
                            continue;
                        }
                        else
                        {
                            break;
                        }
                    }
                }
            }

            l += 1;
        }
        while (l < numVisibleLights);

        if (numVisibleLights < visibleLights.length)
        {
            visibleLights.length = numVisibleLights;
        }
    }

    var globalLights = scene.getGlobalLights();
    var numGlobalLights = globalLights.length;
    if (numGlobalLights)
    {
        l = 0;
        do
        {
            light = globalLights[l];
            if (light && !light.disabled && light.directional)
            {
                globalDirectionalLights[numGlobalDirectional] = light;
                numGlobalDirectional += 1;
            }

            l += 1;
        }
        while (l < numGlobalLights);
    }

    // Clear remaining deleted lights from the last frame
    globalDirectionalLights.length = numGlobalDirectional;
    localDirectionalLights.length = numLocalDirectional;
    pointLights.length = numPoint;
    spotLights.length = numSpot;
  }*/


	void draw(dml.GraphicsDevice device,
	     Vector4 clearColor,
	     bool drawDecalsFn,
	     bool drawTransparentFn,
	     bool drawDebugFn,
	     var postFXsetupFn) {
    var globalTechniqueParameters = this.globalTechniqueParameters;
    var ambientColor = this.ambientColor;
    var context = device.context;

    // TODO: Shadowmaps!
    /*var shadowMaps = this.shadowMaps;
    if (shadowMaps) {
      var sceneExtents = this.sceneExtents;
      var minExtentsHigh = (Math.max((sceneExtents[3] - sceneExtents[0]),
                                     (sceneExtents[4] - sceneExtents[1]),
                                     (sceneExtents[5] - sceneExtents[2])) / 6);

      shadowMaps.lowIndex = 0;
      shadowMaps.highIndex = 0;
      _drawShadowMaps(context, globalTechniqueParameters, pointLights, shadowMaps, minExtentsHigh);
      _drawShadowMaps(context, globalTechniqueParameters, spotLights, shadowMaps, minExtentsHigh);
      _drawShadowMaps(context, globalTechniqueParameters, localDirectionalLights, shadowMaps, minExtentsHigh);
      shadowMaps.blurShadowMaps();
    }*/

    var usingRenderTarget;
    if (postFXsetupFn) {
	    usingRenderTarget = context.beginRenderTarget(this.finalRenderTarget);
    } else {
	    usingRenderTarget = false;
    }

    if (clearColor != null) {
      context.clearColorAndDepthBuffer(clearColor[0], clearColor[1], clearColor[2], 1.0, 0.0);
    } else if (ambientColor) {
    	context.clearColorAndDepthBuffer(0.0, 0.0, 0.0, 1.0, 0.0);
      //gd.clear(null, 1.0, 0);
    } else {
    	context.clearColorAndDepthBuffer(0.0, 0.0, 0.0, 1.0, 0.0);
    }

    var globalTechniqueParametersArray = [globalTechniqueParameters];

    // ambient and emissive pass
    if (clearColor != null &&
        (clearColor[0] ||
         clearColor[1] ||
         clearColor[2] ||
         clearColor[3] != 1.0)) {
      if (!ambientColor) {
        // Need to draw everything on black to cope with the external clear color
        ambientColor = this.v3Zero;
      }
			this.drawAmbientPass(gd, ambientColor);
    } else if (ambientColor) {
      this.drawAmbientPass(gd, ambientColor);
    } else {
	    // Here we may need a fill pass because only a handful of materials may glow
	    gd.drawArray(this.passes[this.passIndex.fillZ], globalTechniqueParametersArray, -1);
	    gd.drawArray(this.passes[this.passIndex.glow], globalTechniqueParametersArray, -1);
    }

    // diffuse pass
    var numDiffuseQueue = this.numDiffuseQueue;
    if (0 < numDiffuseQueue) {
      var diffuseQueue = this.diffuseQueue;
      if (numDiffuseQueue < diffuseQueue.length) {
        diffuseQueue.length = numDiffuseQueue;
      }
      gd.drawArray(diffuseQueue, globalTechniqueParametersArray, -1);
    }

    // decals
    var pass = this.passes[this.passIndex.decal];
    if (0 < pass.length) {
      gd.drawArray(pass, globalTechniqueParametersArray, -1);
    }

    if (drawDecalsFn) {
    	drawDecalsFn();
    }

    // transparent objects
    pass = this.passes[this.passIndex.transparent];
    if (0 < pass.length) {
			gd.drawArray(pass, globalTechniqueParametersArray, 1);
    }

    if (drawTransparentFn) {
      drawTransparentFn();
    }

    if (drawDebugFn) {
			drawDebugFn();
    }

    if (usingRenderTarget) {
	    gd.endRenderTarget();
	    var finalTexture = this.finalTexture;

	    postFXsetupFn(gd, finalTexture);

	    gd.setStream(this.quadVertexBuffer, this.quadSemantics);
	    gd.draw(this.quadPrimitive, 4);
    }
	}



  void _drawShadowMaps(List<Light> lights, shadowMaps, minExtentsHigh) {
	  if (lights.isEmpty) {
      return;
	  }
	  var globalCameraMatrix = this.globalCameraMatrix;
	  //var minPixelCountShadows = this.minPixelCountShadows;

	  for(final light in lights) {
      if (light.numVisibleDrawParameters <= 0) continue;
      if (light.shadows && light.lightType != LightType.ambient) {
        shadowMaps.drawShadowMap(globalCameraMatrix, minExtentsHigh, light);
      }
	  }
  }



}