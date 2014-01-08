part of springbok_db;

abstract class AbstractStore<T extends AbstractStoreInstance>{
  
  Future init(Db db);
  
  T instance(Model$ model$);
  
}

abstract class AbstractStoreInstance<T extends Model> {
  final Model$<T> model$;
  
  AbstractStoreInstance(this.model$);
  
  Map<ClassMirror, ConverterRule> get converterRules;
  
  Future<StoreCursor<T>> cursor([StoreCriteria criteria]);
  Future<int> count([StoreCriteria criteria]);
  Future<List> distinct(field, [StoreCriteria criteria]);
  
  Future<T> findOne([StoreCriteria criteria, fields])
    => cursor(criteria).then((StoreCursor<T> cursor){
    return cursor.next()
        .then((T model){
          cursor.close();
          return model;
        });
  });
  
  
  Future<T> byId(Id id, [fields]) => findOne(idToCriteria(id), fields);
  Future<List<T>> byIds(Iterable<Id> ids, [fields]) => cursor(idsToCriteria(ids))
      .then((StoreCursor cursor){
        cursor.fields = fields;
        return cursor.toList();
      });
  
  Future insert(Map values);
  Future insertAll(List<Map> values);

  Future update(criteria, Map values);
  Future updateOne(criteria, Map values);
  Future updateOneById(Id id, Map values) => updateOne(idToCriteria(id), values);
  
  Future save(Map values);
  
  Future remove(criteria);
  Future removeOne(criteria);
  Future removeOneById(Id id) => removeOne(idToCriteria(id));
  

  T toModel(Map result) => result == null ? null : model$.storeMapToInstance(result);
  
  StoreCriteria newCriteria();
  
  StoreCriteria idToCriteria(Id id) => newCriteria()..fieldEqualsTo('id', id.toString());
  StoreCriteria idsToCriteria(Iterable<Id> ids) => newCriteria()
      ..fieldInValues('id', ids.map((id) => id.toString()).toList(growable: false));
  
  Map instanceToStoreMapResult(Map result) => model$.instanceToStoreMap(result);
}