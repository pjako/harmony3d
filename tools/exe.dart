import 'dart:io';


void main() {
  //print(FileStat.statSync('glsl_optimizer'));
  var process = Process.runSync('/Users/p4jako/dart/harmony3d/tools/glsl_optimizer',
      ['--vertex','--opengl-es','test.vs']);
  print(process.stdout);
  print(process.stderr);
}