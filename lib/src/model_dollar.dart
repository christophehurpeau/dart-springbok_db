part of springbok_db;

class Model$<T extends Model> {
  static final Map<Type, Model$> _modelsInfos = new Map();
  static final bool isOnClient = _io == null;
  
  static final UnmodifiableMapView<Type, Model$> modelsInfos
    = new UnmodifiableMapView(_modelsInfos);
  
  final Type type;
  final ClassMirror classMirror;
  final Map<String, VariableMirror> variables = new Map();
  
  final List classAnnotations;
  final DbKey dbKey;
  
  ModelConverters<T> _converters;
  
  String storeKey;
  
  Db _db;
  AbstractStoreInstance<T> _store;
  
  // -- Store proxy
  Future<StoreCursor<T>> cursor([criteria]) => _store.cursor(criteria);
  Future<int> count([criteria]) => _store.count(criteria);
  Future<List> distinct(field, [criteria]) => _store.distinct(field, criteria);
  Future<T> findOne([criteria, fields]) => _store.findOne(criteria, fields);
  Future<T> byId(Id id, [fields]) => _store.byId(id, fields);

  Future insert(Map values) => _store.insert(_converters.mapToStoreMap(values));
  Future insertAll(List<Map> values) => _store.insertAll(values.map(_converters.mapToStoreMap));

  Future update(criteria, Map values) => _store.update(criteria, values);
  Future updateOne(criteria, Map values) => _store.updateOne(criteria, values);
  Future updateOneById(Id id, Map values) => _store.updateOneById(id, values);
  
  Future save(Map values) => _store.save(_converters.mapToStoreMap(values));
  
  Future remove(criteria) => _store.remove(criteria);
  Future removeOne(criteria) => _store.removeOne(criteria);
  Future removeOneById(Id id) => _store.removeOneById(id);
  // -- End
  
  Model$(Type type) :
    this._(type, reflectClass(type),
      reflectClass(type).metadata
        .map((InstanceMirror metadata) => metadata.reflectee)
        .toList(growable: false));
  
  Model$._(Type type, ClassMirror classMirror, List classAnnotations):
    this.type = type,
    this.classMirror = classMirror,
    this.classAnnotations = classAnnotations,
    dbKey = classAnnotations
      .firstWhere((annotation) => annotation is DbKey,
      orElse: () => null)
  {
    assert(!_modelsInfos.containsKey(type));
    _modelsInfos[type] = this;
    
    _converters = new ModelConverters(this);
   
    var declarations = classMirror.declarations;
    declarations.forEach((Symbol symbol, DeclarationMirror declaration) {
      if (declaration is VariableMirror && !declaration.isPrivate && !declaration.isStatic) {
        for (InstanceMirror im in declaration.metadata) {
          print(im.reflectee == const ServerSideOnly());
        }
        variables[MirrorSystem.getName(symbol)] = declaration;
        
      }
    });
    
    StoreKey storeKey = classAnnotations
        .firstWhere((annotation) => annotation is StoreKey,
              orElse: () => null);
    if (storeKey == null) {
      this.storeKey = MirrorSystem.getName(classMirror.simpleName);
    } else {
      this.storeKey = storeKey.key;
    }
  }
  
  Future init(){
    if (dbKey == null) {
      return new Future.value();
    }
    if (isOnClient && dbKey is DbServerKey)
      return new Future.value();
    if (!isOnClient && dbKey is DbClientKey)
      return new Future.value();
    return changeDb(dbKey.key);
  }
  
  Future changeDb(String key) {
    _db = new Db(key);
    _store = _db.add(this);
    _converters.updateStore(_store);
    return new Future.value();
  }

  InstanceMirror newInstanceMirror() => classMirror.newInstance(const Symbol(''), []);
  
  T newInstance() => newInstanceMirror().reflectee;
  
  T mapToInstance(Map values) => _converters.mapToInstance(values);

  List<T> listOfMapsToInstances(Iterable<Map<String, dynamic>> listOfValues)
    => _converters.listOfMapsToInstances(listOfValues);
  
  T storeMapToInstance(Map values)  => _converters.storeMapToInstance(values);
  
  List<T> listOfStoreMapsToInstances(Iterable<Map<String, dynamic>> listOfValues)
    => _converters.listOfStoreMapsToInstances(listOfValues);
  
  Map instanceToMap(T instance)
    => _converters.instanceToMap(instance);

  List<Map> listOfInstancesToMaps(Iterable<T> listOfValues)
    => _converters.listOfInstancesToMaps(listOfValues);
  
  Map instanceToStoreMap(T instance)
    => _converters.instanceToStoreMap(instance);
  
  List<Map> listOfInstancesToStoreMaps(Iterable<T> listOfValues)
    => _converters.listOfInstancesToStoreMaps(listOfValues);
 
}
