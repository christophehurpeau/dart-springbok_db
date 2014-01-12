library springbok_db;

import 'dart:async';
@MirrorsUsed(targets: 'dart.dom.html.window, '
    'dart.io.Platform.operatingSystem')
import 'dart:mirrors';
import 'package:unmodifiable_collection/unmodifiable_collection.dart';

part 'src/meta.dart';
part 'src/id.dart';
part 'src/model.dart';
part 'src/model_dollar.dart';
part 'src/converter/converter.dart';
part 'src/converter/output.dart';
part 'src/converter/rule.dart';
part 'src/converter/basic_rules.dart';
part 'src/converter/basic_rules_iterable.dart';
part 'src/converter/basic_rules_map.dart';
part 'src/converter/model_rules.dart';
part 'src/converter/model_converters.dart';
part 'src/store/store.dart';
part 'src/store/cursor.dart';
part 'src/store/criteria.dart';



/// If `dart:io` is not available, this returns null.
LibraryMirror get _io => currentMirrorSystem().libraries[Uri.parse('dart:io')];

/// If `dart:html` is not available, this returns null.
LibraryMirror get _html =>
  currentMirrorSystem().libraries[Uri.parse('dart:html')];

typedef AbstractStore StoreCreator(Map config);

class Db<T extends AbstractStoreInstance>{
  static final Map<String, Map> _dbConfigs = {};
  static final Map<String, Db> dbs = {};
  static final Map<String, StoreCreator> stringToStore = {};

  static Future initConfig(Map dbConfigs){
    _dbConfigs.addAll(dbConfigs);
    return new Future.value();
  }

  static void forEach(void callback(String dbName, Db db)) => dbs.forEach(callback);

  
  final String dbName;
  final Map _config;
  final AbstractStore<T> store;
  final Map<Model$, T> models$ = {};
  

  factory Db([String dbName = 'default']){
    if(dbName == null) dbName = 'default';
    
    if (dbs.containsKey(dbName)) {
      return dbs[dbName];
    }
    var config = _dbConfigs[dbName];
    assert(config != null && config['store'] != null);
    assert(stringToStore[config['store']] != null);
    return new Db._(dbName, config);
  }
  
  Db._(this.dbName, Map config):
    _config = config,
    store = stringToStore[config['store']](config) {
    store.init(this); //TODO this is a future, but I don't know how and when I should call it...
    //Models are lazy-loaded, so when we are here we already need it...
  }
  
  T add(Model$ model$){
    return models$.putIfAbsent(model$, () => store.instance(model$));
  }
  
}