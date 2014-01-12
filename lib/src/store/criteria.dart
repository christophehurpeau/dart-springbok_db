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
        var firstKey = v.keys.first;
        if (firstKey == r'$in') {
          fieldInValues(k, v[r'$in']);
        } else if (firstKey == r'$or') {
          or(v[r'$or']);
        } else {
          throw new UnsupportedError('Unssupported key $firstKey');
        }
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

  or(Iterable listOfCriteria) {
    assert(criteria[r'$or'] == null);
    criteria[r'$or'] = listOfCriteria.map((c) => c is StoreCriteria ? c.criteria : c);
  }
  
  
  toJson() => criteria;
}