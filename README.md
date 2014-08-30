Harmony3D is a 3d Game Engine inspired by Unity3D and the UnrealEngine.
* Camera culling
* Component based (Manages Lifetime, Allocation and Dealocation of all Components)
* 3D Physics with DulletPhysics
* 2D Physics with Box2D
* 3D Audio
* Works on both server and client (uses Dart Media Library)



## How To Create your own Component

Import harmony
```Dart
import 'packages:harmony3d/harmony.dart';
```

Create your component by extending the component class (only implementing will not work!)
```Dart
class MyComponent extends Component {

}
```

Implement update() to update the component. This gets then called by the Engine in the update loop.
```Dart
class MyComponent extends Component {
  void update() {
    print('DeltaTime: ${Time.deltaTime}');
  }

}
