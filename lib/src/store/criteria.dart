part of springbok_db;

abstract class StoreCriteria {
  get criteria;
  set criteria(Map criteria);

  fromMap(Map map) {
    if (map == null || map.isEmpty) {
      return;
    }
    map.forEach((k, v) {
      if (v is Map) {
        assert(v.length == 1);
        fieldInValues(k, v[r'$in']);
      } else {
        fieldEqualsTo(k, v);
      }
    });
  }
  
  
  fieldEqualsTo(String field, value) {
    criteria[field] = value;
  }
  
  fieldInValues(String field, Iterable values) {
    criteria[field] = { r'$in': values };
  }
  
  toJson() => criteria;
}