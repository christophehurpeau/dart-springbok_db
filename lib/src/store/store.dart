part of springbok_db;

abstract class AbstractStore<T extends AbstractStoreInstance>{
  
  Future init(Db db);
  
  T instance(Model$ model$);
  
}

abstract class AbstractStoreInstance<T extends Model> {
  final Model$<T> model$;
  
  AbstractStoreInstance(this.model$);
  
  Converters get converter;
  
  Future<StoreCursor<T>> cursor([criteria]);
  Future<int> count([criteria]);
  Future<List> distinct(field, [criteria]);
  
  Future<T> findOne([criteria, fields])
    => cursor(criteria).then((StoreCursor<T> cursor){
    return cursor.next()
        .then((T model){
          cursor.close();
          return model;
        });
  });
  
  
  Future<T> byId(Id id, [fields]) => findOne(idToCriteria(id), fields);
  
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
  
  Map idToCriteria(Id id) => { 'id': id.toString() };
  Map instanceToStoreMapResult(Map result) => result;
}