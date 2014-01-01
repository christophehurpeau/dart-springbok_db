part of springbok_db;

abstract class StoreCursor<T extends Model> {
  final AbstractStoreInstance store;
  
  StoreCursor(this.store);
  

  Map get fields;
  set fields(Map fields);
  
  int get skip;
  set skip(int skip);
  
  int get limit;
  set limit(int limit);
  
  Map get sort;
  set sort(Map sort);
  
  Future<T> next();
  
  Future forEach(callback(T model));

  Future<List<T>> toList();
  
  Future close();
}