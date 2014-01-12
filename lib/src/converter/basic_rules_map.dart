part of springbok_db;

class _MapConverterRules {
  final ClassMirror classKey;
  final ClassMirror classValue;
  final ConverterRule ruleKey;
  final ConverterRule ruleValue;
  
  _MapConverterRules(Converter converter, ClassMirror classKey, ClassMirror classValue)
      : this.classKey = classKey,
        this.classValue = classValue,
      ruleKey = converter.searchRule(classKey),
      ruleValue = converter.searchRule(classValue)
      ;
}

class MapConverterRule implements ConverterRule<Map, Map> {
  const MapConverterRule();
  
  _MapConverterRules findRules(Converter converter, ClassMirror variableType, Map value) {
    List<ClassMirror> args = variableType.typeArguments;
    return new _MapConverterRules(converter, args[0], args[1]);
  }
  
  Map decode(Converter converter, ClassMirror variableType, Map value) {
    if(value.isEmpty) {
      return value;
    }
    
    var rules = findRules(converter, variableType, value);
    var result = {};
    
    value.forEach((k, v){

      if (rules.ruleKey != null && k != null) {
        k = converter.convertFromRule(rules.ruleKey, rules.classKey, k);
      }
      
      if (rules.ruleValue != null && v != null) {
        v = converter.convertFromRule(rules.ruleValue, rules.classValue, v);
      }
      result[k] = v;
    });
    
    return result;
  }

  Map encode(Converter converter, ClassMirror variableType, Map value)
    => decode(converter, variableType, value);
}

class MapSimpleConverterRule extends MapConverterRule {
  const MapSimpleConverterRule();
  
  _MapConverterRules findRules(Converter converter, ClassMirror variableType, Map value) {
    throw new UnsupportedError('This method should not be called');
  }
  
  Map decode(_MapToMapConverter converter, ClassMirror variableType, Map value) {
    if(value.isEmpty) {
      return value;
    }
    //print('MapSimpleConverterRule: $value');
    
    var result = {};
    
    value.forEach((k, v) {
      if (k != null) {
        k = converter.convert(reflectClass(k.runtimeType), k);
      }
      
      if (v != null) {
        v = converter.convert(reflectClass(v.runtimeType), v);
      }
      
      result[k] = v;
    });
    
    return result;
  }
  
}