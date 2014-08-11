//import 'package:yaml/yaml.dart';
//import 'dart:convert';
import 'package:harmony3d/src/shader_builder.dart';
final source =
'''
name: Diffuse
description: A diffuse shader
properties:
 _MainTexture:
  type: texture2d
  filter: linearClamp
 color:
  type: color
  defautValue: [1.0,1.0,1.0,1.0]
subshader:
 diffuse:
  type: surface

#GLSLShader


#Subshader[diffuse]:Start
uniform sampler2D _MainTexture;
uniform vec4 _Color;

struct Input {
  vec2 uv_MainTexure;
};
void surface (Input IN, inout SurfaceOutput o) {
  vec4 c = texture2D(_MainTex, IN.uv_MainTexture) * _Color;
  o.Albedo = c.xyz;
  o.Alpha = c.w;
}
#Subshader[diffuse]:End
''';


void main() {
	print(new HarmonyShader.fromString(source).buildForward());
}

/*

void main() {
	int sourceStart = source.indexOf('#GLSLShader');
	final yaml = source.substring(0,sourceStart-1);
	final ssource = source.substring(sourceStart);
	YamlMap ymap = loadYaml(yaml);
	ymap.forEach((k,v) {
		print('key: $k, value: $v');
	});
	parseShader(ymap['subshader'],ssource);

	//print(JSON.encode(ymap));
}

class RenderType {
	final _i;
	static const forward = const RenderType(0);
	static const deferred = const RenderType(1);
	const RenderType(this._i);
}
class LightType {
	final _i;
	static const vertex = const RenderType(0);
	static const deffered = const RenderType(1);
	static const forward = const RenderType(1);
	static const defaultLight = forward;
	const LightType(this._i);
}

class Subshader {
	final String name;
	final String source;
	final String type;
	final LightType lightType;
	Subshader(this.name,this.source,this.type,[ LightType this.lightType = LightType.defaultLight]);

	String generateVertexShader(RenderType type) {
		switch(type) {
			case(RenderType.forward):
				return _generateForwardVertexShader();
		}
	}
	String _generateForwardVertexShader() {


	}

	String toString() => 'subshader: $name source: $source';
}

List<Subshader> parseShader(YamlMap shaderInfo, String glslshaders) {
	final l = [];
	shaderInfo.forEach((String name, var value) {
		final startName = '#Subshader[$name]:Start';
		final startIdx = glslshaders.indexOf(startName) + startName.length;
		final endIdx = glslshaders.indexOf('#Subshader[$name]:End');
		final type = value['type'];
		final subshader = new Subshader(name, glslshaders.substring(startIdx,endIdx), type);
		l.add(subshader);
		print(subshader);
	});
	return l;
}
*/