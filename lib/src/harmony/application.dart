part of harmony;


/// Access Runtime data of the Engine
/// and control what scene gets loaded or what Project
class Application {

	/// Loads a harmony3d Project at [url]
	/// CURRENTLY STILL IN DEVELOPMENT
	static loadProject(String url) {
		throw 'not implemented';
	}


	/// Loads a Scene async at [scenepath] and set it as the current Scene as soon as its loaded.
	/// Loads all dependencies before returning the scene or setting it as active.
	/// Returns a future containing the scene.
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

}