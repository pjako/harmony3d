/**
 *      ** Shader Builder **
 * Builds GLSL Shader out of harmony shader
 * which is a constraint superset of glsl
 *
 *
 */

library shader_builder;
import 'package:yaml/yaml.dart';


class ShaderType {
	final int index;
	final String name;


	static const ShaderType surface = const ShaderType(0,'surface');

	const ShaderType(this.index, this.name);

	static final list = [surface];
	static parse(String shaderType) {
		for(var val in list) {
			if(val.name == shaderType ) {
				return val;
			}
		}
		throw 'no such shader type "$shaderType"';
		return null;
	}
}

class RenderType {
	final _i;
	static const forward = const RenderType(0);
	static const deferred = const RenderType(1);
	const RenderType(this._i);
}
class LightType {
	final _i;
	static const vertex = const LightType(0);
	static const deffered = const LightType(1);
	static const forward = const LightType(2);
	static const custom = const LightType(3);
	static const none = const LightType(4);
	static const defaultLight = forward;
	const LightType(this._i);
}

class FilterType {
	final int index;
	final String name;
// anisotropicClamp/anisotropicWrap/linearClamp/linearWrap/pointClamp/pointWrap
	static const anisotropicClamp = const FilterType(0,'anisotropicClamp');
	static const anisotropicWrap = const FilterType(1,'anisotropicWrap');
	static const linearClamp = const FilterType(2,'linearClamp');
	static const linearWrap = const FilterType(3,'linearWrap');
	static const pointClamp = const FilterType(4,'pointClamp');
	static const pointWrap = const FilterType(5,'pointWrap');
	const FilterType(this.index,this.name);

	static final list = [anisotropicClamp,anisotropicWrap,linearClamp,linearWrap,pointClamp,pointWrap];
	static FilterType parse(String filterType) {
		for(var val in list) {
			if(val.name == filterType ) {
				return val;
			}
		}
		throw 'no such Property type "$filterType"';
		return null;
	}
}

class UniformType {

}

class PropertyType {
	final int index;
	final String name;

	static const color = const PropertyType(0,'color');
	static const texture2d = const PropertyType(1,'texture2d');

	const PropertyType(this.index,this.name);

	static final list = [color,texture2d];
	static parse(String propertyType) {
		for(var val in list) {
			if(val.name == propertyType ) {
				return val;
			}
		}
		throw 'no such Property type "$propertyType"';
		return null;
	}

}


class TextureProperty {
	final String name;
	final FilterType filterType;
	final defautValue;
	TextureProperty(this.name,this.filterType,this.defautValue);
}

class UniformProperty {
	final String name;
	final UniformType type;
	final defautValue;
	UniformProperty(this.name,this.type, this.defautValue);
}



class HarmonyShader {
	ShaderType type;
	HarmonyShader();
	final List<TextureProperty> _textures = [];
	final List<Subshader> _subShader = [];

	HarmonyShader.fromString(String source) {
		int sourceStart = source.indexOf('#GLSLShader');
		if(sourceStart == -1) {
			throw 'Parse error, GLSL Shader is missing, "#GLSLShader" was not found';
		}
  	final yaml = source.substring(0,sourceStart-1);
  	final ssource = source.substring(sourceStart);
  	YamlMap ymap = loadYaml(yaml);
  	ymap.forEach((k,v) {
  		print('key: $k, value: $v');
  	});
  	if(ymap.containsKey('properties')) {
  		ymap['properties'].forEach(_parseProperties);
  	}

  	_parseShader(ymap['subshader'],ssource);
	}

	void _parseProperties(String name, YamlMap map) {
		print(name);
		final propType = PropertyType.parse(map['type']);
		switch(propType) {
			case(PropertyType.texture2d):
				_textures.add(new TextureProperty(name,FilterType.parse(map['filter']),map['defaultValue']));
			break;
		}

	}

	void _parseShader(YamlMap shaderInfo, String glslshaders) {
  	shaderInfo.forEach((String name, var value) {
  		final startName = '#Subshader[$name]:Start';
  		final startIdx = glslshaders.indexOf(startName) + startName.length;
  		assert(startIdx != -1+startName.length);
  		final endIdx = glslshaders.indexOf('#Subshader[$name]:End');
  		assert(endIdx != -1);
  		final type = ShaderType.parse(value['type']);
  		assert(type != null);
  		final subshader = new Subshader(this,name, glslshaders.substring(startIdx,endIdx), type);
  		_subShader.add(subshader);
  	});
  }

