library harmony.browser;
import 'package:dml/browser.dart' as dml;
import 'package:dml/src/web_io_device.dart';
import 'package:dml/src/web_audio_device.dart';
import 'package:dml/src/webgl_graphics_device.dart';
//import 'package:resources_io/client_handle_indexed.dart';
//import 'package:resources_io/client_handle_webrequest.dart';
import 'package:harmony3d/harmony.dart';
import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
export 'harmony.dart';
import 'package:dml/src/file_load.dart';
import 'package:mist/mist.dart';
part 'src/browser/browser.dart';




Future initHarmonyBrowser(CanvasElement canvas, {ProjectConfig projectConfig, dynamic physics, dynamic physics2d}) {
  //final Completer comp = new Completer();
  if(projectConfig == null) {
    projectConfig = new ProjectConfig();
  }

  final loader = new TempFileLoader();

  final confg = new EngineConfig()
  ..dmlWindow = new dml.DMLBrowserWindow(canvas)
  ..graphicsDevice = new WebGLGraphicsDevice(canvas,loader)
  ..physicsDevice3d = physics
  ..physicsDevice2d = physics2d
  ..audioDevice = new WebAudioDevice(loader)
  ..ioDevice = new WebIoDevice();
  //..localFileHandler = new IndexedDbLocalFileHandler('', '')
  //..webRequestHandler = new WebLoaderDevice('');

  return initHarmony(confg);
}

