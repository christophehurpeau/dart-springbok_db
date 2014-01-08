part of springbok_db;

abstract class StoreCriteria {
  get _criteria;
  set _criteria(Map criteria);

  fromMap(Map map) {
    if (map == null || map.isEmpty) {
      return;
    }
    map.forEach((k, v) {
      if (v is List) {
        fieldInValues(k, v);
      } else {
        fieldEqualsTo(k, v);
      }
    });
  }
  
  
  fieldEqualsTo(String field, value) {
    _criteria[field] = value;
  }
  
  fieldInValues(String field, Iterable values) {
    _criteria[field] = values;
  }
  
  toJson();
}