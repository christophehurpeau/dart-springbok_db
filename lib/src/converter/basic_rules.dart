part of springbok_db;

class DateTimeToIntRule extends ConverterRule<DateTime, int> {
  const DateTimeToIntRule();

  int encode(Converter converter, ClassMirror variableType, DateTime value)
    => value.millisecondsSinceEpoch;

  DateTime decode(Converter converter, ClassMirror variableType, int value)
    => new DateTime.fromMillisecondsSinceEpoch(value);
}

class IdToStringRule extends StringConverterRule<Id> {
  const IdToStringRule();

  IdString decode(Converter converter, ClassMirror variableType, String value) {
    return new IdString(value.startsWith('#IdString#|>') ? value.substring(12) : value);
  }
  
  String encode(Converter converter, ClassMirror variableType, Id value) {
    return '#IdString#|>$value';
  }
}

class StringToIdConverterRule extends ConverterRule<String, Object> {
  const StringToIdConverterRule();

  Object encode(Converter converter, ClassMirror variableType, String value) {
    print('StringToId : encode $value');
    return value.startsWith('#IdString#|>') ? 
        converter.convert(reflectClass(Id), new IdString(value.substring(12)))
          : value;
  }

  String decode(Converter converter, ClassMirror variableType, Object value) {
    return value.toString();
  }
}

class ListConverterRule implements ConverterRule<List, List> {
  const ListConverterRule();
  
  ClassMirror findArg(ClassMirror variableType, List value) {
    assert(variableType.typeArguments.first != null);
    return variableType.typeArguments.first;
  }
  
  List decode(Converter converter, ClassMirror variableType, List value) {
    ClassMirror arg = findArg(variableType, value);
    ConverterRule rule = converter.searchRule(arg);
    //print('ListConverterRule: $arg, $rule');
    if (rule == null) {
      return value;
    }
    
    return value.map((v) => v == null ? v : converter.convertFromRule(rule, arg, v)).toList();
  }

  // Same thing, the difference between encode and decode is for the value and handled by the converter
  List encode(Converter converter, ClassMirror variableType, List value)
    => decode(converter, variableType, value);
}

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

class ListSimpleConverterRule extends ListConverterRule {
  const ListSimpleConverterRule();
  

  ClassMirror findArg(ClassMirror variableType, List value) {
    if (value.isEmpty) {
      return null;
    }
    
    return reflectClass(value.firstWhere((e) => e != null).runtimeType);
  }
  
}


class MapSimpleConverterRule extends MapConverterRule {
  const MapSimpleConverterRule();
  
  _MapConverterRules findRules(Converter converter, ClassMirror variableType, Map value) {
    if (value.isEmpty) {
      return null;
    }

    var firstKey = value.keys.first;
    var firstValue = value.values.first;
    
    return new _MapConverterRules(converter, 
        reflectClass(firstKey.runtimeType), 
        reflectClass(firstValue.runtimeType));
  }
}