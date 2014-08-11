part of harmony;



class Application {
  static Future<Scene> loadScene(String scenepath) {
  	return Resources.loadAsync(scenepath).then((scene) {
  		_setNextScene(scene);
  		return scene;
  	});

  }

  static void _setNextScene(Scene scene) {
  	if(Scene._current != null) {
  		//TODO: unload scene!
  	}
  	Scene._current = scene;
  }



  static void requestFullScreen() {

  }

}