part of springbok_db;

abstract class Converter<O, S> {
  const Converter();
  S encodeValue(Converters converters, ClassMirror variableType, O value)
    => encode(variableType, value);
  
  O decodeValue(Converters converters, ClassMirror variableType, S value)
    => decode(variableType, value);
  
  
  S encode(ClassMirror variableType, O value);
  
  O decode(ClassMirror variableType, S value);
}

abstract class StringConverter<O> extends Converter<O, String>{
  const StringConverter();
  
  String encode(ClassMirror variableType, O value) => value.toString();
  
  O decode(ClassMirror variableType, String value);// => new T(value);
}

class DateTimeConverter extends Converter<DateTime, int> {
  const DateTimeConverter();

  int encode(ClassMirror variableType, DateTime value) => value.millisecondsSinceEpoch;

  DateTime decode(ClassMirror variableType, int value)
    => new DateTime.fromMillisecondsSinceEpoch(value);
}


class IdConverter extends StringConverter<Id> {
  const IdConverter();

  IdString decode(ClassMirror variableType, String value) => new IdString(value);
}


class Converters {
  final Map<ClassMirror, Converter> converters = {
  };
  
  Converters([Map<ClassMirror, Converter> converters]) {
    if (converters != null) {
      this.converters.addAll(converters);
    }
  }
  
  encode(ClassMirror variableType, Object value) {
    var converter = converters[variableType.originalDeclaration];
    return converter == null ? value : converter.encodeValue(this, variableType, value);
  }

  decode(ClassMirror variableType, value) {
    // originalDeclaration because else we have List<int> and we want List.
    var converter = converters[variableType.originalDeclaration];
    //print('value = $value, variableType = $variableType, converter = $converter');
    return converter == null ? value : converter.decodeValue(this, variableType, value);
  }
}