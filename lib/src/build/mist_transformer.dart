library harmony.mist.transformer;
/*
import 'dart:async' show Future, Completer;
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';

import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';

/*
class ClazzTransformer extends TransformerGroup {
  ClazzTransformer.asPlugin() : this._(new MistTransformer());
  ClazzTransformer._(MistTransformer mt) : super(new Iterable.generate(
      1, (_) => [mt]));
}*/

//final _transformedList = [];
class HarmonyMistTransformer extends Transformer {
  BarbackSettings _settings;
  bool _isDeploy = false;

  HarmonyMistTransformer.asPlugin(BarbackSettings settings) {
    _settings = settings;
    _isDeploy = settings.mode == BarbackMode.RELEASE;
  }
  Resolvers resolvers = new Resolvers(dartSdkDirectory);
  List<AssetId> unmodified = [];

  Map<AssetId, String> contentsPending = {};

  HarmonyMistTransformer();

  String get allowedExtensions => '.dart';

  Future apply(Transform transform) {
    //if(_isDeploy == false) return new Future.value(false);
    final id = transform.primaryInput.id;



    if (unmodified.contains(id)) return new Future.value(false);
    unmodified.add(id);
    return resolvers.get(transform).then((resolver) {
      return new Future(() => applyResolver(transform, resolver)).whenComplete(
          () => resolver.release());
    });

  }

  bool isPart(LibraryElement lib) => lib.unit.directives.any((d) => d is
      PartOfDirective);



  final List _testedLib = [];

  bool applyResolver(Transform transform, Resolver resolver) {
    final libAssetId = transform.primaryInput.id;
    //print('actually addMistCode to: ${libAssetId.path}');
    final currLib = resolver.getLibrary(libAssetId);
    if (isPart(currLib)) return false;


    _testedLib.clear();
    //if(_containsLib(currLib,'mist') == false) return false;

    var mistLib;

    for(var lib in currLib.importedLibraries) {
      if(lib.name == 'mist') {
        mistLib = lib;
        break;
      }
      if(lib.name == 'harmony') {
        mistLib = lib;
        break;
      }

    }
    //final mistLib = resolver.getLibraryByName('mist');
    print('MIST(${this.hashCode}): Transform ${currLib.name}');
    if(mistLib == null) {
    	unmodified.add(libAssetId);
    	return false;
    }


    final List<_Clazz> _reflectClasses = [];
    final libs = currLib.importedLibraries.toList()..add(currLib);
    for(var lib in libs) {
      for(final unit in lib.units) {
        _reflectClasses.addAll(_searcMetadata.accept(unit));
      }
    }
    bool finalValue = false;
    //_addGeneratedCode(currLib,_reflectClasses);
    final lib = currLib;
    final classes = _reflectClasses;

    StringBuffer buffer = new StringBuffer();
    for(_Clazz clazz in classes) {
      ClassElement classElement;
      if(clazz.library != lib && clazz.includeSubclasses == false) {
        continue;
      }



      for (final unit in currLib.units) {
        final String str = _staticClassReflect.accept(unit,clazz.clazz.element,clazz.includeSubclasses);
        buffer.writeln(str);
      }
    }
    {
      final unit = currLib.units.first;
      final AssetId id = libAssetId;
      final transaction = resolver.createTextEditTransaction(unit);
      final end = transaction.original.length;
      transaction.edit( end, end, buffer.toString());
      print('Does this lib has edits? ${transaction.hasEdits}');
      if (transaction.hasEdits) {
        final np = transaction.commit();
        np.build('');
        final newContent = np.text;
        //transform.logger.fine("new content for $id : \n$newContent", asset: id);
        finalValue = true;

        if (id == libAssetId) {
          transform.addOutput(new Asset.fromString(id, newContent));
        } else {
          contentsPending[id] = newContent;
        }
      } else {
        unmodified.add(id);
      }

    }


    print('Mist Transform DONE!');


    //print('Add static mist reflections $finalValue');
    return finalValue;

    //unmodified.addAll(mistGen.unmodified);
    //contentsPending.addAll(mistGen.contentsPending);

  }

