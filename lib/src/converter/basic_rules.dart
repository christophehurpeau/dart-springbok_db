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
    //print('IdToString : decode $value');
    return new IdString(value.startsWith('#IdString#|>') ? value.substring(12) : value);
  }
  
  String encode(Converter converter, ClassMirror variableType, Id value) {
    //print('IdToString : encode $value');
    return '#IdString#|>$value';
  }
}

class StringToIdConverterRule extends ConverterRule<String, Object> {
  const StringToIdConverterRule();

  Object encode(Converter converter, ClassMirror variableType, String value) {
    //print('StringToId : encode $value');
    return value.startsWith('#IdString#|>') ? 
        converter.convert(reflectClass(Id), new IdString(value.substring(12)))
          : value;
  }

  String decode(Converter converter, ClassMirror variableType, Object value) {
    return value.toString();
  }
}