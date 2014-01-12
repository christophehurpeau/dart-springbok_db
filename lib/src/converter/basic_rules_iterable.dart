part of springbok_db;

class IterableConverterRule implements ConverterRule<Iterable, Iterable> {
  const IterableConverterRule();
  
  ClassMirror findArg(ClassMirror variableType, List value) {
    assert(variableType.typeArguments.first != null);
    return variableType.typeArguments.first;
  }
  
  
  Iterable decode(Converter converter, ClassMirror variableType, Iterable value) {
    if (value.isEmpty) {
      return value;
    }
    
    ClassMirror arg = findArg(variableType, value);
    ConverterRule rule = converter.searchRule(arg);
    //print('ListConverterRule: $arg, $rule');
    if (rule == null) {
      return value;
    }
    
    var result = value.map((v) => v == null ? v : converter.convertFromRule(rule, arg, v)).toList();
    //print('ListConverterRule: value = ${value} ; result = ${result}');
    return result;
  }

  // Same thing, the difference between encode and decode is for the value and handled by the converter
  Iterable encode(Converter converter, ClassMirror variableType, Iterable value)
    => decode(converter, variableType, value);
}


class IterableSimpleConverterRule extends IterableConverterRule {
  const IterableSimpleConverterRule();
  

  ClassMirror findArg(ClassMirror variableType, List value) {
    throw new UnsupportedError('This method should not be called');
  }
  
  Iterable decode(_MapToMapConverter converter, ClassMirror variableType, Iterable value) {
    if (value.isEmpty) {
      return value;
    }
    
    //print('ListSimpleConverterRule: value = ${value}');
    var result = value.map((v){
      //print('ListSimpleConverterRule: value: ${v}, ${v.runtimeType}, ${converter.runtimeType}');
      return v == null ? v : converter.convert(reflectClass(v.runtimeType), v);
    }).toList();
    //print('ListSimpleConverterRule: value = ${value} ; result = ${result}');
    return result;
  }
}