  void _addGeneratedCode(LibraryElement lib, List<_Clazz> classes) {

  }
}

final SearchMistInClasses _searcMetadata = new SearchMistInClasses();
final StaticClassReflect _staticClassReflect = new StaticClassReflect();
final Map<String,GeneratedSystemInfo> _compMap = {};

class SearchMistInClasses extends GeneralizingAstVisitor {
  final List<_Clazz> _anotadedClasses = [];
  List<_Clazz> accept(CompilationUnitElement unitElement) {
    _anotadedClasses.clear();
    unitElement.unit.visitChildren(this);
    return _anotadedClasses;

  }

  @override visitClassDeclaration(ClassDeclaration clazz) {
    for(var meta in clazz.metadata) {
      if(meta.element.library.name != 'mist') {
        continue;
      }
      bool includeSubclasses = false;
      if(meta.arguments != null && meta.arguments.length > 0) {
        includeSubclasses = meta.arguments.toSource().contains('true');//.getProperty('includeSubclasses');
      }
      _anotadedClasses.add(new _Clazz(clazz,clazz.element.library,includeSubclasses));
      break;
    }
  }
}


class StaticClassReflect extends GeneralizingAstVisitor {
  StringBuffer transformations;
  ClassElement componentClass;
  bool _includeSubclasses;

  String accept(CompilationUnitElement unitElement, ClassElement componentClass, bool includeSubclasses) {
    _includeSubclasses = includeSubclasses;
    this.componentClass = componentClass;
    transformations = new StringBuffer();
    unitElement.unit.visitChildren(this);
    return transformations.toString();
  }

  @override visitClassDeclaration(ClassDeclaration clazz) {
    super.visitClassDeclaration(clazz);
    if(clazz.element != componentClass) {
      if(clazz.extendsClause == null) return;
      if(_includeSubclasses == false) return;
      if(!clazz.extendsClause.superclass.type.isSubtypeOf(componentClass.type)) {
        return;
      }
    }

    //print('class: ${clazz.name.toString()}');
    //print('Classsource:\n${clazz.toSource()}');
    //print('SuperType: ${clazz.extendsClause.superclass.toSource()}');

    //
    // Generate ComponentSystem
    //
    //transformations.add();

    String className = clazz.name.toString();
    String libName = clazz.element.library.name;

    //if(_compMap.containsKey('${libName}${className}')) return;
    print('generate code for class: $className  lib: $libName');

    final constructor = clazz.getConstructor(className);
    int mainconstructorArgs = 0;
    if(constructor != null) {
    	mainconstructorArgs = constructor.parameters.length;
    }

    //String componentParentClass = clazz.extendsClause.superclass.type.name;

    final List<String> clazzMeta = [];
    for( var meta in clazz.metadata) {
    	clazzMeta.add(meta.toSource().replaceFirst('@', 'const '));
    }

    final List<Method> methods = [];
    final List<Field> fields = [];
    for(var member in clazz.members) {
      if (member is MethodDeclaration) {
        if(member.isStatic) continue;
        if(member.isSetter) continue;
        if(member.isGetter) continue;
        if(member.isOperator) continue;
        String methodName = member.name.toSource();
        final numParams = member.parameters.parameterElements.length;

        final List<String> metadata = [];
        bool ignoreThis = false;
        for( var meta in member.metadata) {
          //print('METADATA: ${meta.name.toString()} ${meta.toSource()}');
          if(meta.element.library.name == 'mist' && meta.toSource().contains('Ignore')) {
            ignoreThis = true;
            break;
          }
          metadata.add(meta.toSource().replaceFirst('@', ''));

        }
        if(ignoreThis == true) continue;

        /*
        for(var param in member.parameters.parameterElements) {
          if(param.metadata.isNotEmpty) {
            // only save the first metavalue for each parameter
            param.metadata.first.
          }
        }*/


        methods.add(new Method(methodName,numParams,metadata));
        continue;
      }
      if(member is FieldDeclaration) {
        if(member.isStatic) continue;
        String fieldName;




        FieldDeclaration fieldDeclaration = member;

        final List<String> metadata = [];

        bool ignoreThis = false;
        for( var meta in member.metadata) {
          //print('METADATA: ${meta.element.library.name} ${meta.toSource()}');
          if(meta.element.library.name == 'mist' && meta.toSource().contains('Ignore')) {
            ignoreThis = true;
            break;
          }
          metadata.add(meta.toSource().replaceFirst('@', 'const '));

        }
        if(ignoreThis == true) continue;

        NodeList<VariableDeclaration> fields_ = fieldDeclaration.fields.variables;

        bool isFinal  = false;
        for (VariableDeclaration field in fields_) {
          SimpleIdentifier fieldName_ = field.name;
          bool ignore = false;
          for(var meta in field.metadata) {
            if(meta.element.library.name == 'mist') {
              print(meta.element.displayName);
              continue;
            }
          }
          isFinal = field.isFinal;
          if (fieldName_ != null) {
            fieldName = fieldName_.toString();
            break;
          }

        }
        if(fieldName == null) continue;
        fields.add(new Field(fieldName,isFinal,null,metadata));
      }

    }


    final creation = new CreationInfo()
    ..mainConstructorPosArguments = mainconstructorArgs
    ..className = className
    ..libName = libName
    ..superClassName = clazz.extendsClause != null ? clazz.extendsClause.superclass.toSource() : 'null'
    ..methods = methods
    ..fields = fields
    ..metaData = clazzMeta;

    final info = _generateComponentSystem(creation);
    //print('Generator: ${info.systemSource}');
    //transformations.add(new Transformation.insertion(clazz.end,info.systemSource));
    transformations.writeln(info.systemSource);
    _compMap['${libName}${className}'] = info;
  }
}

