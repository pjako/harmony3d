part of harmony;





/// Loads a Scene by a map. All dependecies gets loaded as well.
Future _loadScene(Scene scene, Map map) {
	print('loadScene...');
  final Map<int,dynamic> uniqueObjects = {};
  final List<GameObject> gameObjects = [];
  final List<String> goNames = map['gameObjects']['names'];
  final List<int> goIds = map['gameObjects']['instanceIds'];
  final List<int> goParents = map['gameObjects']['parents'];
  GameObject root;




  // Building GameObjects with temporary Ids
  for(int i=0; i<goNames.length;i++) {
    var go = new GameObject._transformless(goNames[i]);
    var id = goIds[i];
    gameObjects.add(go);
    uniqueObjects[id] = go;

  }
  // set GameObjects parent
  for(int i=0; i<gameObjects.length;i++) {
    var go = gameObjects[i];

    go.static = true;

    var parentId = goParents[i];
    var parent = uniqueObjects[parentId];
    if(parent == null && parentId == -1) {
      // if there is no root creat one
      if(root == null) root = new GameObject('root');
      parent = root;

    }
    parent.addChild(go);
  }


  final Map<String,List> jsonAssets = map['assets'];
  final List<String> assetPath = jsonAssets['paths'];
  final List<int> assetIds = jsonAssets['ids'];
  final int assetCount = assetPath.length;
  final List<Future> waitingFor = new List<Future>();
  for(int i=0; i < assetCount; i++) {
    var asset = Resources.load(assetPath[i]);
    if(!asset.isLoaded) {
      waitingFor.add(asset.notifyOnLoad());
    }
    uniqueObjects[assetIds[i]] = asset;
  }
  Future waitForAssets = Future.wait(waitingFor);

  // Set Lightmaps if present
  if(map.containsKey('lightmaps')) {
  	final List l = map['lightmaps'];
  	final leng = l.length;
  	final lMaps = new List(leng);
  	for(int i=0; i < leng; i++) {
  		lMaps[i] = uniqueObjects[l[i]];
  	}
  	scene._lightmaps = lMaps;
  }


  // Build components.

  final Map<String,Map> components = map['components'];
  final Map<String,List<Component>> objComponents = {};

  components.forEach((String componentName, Map<String,dynamic> data) {
    List<int> owners = data['owners'];
    List<int> ids = data['instanceIds'];
    int count = ids.length;
    List<Component> comps = new  List<Component>.generate(count, (int idx) {
      var comp = (uniqueObjects[owners[idx]] as GameObject)._addComponentByString(componentName);
      uniqueObjects[ids[idx]] = comp;
      return comp;
    }, growable: false);
    objComponents[componentName] = comps;
  });

  components.forEach((String componentName, Map<String,dynamic> data) {
    print(componentName);
    var compList = objComponents[componentName];
    compList.first._system.decode(compList,data,uniqueObjects);
  });





  return waitForAssets.then((onValue) {
    scene._root = root;
    scene._registerGameObject(root, null);
    return null;
  });
}

/*for(int i=0; i < compsCount; i++) {
var compDataList = components[i];
var compList = objComponents[i];
print(compList);
compList.first._system.decodeComponents(compList,compDataList,uniqueObjects);
}*/

/*
  var compsCount = components.length;
  List<List<Component>> objComponents = new List<List<Component>>.generate(compsCount, (int index) {
    var component = components[index];
      //print(component);
      String componentName = component['componentName'];
      List<int> owners = component['owners'];
      List<int> ids = component['instanceIds'];
      int count = ids.length;
      List<Component> comps = new  List<Component>.generate(count, (int idx) {
        var comp = (uniqueObjects[owners[idx]] as GameObject).addComponent(componentName);
        uniqueObjects[ids[idx]] = comp;
        return comp;
      }, growable: false);
      return comps;
  }, growable: false);
*/


