library testlib;
import'package:harmony3d/harmony.dart';
import 'package:mist/mist.dart';

class MyComponent extends Component {
  double a = 0.0;
  double f = null;

  void fixedUpdate() {

    print('fixed update ${Time.deltaTime}');
  }

  void update() {
    print(f);
    f = 0.0;
    print('update test ${Time.deltaTime}');
  }
  void lateUpdate() {
    print('late update ${Time.deltaTime}');
    //this.gameObject.destroy();
    //this.destroy();
  }
}