class Transformation {
  final int begin, end;
  final String content;
  Transformation(this.begin, this.end, this.content);
  Transformation.insertion(int index, this.content)
      : begin = index,
        end = index;
  Transformation.deletation(this.begin, this.end) : content = '';
}


GeneratedSystemInfo _generateComponentSystem(CreationInfo creationInfo/*String className, String superClassName, String libName, List<Method> methods,
                               List<Field> fields*/) {
  StringBuffer componentSystem = new StringBuffer();
  final String className = creationInfo.className;
  final String fullClassName = '${creationInfo.libName}.${className}';
  final String generatorName = 'Gen_mist__${className}';
  final String lib = creationInfo.libName;
  final String superclass = creationInfo.superClassName;


  StringBuffer constructorArgs = new StringBuffer();
  for(int i=0; creationInfo.mainConstructorPosArguments<i;i++) {
  	if(constructorArgs.length != 0) {
  		constructorArgs.write(',');
  	}
  	constructorArgs.write('l[$i]');
  }


  //print('generateComponentSystem: $className');
  String fields = _generateFieldInfoList(creationInfo.fields);
  String methods = _generateMethodInfoList(creationInfo.methods);

  String clazzMeta = '[]';
  if(creationInfo.metaData.isNotEmpty) {
    StringBuffer metaInfo = new StringBuffer();
    metaInfo.write('[');
    for(var meta in creationInfo.metaData) {
      metaInfo.write('$meta,');
    }

    String str = metaInfo.toString();
    if(str.length > 1) {
      str = str.substring(0,str.length-1);
    }
    clazzMeta = '$str]';
  }

  var gen = "{'name': '$fullClassName', 'type' : $className, 'constructor' : (List l) => new $className($constructorArgs), 'super' : $superclass, 'meta' : $clazzMeta, 'methods': $methods, 'fields' : $fields}";


  componentSystem.write("final $generatorName = $gen;");//new ComponentSystem('$fullClassName',() => new $className(),$superclass,''');
  //componentSystem.write('${_generateFieldInfoList(creationInfo.fields)},${_generateMethodInfoList(creationInfo.methods)});');

  return new GeneratedSystemInfo(className,fullClassName,generatorName,componentSystem.toString());
}

