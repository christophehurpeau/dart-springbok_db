part of springbok_db;

abstract class ConverterOutput<T, U> {
  const ConverterOutput();
  
  U convert(Converter converter, ConverterRule rule, ClassMirror variableType, T value);
}

class EncoderInstanceToMap extends ConverterOutput<Object, dynamic> {
  const EncoderInstanceToMap();
  
  dynamic convert(Converter converter, ConverterRule rule, ClassMirror variableType, Object value) {
    return rule.encode(converter, variableType, value);
  }
}

class DecoderMapToInstance extends ConverterOutput<dynamic, Object> {
  const DecoderMapToInstance();
  
  Object convert(Converter converter, ConverterRule rule, ClassMirror variableType, value) {
    return rule.decode(converter, variableType, value);
  }
}

class EncoderMapToMap extends ConverterOutput<Object, dynamic> {
  const EncoderMapToMap();
  
  dynamic convert(Converter converter, ConverterRule rule, ClassMirror variableType, Object value) {
    return rule.encode(converter, variableType, value);
  }
}

class DecoderMapToMap extends ConverterOutput<Map, Model> {
  const DecoderMapToMap();
  
  Object convert(Converter converter, ConverterRule rule, ClassMirror variableType, value) {
    return rule.decode(converter, variableType, value);
  }
}
