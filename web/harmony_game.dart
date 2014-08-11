import 'package:harmony3d/browser.dart';
import 'package:harmony3d/harmony.dart';
import 'dart:html';
import 'dart:async';
import 'package:harmony3d/testlib.dart';
//import 'package:mist/mist.dart';

/*
class MyComponent extends Component {

}
*/



void main() {
	print('start!');

  window.screen.lockOrientation("landscape-primary");
  final canvas = querySelector('#front_buffer');
  assert(canvas != null);
  initHarmonyBrowser(canvas).then(engineReady);


}



void engineReady(_) {
	Application.loadScene('assets/L_FG_assets_Pack_Lite/Demo/Demo6.scene');
  {
    final go = new GameObject();
    print(go.addComponent(MyComponent));
    Scene.current.root.addChild(go);
  }
  new Timer(new Duration(seconds: 1), () {
    final go = new GameObject();
    go.addComponent(Camera);
    print(go.addComponent(MyComponent));
    Scene.current.root.addChild(go);
    //print('done');
  });
}