	bool get canBeDeffered => type == ShaderType.surface;

	Map buildDefered() {

	}

	Map buildForward() {
		for(var s in _subShader) {
			s.generateVertexShader(RenderType.forward);
		}

	}

}



/*
 * float3 viewDir
 * float4 with COLOR semantic - will contain interpolated per-vertex color.
 * float4 screenPos - will contain screen space position for reflection effects. Used by WetStreet shader in Dark Unity for example.
 * float3 worldPos - will contain world space position.
 * float3 worldRefl - will contain world reflection vector if surface shader does not write to o.Normal. See Reflect-Diffuse shader for example.
 * float3 worldNormal - will contain world normal vector if surface shader does not write to o.Normal.
 *
  */
class SurfaceShaderInputs {
	static const _inputForm = 'struct Input {';
	String _input;

	bool get containsViewDir => _input.contains('vec3 viewDir');
	bool get containsColor => _input.contains('vec4 color');
	bool get containsScreenPos => _input.contains('vec4 screenPos');
	bool get containsWorldPos => _input.contains('vec3 worldPos');
	bool get containsWorldRefl => _input.contains('vec3 worldRefl');
	bool get containsWorldNormal => _input.contains('vec3 worldNormal');

	SurfaceShaderInputs(String source) {
		if(!source.contains(_inputForm)) return;
		final start = source.indexOf(_inputForm);
		final end = source.indexOf(_close);
		_input = source.substring(start, end);
	}

	bool containsUvFor(String texture) {
		return _input.contains('uv$texture');
	}


}


/*struct SurfaceOutput {
    vec3 Albedo;
    vec3 Normal;
    vec3 Emission;
    float Specular;
    float Gloss;
    float Alpha;
};*/

class Subshader {
	HarmonyShader _masterShader;
	final String name;
	final String source;
	final ShaderType type;
	SurfaceShaderInputs _surfaceInput;
	final LightType lightType;
	final bool isHp = true;
	Subshader(this._masterShader,this.name,this.source,this.type,[ LightType this.lightType = LightType.defaultLight]) {
		if(type == ShaderType.surface) {
			_surfaceInput = new SurfaceShaderInputs(source);
			//test if specific types are used.
		}
	}

	String generateVertexShader(RenderType type) {
		switch(type) {
			case(RenderType.forward):
				return _generateForwardFragmentShader(true,false,80);
		}
	}
	String _generateForwardFragmentShader(bool lightmap, bool skinned, int boneCount) {


	  StringBuffer buffer = new StringBuffer();
    if(isHp) buffer.write('precision highp float;\n');



    for(var tex in _masterShader._textures) {
    	print('texture: ${tex.name}');
    	if(_surfaceInput.containsUvFor(tex.name)) {
    		buffer.writeln(_varTex0);
    		break;
    	}

    }


    // Write Attributes
    //buffer.write(_attPos);
    //buffer.write(_attNormal);
    //buffer.write(_attTangent);
    //buffer.write(_attTex0);

    // Texture coordinates for the Lightmap
    if(lightmap) {
    	buffer.write(_varTex1);
    }

    if(skinned) {
	    buffer.write(_attWeights);
	    buffer.write(_attBones);
    }

    buffer.write('\n');

    // Write Uniforms
    if(skinned) {
	    buffer.write(_MATRIX_MV);
	    buffer.write(_MATRIX_P);
	    buffer.write(_BONE_MATRICES(boneCount));
    } else {
    	buffer.write(_MATRIX_MVP);
    }


    // Shader specific code
    buffer.writeln(source);



    // Surface output
    buffer.writeln(_SurfaceOutputStart);
    buffer.writeln(_SoAlbedo);
    buffer.writeln(_SoNormal);
    buffer.writeln(_SoEmission);
    buffer.writeln(_SoSpecular);
    buffer.writeln(_SoGloss);
    buffer.writeln(_SoAlpha);
    buffer.writeln(_close);


    buffer.writeln(_blinPhongLight);



    // Main
    buffer.write(_mainStart);
    buffer.writeln(' SurfaceOutput o;');
    buffer.writeln(' o.Alpha = 1.0;');
    buffer.writeln(' Input in;');
    for(var tex in _masterShader._textures) {
    	print('texture: ${tex.name}');
    	if(_surfaceInput.containsUvFor(tex.name)) {
    		buffer.writeln(' in.uv${tex.name} = h_texcoord0;');
    	}

    }
    buffer.writeln(' surface(in,o);');//LightingBlinnPhong


    buffer.writeln(' atten = 1.0;');
    if(lightmap) {

    }
    buffer.writeln(' gl_FragColor = LightingBlinnPhong(o,h_lightDir,h_viewDir,atten,vec4(0.0));');


    //buffer.writeln(' gl_FragColor = vec4(o.Albedo,o.Apha);');




    //buffer.writeln(' Input input;');
    if(_surfaceInput.containsColor) {

    }
    if(_surfaceInput.containsScreenPos) {

    }
    if(_surfaceInput.containsViewDir) {

    }
    if(_surfaceInput.containsWorldNormal) {

    }
    if(_surfaceInput.containsWorldPos) {

    }
    if(_surfaceInput.containsWorldRefl) {

    }



    buffer.write(_close);

    print('vertexShader:\n${buffer}');
	}
	String _generateForwardVertexShader(bool skinned, bool tex1, int boneCount) {
		final buffer = new StringBuffer();


	}

