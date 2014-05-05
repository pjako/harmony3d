library game_engine_html;
import 'dart:html';
import 'dart:async';
import 'package:game_loop/game_loop_html.dart';
import 'game_core.dart';
import 'package:resources_io/client_handle_indexed.dart';
import 'package:resources_io/client_handle_webrequest.dart';
import 'package:harmony_devices/audio_device_html.dart';
import 'package:harmony_devices/webgl_render_device.dart';
import 'package:harmony_devices/physics2d_device.dart';
import 'package:harmony_devices/physics3d_device.dart';
export 'game_core.dart';

Future initGameEngine(String projectName, String basePath, CanvasElement canvas, {Physics3DDevice physics3d, Physics2DDevice physics2d}) {
  var gameLoop = new GameLoopHtml(canvas);
  registerAssetHandler(new MeshHandler(), 'mesh');
  registerAssetHandler(new MaterialHandler(), 'mat');
  registerAssetHandler(new ShaderHandler(), 'shader');
  registerAssetHandler(new SceneHandler(), 'scene');
  var texHandler = new HtmlTextureHandler();
  registerAssetHandler(texHandler, 'png');
  registerAssetHandler(texHandler, 'jpg');
  
  //gameLoop.enableFullscreen(true);
  



  return Engine.initEngine(config: null,
      renderDevice: new WebGLRenderDevice(canvas),
      physicsDevice3d: physics3d,
      physicsDevice2d: physics2d,
      audioDevice: new AudioDeviceHtml(),
      timeDevice: new TimeDeviceHtml(gameLoop),
      screenDevice: new ScreenDeviceHtml(gameLoop),
      inputDevice: new InputDeviceHtml(gameLoop),
      localFileHandler: new IndexedDbLocalFileHandler(basePath, projectName),
      webRequestHandler: new WebLoaderDevice(basePath));
}


class HtmlTextureHandler extends TextureHandler {
  List<Texture> _cache = [];


  Asset create() => super.create();

  Asset load(String src, LoaderDevice loader) {
    var texture = create();
    var type = src.substring(src.lastIndexOf('.'));

    loader.loadFileAsBinary(src).then((bin) {
      String mime;
      switch(type) {
        case('png'):
          mime = 'image/png';
        break;
        default:
          mime = 'image/jpeg';
      }

      var url = Url.createObjectUrlFromBlob(new Blob([bin],mime,'native'));
      var img = new ImageElement(src: url);
      img.onLoad.first.then((_) {
        setTextureInitData(texture, img, bin);
        loadingDone(texture);
      });
    });

    return texture;
  }


  bool unload(Asset asset) {
    return super.unload(asset);
  }
  Future save(Asset asset, String src, LoaderDevice loader) {
  }
}

class TimeDeviceHtml extends TimeDevice {
  final GameLoopHtml _loop;
  double get deltaTime => _loop.dt;
  double get realTimeSinceStartup => _loop.time;
  TimeDeviceHtml(this._loop) {
    _loop.onRender = _render;
    _loop.onUpdate = _update;
  }
  void start() {
    _loop.start();
  }
  void stop() {
    _loop.stop();
  }

  void _update(var l) {
    update();

  }
  void _render(var l) {
    render();
  }
}


class ScreenDeviceHtml extends ScreenDevice {
  final GameLoopHtml _loop;
  CanvasElement _canvas;
  ScreenDeviceHtml(GameLoopHtml this._loop) : super() {

    _canvas = _loop.element;
    _loop.onResize = _onResize;
  }
  void _onResize(GameLoop loop) {
    onResize();
  }

  int get width => _canvas.width;
  int get height => _canvas.height;
}




class InputDeviceHtml implements InputDevice {
  final dynamic _loop;
  dynamic _mouse;
  dynamic _keyBoard;
  dynamic _gamepad;
  InputDeviceHtml(this._loop) {
    _mouse = _loop.mouse;
    _keyBoard = _loop.keyboard;
    _gamepad = _loop.gamepad0;
  }

  int get mouseLastFrameUpdate => -1;
  double get mouseLastUpdateTime => 0.0;
  int get mouseX => _mouse.x;
  int get mouseY => _mouse.y;
  int get mouseDx => _mouse.dx;
  int get mouseDy => _mouse.dy;
  int get mouseClampX => _mouse.clampX;
  int get mouseClampY => _mouse.clampY;
  int get wheelDx => _mouse.wheelDx;
  int get wheelDy => _mouse.wheelDy;
  bool get mouseWithinCanvas => _mouse.withinCanvas;

  double get mouseXaxis => mouseDx.toDouble() * 0.0005;
  double get mouseYaxis => mouseDy.toDouble() * 0.0005;

  bool buttonDown(int buttonId) {
    return _mouse.isDown(buttonId);
  }
  bool buttonUp(int buttonId) {
    return _mouse.isUp(buttonId);
  }
  bool buttonPressed(int buttonId) {
    return _mouse.pressed(buttonId);
  }
  bool buttonReleased(int buttonId) {
    return _mouse.released(buttonId);
  }
  double buttonTimePressed(int buttonId) {
    return _mouse.timePressed(buttonId);
  }
  double buttonTimeReleased(int buttonId) {
    return _mouse.timeReleased(buttonId);
  }


  bool keyDown(int keyId) {
    return _keyBoard.isDown(keyId);
  }
  bool keyUp(int keyId) {
    return _keyBoard.isUp(keyId);
  }
  bool keyPressed(int keyId) {
    return _keyBoard.pressed(keyId);
  }
  bool keyReleased(int keyId) {
    return _keyBoard.released(keyId);
  }
  double keyTimePressed(int keyId) {
    return _keyBoard.timePressed(keyId);
  }
  double keyTimeReleased(int keyId) {
    return _keyBoard.timeReleased(keyId);
  }
  
  dynamic getGamePad(int pad) {
    final gamePadList = window.navigator.getGamepads();
    if(gamePadList == null) return null;
    if(gamePadList.isEmpty) return null;
    if(gamePadList.length <= pad) return null;
    return gamePadList[pad];
  }


  bool gamepadDigitalPressed(int buttonId) {
    if(_gamepad.buttons == null) return false;
    return _gamepad.buttons.pressed(buttonId);
  }
  bool gamepadDigitalDown(int buttonId) {
    if(_gamepad.buttons == null) return false;
    return _gamepad.buttons.isDown(buttonId);
  }
  bool gamepadDigitalUp(int buttonId) {
    if(_gamepad.buttons == null) return false;
    return _gamepad.buttons.isUp(buttonId);
  }
  bool gamepadDigitalReleased(int buttonId) {
    if(_gamepad.buttons == null) return false;
    return _gamepad.buttons.released(buttonId);
  }
  double gamepadDigitalTimePressed(int buttonId) {
    if(_gamepad.buttons == null) return 0.0;
    return _gamepad.buttons.timePressed(buttonId);
  }
  double gamepadDigitalTimeReleased(int buttonId) {
    if(_gamepad.buttons == null) return 0.0;
    return _gamepad.buttons.timeReleased(buttonId);
  }

  double gamepadAnalogLastUpdateTime(int buttonId) {
    if(_gamepad.sticks == null) return 0.0;
    return _gamepad.sticks.timeUpdated(buttonId);

  }
  int gamepadAnalogLastUpdateFrame(int buttonId) {
    if(_gamepad.sticks == null) return 0;
    return _gamepad.sticks.frameUpdated(buttonId);
  }
  double gamepadAnalogValue(int buttonId) {
    if(_gamepad.sticks == null) return 0.0;
    return _gamepad.sticks.value(buttonId);
  }
}