part of springbok_db;

class Model$<T extends Model> {
  static final Converters _converter = new Converters({
    reflectClass(DateTime): const DateTimeConverter(),
    reflectClass(Id): const IdConverter(),
    reflectClass(Model): const ModelConverter(),
    reflectClass(List): const ListConverter(),
  });
  static final Map<Type, Model$> _modelsInfos = new Map();
  static final bool isOnClient = _io == null;
  
  static Map<Type, Model$> get modelsInfos => _modelsInfos;
  
  final Type type;
  final ClassMirror classMirror;
  final Map<String, VariableMirror> variables = new Map();
  
  final List classAnnotations;
  final DbKey dbKey;
  
  String storeKey;
  
  Db _db;
  AbstractStoreInstance<T> _store;
  
  // -- Store proxy
  Future<StoreCursor<T>> cursor([criteria]) => _store.cursor(criteria);
  Future<int> count([criteria]) => _store.count(criteria);
  Future<List> distinct(field, [criteria]) => _store.distinct(field, criteria);
  Future<T> findOne([criteria, fields]) => _store.findOne(criteria, fields);
  Future<T> byId(Id id, [fields]) => _store.byId(id, fields);

  Future insert(Map values) => _store.insert(values);
  Future insertAll(List<Map> values) => _store.insertAll(values);

  Future update(criteria, Map values) => _store.update(criteria, values);
  Future updateOne(criteria, Map values) => _store.updateOne(criteria, values);
  Future updateOneById(Id id, Map values) => _store.updateOneById(id, values);
  
  Future save(Map values) => _store.save(values);
  
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
    return new Future.value();
  }
  
  T createInstance(Map<String, dynamic> values, [Converters converters]) {
    if (converters == null) converters = _converter;
    var instance = classMirror.newInstance(const Symbol(''), []);
    values.forEach((String fieldName, value) {
      var variable = variables[fieldName];
      if (variable == null) {
        //throw new Exception('Unexpected key $fieldName');
        return;
      }
      
      if (value != null) {
        ClassMirror variableType = variable.type;
        value = converters.decode(variableType, value);
      }

      instance.setField(variable.simpleName, value);
    });
    return instance.reflectee;
  }
  
  List<T> createListOfInstances(Iterable<Map<String, dynamic>> listOfValues, [Converters converters]) {
    return listOfValues.map((m) => createInstance(m, converters)).toList();
  }
  
  Map instanceToMap(T object, [Converters converters]) {
    if (converters == null) converters = _converter;
    assert(object != null);
    InstanceMirror mirror = reflect(object);
    
    Map result = {};
    variables.forEach((String fieldName, VariableMirror variable) {
      Object value = mirror.getField(variable.simpleName).reflectee;
      
      if (value != null) {
        ClassMirror variableType = variable.type;
        value = converters.encode(variableType, value);
        if (value != null) {
          result[fieldName] = value;
        }
      }
    });
    return result;
  }
  
  List<Map> createListFromInstances(Iterable<T> listOfValues, [Converters converters]) {
    return listOfValues.map((m) => instanceToMap(m, converters)).toList();
  }
  
  
  T storeMapToInstance(Map <String, dynamic> values, [Converters converters]) {
    if (converters == null) converters = _store.converter;
    var instance = classMirror.newInstance(const Symbol(''), []);
    values.forEach((String fieldName, value) {
      var variable = variables[fieldName];
      if (variable == null) {
        throw new Exception('Unexpected key $fieldName');
      }
      
      if (value != null) {
        ClassMirror variableType = variable.type;
        value = converters.decode(variableType, value);
      }

      instance.setField(variable.simpleName, value);
    });
    return instance.reflectee;
  }
  
  List<T> createListOfInstancesFromStore(Iterable<Map<String, dynamic>> listOfValues, [Converters converters]) {
    return listOfValues.map((v) => storeMapToInstance(v, converters)).toList();
  }
  
  // Same, but set null values too
  Map instanceToStoreMap(T object, [Converters converters]) {
    if (converters == null) converters = _store.converter;
    assert(object != null);
    InstanceMirror mirror = reflect(object);
    
    Map result = {};
    variables.forEach((String fieldName, VariableMirror variable) {
      Object value = mirror.getField(variable.simpleName).reflectee;
      
      if (value != null) {
        ClassMirror variableType = variable.type;
        value = converters.encode(variableType, value);
      }
      
      result[fieldName] = value;
    });
    return _store == null ? result : _store.instanceToStoreMapResult(result);
  }
  
  List<Map> createListFromInstancesToStore(Iterable<T> listOfValues, [Converters converters]) {
    return listOfValues.map((m) => instanceToStoreMap(m, converters)).toList();
  }
  
}
