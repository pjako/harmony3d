import 'dart:io';


void main() {
  //print(FileStat.statSync('glsl_optimizer'));
  /*var process = Process.runSync('/Users/p4jako/dart/harmony3d/tools/assimp2json',
      ['muscle.FBX']);
  print(process.stdout);
  print(process.stderr);*/
  var process = Process.runSync('/Users/p4jako/dart/harmony3d/tools/assimp2json2',
      ['idle.DAE']);
  var f = new File('muscle.preMesh');
  f.writeAsStringSync(process.stdout);
  //print(process.stdout);
  //print(process.stderr);
}