	String toString() => 'subshader: $name source: $source';
}




const _SurfaceOutputStart = 'struct SurfaceOutput {';
const _SoAlbedo = ' vec3 Albedo;';
const _SoNormal = ' vec3 Normal;';
const _SoEmission = ' vec3 Emission;';
const _SoSpecular = ' float Specular;';
const _SoGloss = ' float Gloss;';
const _SoAlpha = ' float Alpha;';

const _mainStart = 'void main() {\n';
const _close = '}\n';
const _precHp = 'precision highp float;\n';

const _attPos = 'attribute vec3 POSITION;\n';
const _attNormal = 'attribute vec3 NORMAL;\n';
const _attTangent = 'attribute vec3 TANGENT;\n';
const _attTex0 = 'attribute vec2 TEXCOORD0;\n';
const _attTex1 = 'attribute vec2 TEXCOORD1;\n';
const _attWeights = 'attribute vec3 WEIGHTS;\n';
const _attBones = 'attribute vec3 BONES;\n';
const _varPos = 'varying vec3 h_pos';
const _varNormal = 'varying vec3 h_normal';
const _varTangent = 'varying vec3 h_tangent';
const _varTex0 = 'varying vec3 h_texcoord0';
const _varTex1 = 'varying vec3 h_texcoord1';
const _varScreenPos = 'varying vec3 h_screenpos';

const _MATRIX_MVP = 'uniform mat4 MATRIX_MVP';
const _MATRIX_M = 'uniform mat4 MATRIX_M';
const _MATRIX_MV = 'uniform mat4 MATRIX_MV';
const _MATRIX_P = 'uniform mat4 MATRIX_P';

const _blinPhongLight =
'''
vec4 LightingBlinnPhong( in SurfaceOutput s, in vec3 lightDir, in vec3 viewDir, in float atten, in vec4 specColor ) {
 vec3 h;
 float diff;
 float nh;
 float spec;
 vec4 c;
 h = normalize( (lightDir + viewDir) );
 diff = max( 0.000000, dot( s.Normal, lightDir));
 nh = max( 0.000000, dot( s.Normal, h));
 spec = (pow( nh, (s.Specular * 128.000)) * s.Gloss);
 c.xyz  = ((((s.Albedo * _LightColor0.xyz ) * diff) + ((_LightColor0.xyz  * specColor.xyz ) * spec)) * (atten * 2.00000));
 c.w  = (s.Alpha + (((_LightColor0.w  * specColor.w ) * spec) * atten));
 return c;
}
''';

const _lightMap =
'''
    // Lightmap
    vec4 lightmapValue = texture2D(LightMap, uvLightMap);
    c.xyz += o.Albedo * IN.vlight * lightmapValue.rgb * (lightmapValue.a * 9.0);
    //c.xyz = (o.Albedo * IN.vlight);
    c.w = 1.0;//o.Alpha;
''';


String _BONE_MATRICES(int count) => 'uniform mat4 BONE_MATRICES[$count];\n';