String _generateFieldInfoList(List<Field> fields) {
  StringBuffer fieldsInfo = new StringBuffer();
  fieldsInfo.write('[');
  for(var field in fields) {
    fieldsInfo.write('$field,');
  }

  String str = fieldsInfo.toString();
  if(str.length > 1) {
    str = str.substring(0,str.length-1);
  }
  return '$str]';

}
String _generateMethodInfoList(List<Method> methods) {
  StringBuffer methodsInfo = new StringBuffer();
  methodsInfo.write('[');
  for(var method in methods) {
    methodsInfo.write('$method,');
  }

  String str = methodsInfo.toString();
  if(str.length > 1) {
    str = str.substring(0,str.length-1);
  }
  return '$str]';
}

/*
String _generateFieldInfoList(List<Field> fields) {
  StringBuffer fieldsInfo = new StringBuffer();
  fieldsInfo.write('[');
  for(var field in fields) {
    fieldsInfo.write('$field,');
  }

  String str = fieldsInfo.toString();
  if(str.length > 1) {
    str = str.substring(0,str.length-1);
  }
  return 'new List.from($str], growable: false)';

}
String _generateMethodInfoList(List<Method> methods) {
  StringBuffer methodsInfo = new StringBuffer();
  methodsInfo.write('[');
  for(var method in methods) {
    methodsInfo.write('$method,');
  }

  String str = methodsInfo.toString();
  if(str.length > 1) {
    str = str.substring(0,str.length-1);
  }
  return 'new List.from($str], growable: false)';
}*/


class GeneratedSystemInfo {
  final String compName;
  final String compFullName;
  final String compVariable;
  //final String compSystemName;
  final String systemSource;
  GeneratedSystemInfo(this.compName,this.compFullName,this.compVariable/*,this.compSystemName*/,this.systemSource){

  }
}

String _writeArguments(String listname, int numArguments) {
  if(numArguments <= 0) return '';
  StringBuffer buffer = new StringBuffer();
  for(int i=0; i < numArguments; i++) {
    buffer.write('$listname[$i],');
  }
  final String strMethod = buffer.toString();
  return strMethod.substring(0,strMethod.length-1);
}







class _Clazz {
  final ClassDeclaration clazz;
  final LibraryElement library;
  final includeSubclasses;
  _Clazz(this.clazz,this.library,this.includeSubclasses);
}

class Method {
  final int numArguments;
  final String name;
  //final FieldCall
  final List metaData;
  Method(this.name,this.numArguments,this.metaData);
  String toString() {
    StringBuffer metaStr = new StringBuffer();
    for(var meta in metaData) {
      metaStr.write('$meta,');
    }
    final str = metaStr.toString();


    return "{'name' : '$name', 'call' : (c,a) => c.$name(${_writeArguments('a',numArguments)}), 'numArgs' : $numArguments, 'meta' : [${str.substring(0,str.length)}]}";
    //return "new Method('$name',$numArguments,(c,a) => c.$name(${_writeArguments('a',numArguments)}),[${str.substring(0,str.length)}])";
  }
}

class Field {
  final String name;
  final datatype;
  final List metaData;
  final isFinal;
  Field(this.name,this.isFinal,this.datatype,this.metaData);
  String toString() {
    StringBuffer metaStr = new StringBuffer();
    for(var meta in metaData) {
      metaStr.write('$meta,');
    }
    final str = metaStr.toString();


    return "{'name' : '$name', 'datatype' : $datatype, 'isFinal' : $isFinal, 'get' : (c) => c.$name , 'set' : (c,v) { c.$name = v;} , 'meta' : [${str.substring(0,str.length)}] }";
    //return "new Field('$name',$datatype,(c) => c.$name,[${str.substring(0,str.length)}])";
  }
}

class CreationInfo {
  String className, superClassName, libName;
  int mainConstructorPosArguments;
  List<String> metaData;
  List<Method> methods;
  List<Field> fields;
}*/