/*
for(var component in components) {
  //print(component);
  String componentName = component['componentName'];
  List<int> owners = component['owners'];
  List<int> ids = component['instanceIds'];
  int count = ids.length;

  /*
  List<Component> componentList =
  new List<Component>.generate(count, (int i) => (uniqueObjects[owners[i]] as GameObject).attachComponent(componentName), growable: false);
  ComponentManager.current._systems[componentName].initComponents(componentList);
   */
  switch(componentName) {
    case('Transform'):
      var posBuffer = new Float32List.view( base64decoder.decode(component['positions']) );
    var rotBuffer = new Float32List.view( base64decoder.decode(component['rotations']) );
    for(int i=0; i<count; i++) {
      int p = i * 3;
      int r = i * 4;
      GameObject owner = uniqueObjects[owners[i]] as GameObject;
      Transform transform = owner.transform;

      transform._localPosition.storage[0] = posBuffer[p];
      transform._localPosition.storage[1] = posBuffer[p+1];
      transform._localPosition.storage[2] = posBuffer[p+2];
      //print(transform._localPosition);

      transform._localRotation.storage[0] = rotBuffer[r];
      transform._localRotation.storage[1] = rotBuffer[r+1];
      transform._localRotation.storage[2] = rotBuffer[r+2];
      transform._localRotation.storage[3] = rotBuffer[r+3];
      transform._needsWorldUpdate = true;
      uniqueObjects[ids[i]] = transform;
    }
    break;
    case('MeshRenderer'):
      var boundsBuffer = new Float32List.view( base64decoder.decode(component['bounds']) );
    var lightmapTilingOffsetBuffer = new Float32List.view( base64decoder.decode(component['lightmapTilingOffsets']) );
    var lightmapIndexies = component['lightmapIndexies'];
    List materials = component['materials'];
    var meshes = component['meshes'];
    for(int i=0; i<count; i++) {
      int b = i * 6;
      int l = i * 4;
      GameObject owner = uniqueObjects[owners[i]] as GameObject;

      MeshRenderer meshRenderer = owner.addComponent('MeshRenderer') as MeshRenderer;
      meshRenderer._bounds.min.storage[0] = boundsBuffer[b];
      meshRenderer._bounds.min.storage[1] = boundsBuffer[b+1];
      meshRenderer._bounds.min.storage[2] = boundsBuffer[b+2];
      meshRenderer._bounds.max.storage[0] = boundsBuffer[b+3];
      meshRenderer._bounds.max.storage[1] = boundsBuffer[b+4];
      meshRenderer._bounds.max.storage[2] = boundsBuffer[b+5];
      meshRenderer.mesh = assetMap[meshes[i]];
      meshRenderer.material = assetMap[materials[i]];
      meshRenderer._parameters.lightmapTilingOffset.storage[0] = lightmapTilingOffsetBuffer[l];
      meshRenderer._parameters.lightmapTilingOffset.storage[1] = lightmapTilingOffsetBuffer[l+1];
      meshRenderer._parameters.lightmapTilingOffset.storage[2] = lightmapTilingOffsetBuffer[l+2];
      meshRenderer._parameters.lightmapTilingOffset.storage[3] = lightmapTilingOffsetBuffer[l+3];
      var lightmapId = lightmapIndexies[i];
      var hasLightMaps = lightmapId != -1;
      if(hasLightMaps) {

        meshRenderer._addLightmap(lightMapTex[lightmapId]);
      }
      meshRenderer._parameters.lightmapIndex = lightmapId;
      meshRenderer._parameters.usesLightmaps = hasLightMaps;


      uniqueObjects[ids[i]] = meshRenderer;
      //print(materials[i]);
    }
    break;
    case('Terrain'):
      List<String> terrainDataList = component['terrainData'];
    for(int i=0; i<count; i++) {
      GameObject owner = uniqueObjects[owners[i]] as GameObject;
      TerrainData  data = Resources.load(terrainDataList[i]) as TerrainData;
      Terrain terrain = owner.attachComponent('Terrain') as Terrain;
      terrain.terrainData = data;
    }





  }*/


/**
 * "gameObjects" : {
 *  "id" : [3123123,123123, ... ,123123],
 *  "comps" : [[3123123,23123123],[],[]],
 *  "parent" : []
 * },
 * comps {
 *  "renderer" : {},
 *  "..." : {}
 * }
 *
 */

/**
 * component JSON
 * {
 *  "id":[3123123,123123, ... ,123123],
 *  "strSomething" : ["dasdasds","dasdasd","asdasd", ... , "dasdasdasd"]
 *
 * }
 *
 */



class SceneSerializer {
  static serialize(Scene scene) {
    List<Object> serialize;
    Map<Type,List<Component>> components = {};
    List<GameObject> gameObjects = [];
    Map<Asset,String> assets = {};

    scene._idMap.forEach((int id, GameObject go) {
      gameObjects.add(go);
      for(Component comp in go._components) {
        var l = components[comp.runtimeType];
        if(l == null) {
          l = new List<Component>();
          components[comp.runtimeType] = l;
        }
        l.add(comp);
      }
    });

    Map gos = _gameObjectMap(scene,gameObjects);


    Map<String,Map> componentMap = {};

    components.forEach((Type type, List<Component> cList) {
      var comp = cList.first;
      /*if(comp is Behaviour) {
        return;
      }*/
      if(comp is Transform) {
        var map = {
          'enabled' : <bool>[],
          'locRot' : [],
          'locPos' : [],
          'locScale' : []
        };
        //comp.localPosition;
        //comp.localRotation;
        //comp.localScale;
        componentMap['Transform'] = map;

        return;
      }
    });
  }

  static Map _gameObjectMap(Scene scene, List<GameObject> gameObjects) {
    final List<int> id = [];
    final List<bool> enabled = [];
    final List<List<int>> comps = [];
    final List<int> parent = [];
    for(var go in gameObjects) {
      id.add(go.instanceId);
      enabled.add(go.enabled);
      var l = [];
      for(Component comp in go._components) {
        l.add(comp.instanceId);
      }
      comps.add(l);
      if(go.parent == null) {
        //Root GameObject
        parent.add(-1);
        continue;
      }
      parent.add(go.parent.instanceId);
    }
    var gameObjectMap = {
      'id' : id,
      'enabled' : enabled,
      'components' : comps,
      'parent' : parent,
      'root' : scene.root.instanceId
    };
    return gameObjectMap;
  }



}
