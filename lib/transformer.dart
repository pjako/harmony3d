// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Transfomer used for pub-serve and pub-deploy.
library harmony.transformer;
import 'dart:async' show Future, Completer;

//import 'package:mist/transformer.dart';
//import 'transform_components.dart';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:mist/src/generator/mistgen.dart' as mist;
import 'package:mist/transformer.dart';



final _transformedList = [];

class HarmonyTransformer extends Transformer {
	final MistTransformer _mist = new MistTransformer();

  BarbackSettings _settings;
  bool _isDeploy = false;
  HarmonyTransformer.asPlugin(BarbackSettings settings) {
    _settings = settings;
    _isDeploy = settings.mode.name != BarbackMode.DEBUG.name;
    print(settings.mode.name);
  }
  Resolvers resolvers = new Resolvers(dartSdkDirectory);
  //List<AssetId> unmodified = [];



  //Map<AssetId, String> contentsPending = {};

  HarmonyTransformer(BarbackSettings settings) {
  	_isDeploy = settings.mode.name != BarbackMode.DEBUG.name;
  }

  String get allowedExtensions => '.dart';

  Future apply(Transform transform) {
    //if(_isDeploy == false) return new Future.value(false);



    final id = transform.primaryInput.id;

    /*if (unmodified.contains(id)) return new Future.value(false);
    unmodified.add(id);*/
    /*if (contentsPending.containsKey(id)) {
      transform.addOutput(new Asset.fromString(id, contentsPending.remove(id)));
      return new Future.value(true);
    }*/
    /*
    if(id.package == 'mist' && id.path == 'lib/src/implementation.dart') {
      return transform.primaryInput.readAsString().then((code) {
        // Note: this rewrite is highly-coupled with how implementation.dart is
        // written. Make sure both are updated in sync.
        transform.addOutput(new Asset.fromString(id, code
            .replaceAll("import 'package:mist/mirrors.dart';", "import 'package:mist/static.dart';")));
      });
    }*/

    return resolvers.get(transform).then((resolver) {
      return new Future(() => applyResolver(transform, resolver)).whenComplete(
          () => resolver.release());
    });
  }

  applyResolver(Transform transform, Resolver resolver) {
    final assetId = transform.primaryInput.id;
    final LibraryElement lib = resolver.getLibrary(assetId);
    if (isPart(lib)) return false;
    {
    	_mist.applyResolver(transform, resolver);
    }
    return true;


    if(_transformedList.contains(lib.source.fullName)) {
    	print('already generated for this lib. ${lib.source.fullName}');
    	return false;
    }
    _transformedList.add(lib.source.fullName);
		print('Write reflection for lib: ${lib.source.fullName}');

    final mistGen = new mist.MistGenerator(resolver,transform,true);
    mistGen.transformLib();






    return true;
  }

  bool isPart(LibraryElement lib) => lib.unit.directives.any((d) => d is
      PartOfDirective);
}




//import 'package:observe/transformer.dart';

/*

import 'dart:async';
import 'package:barback/barback.dart';

/// Removes the code-initialization logic based on mirrors.
class MirrorsRemover extends Transformer {
  MirrorsRemover.asPlugin();

  /// Only apply to `lib/polymer.dart`.
  // TODO(nweiz): This should just take an AssetId when barback <0.13.0 support
  // is dropped.
  Future<bool> isPrimary(idOrAsset) {
    var id = idOrAsset is AssetId ? idOrAsset : idOrAsset.id;
    return new Future.value(
        id.package == 'polymer' && id.path == 'lib/polymer.dart');
  }

  Future apply(Transform transform) {
    var id = transform.primaryInput.id;
    return transform.primaryInput.readAsString().then((code) {
      // Note: this rewrite is highly-coupled with how polymer.dart is
      // written. Make sure both are updated in sync.
      var start = code.indexOf('@MirrorsUsed(');
      if (start == -1) _error();
      var end = code.indexOf('show MirrorsUsed;', start);
      if (end == -1) _error();
      end = code.indexOf('\n', end);
      var loaderImport = code.indexOf(
          "import 'package:mist/mirrors.dart';", end);
      if (loaderImport == -1) _error();
      var sb = new StringBuffer()
          ..write(code.substring(0, start))
          ..write(code.substring(end)
              .replaceAll('package:mist/mirrors.dart', 'package:mist/static.dart'));
      print(sb);
      transform.addOutput(new Asset.fromString(id, sb.toString()));
    });
  }
}

/** Transformer phases which should be applied to the smoke package. */
List<List<Transformer>> get phasesForSmoke =>
    [[new MirrorsRemover.asPlugin()]];

_error() => throw new StateError("Couldn't remove imports to mirrors, maybe "
    "polymer.dart was modified, but mirrors_remover.dart wasn't.");*/
/*
import 'package:barback/barback.dart';
//import 'package:observe/transformer.dart';

//import 'src/build/build_filter.dart';
import 'src/build/common.dart';
//import 'src/build/import_inliner.dart';
//import 'src/build/linter.dart';
//import 'src/build/polyfill_injector.dart';
//import 'src/build/script_compactor.dart';
import 'src/build/harmony_transformer.dart';


/// The Polymer transformer, which internally runs several phases that will:
///   * Extract inlined script tags into their separate files
///   * Apply the observable transformer on every Dart script.
///   * Inline imported html files
///   * Combine scripts from multiple files into a single script tag
///   * Inject extra polyfills needed to run on all browsers.
///
/// At the end of these phases, this tranformer produces a single entrypoint
/// HTML file with a single Dart script that can later be compiled with dart2js.
class HarmonyTransformerGroup implements TransformerGroup {
  final Iterable<Iterable> phases;

  HarmonyTransformerGroup(TransformOptions options)
      : phases = createDeployPhases(options) {
  	print('apply Harmony3d Transformer');
  }

  HarmonyTransformerGroup.asPlugin(BarbackSettings settings)
      : this(_parseSettings(settings));
}

TransformOptions _parseSettings(BarbackSettings settings) {
  var args = settings.configuration;
  bool releaseMode = settings.mode == BarbackMode.RELEASE;
  bool jsOption = args['js'];
  bool csp = args['csp'] == true; // defaults to false
  return new TransformOptions(
      entryPoints: _readEntrypoints(args['entry_points']),
      directlyIncludeJS: jsOption == null ? releaseMode : jsOption,
      contentSecurityPolicy: csp,
      releaseMode: releaseMode);
}

_readEntrypoints(value) {
  if (value == null) return null;
  var entryPoints = [];
  bool error;
  if (value is List) {
    entryPoints = value;
    error = value.any((e) => e is! String);
  } else if (value is String) {
    entryPoints = [value];
    error = false;
  } else {
    error = true;
  }
  if (error) {
    print('Invalid value for "entry_points" in the polymer transformer.');
  }
  return entryPoints;
}

/// Create deploy phases for Polymer. Note that inlining HTML Imports
/// comes first (other than linter, if [options.linter] is enabled), which
/// allows the rest of the HTML-processing phases to operate only on HTML that
/// is actually imported.
List<List<Transformer>> createDeployPhases(
    TransformOptions options, {String sdkDir}) {
  var phases = [];//= options.lint ? [[new Linter(options)]] : [];
  return phases..addAll([
    [new HarmonyTransformer(options)],
    /*[new MistTransformer()]

    [new ImportInliner(options)],
    [new ObservableTransformer()],
    [new ScriptCompactor(options, sdkDir: sdkDir)],
    [new PolyfillInjector(options)],
    [new BuildFilter(options)]*/
  ]);
}*/
