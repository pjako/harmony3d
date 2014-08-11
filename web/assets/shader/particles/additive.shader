{"properties":[{"tagName":"Main Color","varName":"_Color","type":"rgb","defaultValue":[1.0,1.0,1.0]},{"tagName":"Base (RGB)","varName":"_MainTexture","type":"texture2d","defaultValue":"white"},{"tagName":"Cut off","varName":"_cutOff","type":"float","defaultValue":"0.4"}],"subshaders":[{"renderpass":"transparent","type":"surface","vs":"precision highp float;\nattribute vec3 POSITION;\nattribute vec2 TEXCOORD0;\nattribute vec2 TEXCOORD1;\nattribute vec3 NORMAL;\n\nuniform mat4 cameraTransform;\nuniform vec4 lightmapTilingOffset;\n\nvarying vec2 uv_MainTexture;\nvarying vec2 uvLightMap;\nvarying vec3 Normal;\n\nvoid main() {\n Normal = NORMAL;\n uv_MainTexture = TEXCOORD0;\n uvLightMap = TEXCOORD1 * lightmapTilingOffset.xy + lightmapTilingOffset.zw;\n vec4 vPosition4 = vec4(POSITION.x, POSITION.y, POSITION.z, 1.0);\n gl_Position = cameraTransform*vPosition4;\n}\n","fs":"precision mediump float;\nstruct SurfaceOutput {\n    vec3 Albedo;\n    vec3 Normal;\n    vec3 Emission;\n    float Specular;\n    float Gloss;\n    float Alpha;\n};\nstruct Input {\n    vec2 uv_MainTexture;\n};\nstruct v2f_surf {\n    vec4 pos;\n    vec2 hip_pack0;\n    vec3 normal;\n    vec3 vlight;\n};\nvarying vec3 Normal;\n\n//Lightmap\nvarying vec2 uvLightMap;\n\nvarying vec2 uv_MainTexture;\n\nuniform vec3 AmbientColor;\nuniform vec4 _Color;\nuniform vec4 _LightColor0;\nuniform float _cutOff;\n\n\n\n//LightMap\nuniform sampler2D LightMap;\nuniform sampler2D _MainTexture;\n\n\nuniform vec4 _WorldSpaceLightPos0;\nvoid surf (in Input IN, inout SurfaceOutput o) {\n    vec4 c;\n    c = texture2D (_MainTexture, IN.uv_MainTexture);// * _Color;\n    o.Albedo = c.xyz;\n    o.Alpha = c.a;\n}\n// NOTE: some intricacy in shader compiler on some GLES2.0 platforms (iOS) needs 'viewDir' & 'h'\n// to be mediump instead of lowp, otherwise specular highlight becomes too bright.\nvec4 LightingBlinnPhong (in SurfaceOutput s, in vec3 lightDir, in vec3 viewDir, in float atten) {\n  vec3 h = normalize (lightDir + viewDir);\n  \n  float diff = max (0.0, dot (s.Normal, lightDir));\n  \n  float nh = max (0.0, dot (s.Normal, h));\n  float spec = pow (nh, s.Specular*128.0) * s.Gloss;\n  \n  vec4 c;\n  c.xyz = s.Albedo;//(s.Albedo * _LightColor0.xyz * diff + _LightColor0.xyz * spec) * (atten * 2.0);\n  c.w = s.Alpha;\n  // + _LightColor0.w * spec * atten;\n  //c.xyz = vec3(0.0);\n  return c;\n}\nvec4 frag_surf (in v2f_surf IN) {\n    Input surfIN;\n    SurfaceOutput o;\n    float atten = 1.0;\n    vec4 c;\n    surfIN.uv_MainTexture = IN.hip_pack0.xy;\n    o.Albedo = vec3 (0.0);\n    o.Emission = vec3 (0.0);\n    o.Specular = 0.0;\n    o.Alpha = 0.0;\n    o.Gloss = 0.0;\n    o.Normal = IN.normal;\n    surf (surfIN, o);\n\n    c = LightingBlinnPhong (o, vec3(-0.63,1.0,0.52), vec3(0.11,0.032,0.422), atten);\n    // Lightmap\n    vec4 lightmapValue = texture2D(LightMap, uvLightMap);\n    c.xyz += o.Albedo * IN.vlight * lightmapValue.rgb * (lightmapValue.a * 9.0);\n    //c.xyz = (o.Albedo * IN.vlight);\n    c.w = o.Alpha;\n    return c;\n}\nvoid main() {\n    vec4 xl_retval;\n    v2f_surf xlt_IN;\n    xlt_IN.hip_pack0 = uv_MainTexture;//vec2 (gl_TexCoord[0]);\n    //xlt_IN.normal = vec3 (gl_TexCoord[1]);\n    //xlt_IN.vlight = vec3 (gl_TexCoord[2]);\n    xlt_IN.normal = Normal;\n    xlt_IN.vlight = vec3 (0.8,0.8,0.9);\n    xl_retval = frag_surf (xlt_IN);\n    gl_FragColor = xl_retval;\n    //gl_FragColor = vec4(texture2D (_MainTexture, uv_MainTexture).xyz, 1.0);\n    //gl_FragData[0] = xl_retval;\n}\n"}]}