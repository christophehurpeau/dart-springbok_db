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

  IdString decode(Converter converter, ClassMirror variableType, String value)
    => new IdString(value);
}



class ListConverterRule implements ConverterRule<List, List> {
  const ListConverterRule();
  
  ClassMirror _findArg(ClassMirror variableType) {
    assert(variableType.typeArguments.first != null);
    return variableType.typeArguments.first;
  }
  
  List decode(Converter converter, ClassMirror variableType, List value) {
    ClassMirror arg = _findArg(variableType);
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


