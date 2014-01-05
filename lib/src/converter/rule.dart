part of springbok_db;

abstract class ConverterRule<T, U> {
  const ConverterRule();
  
  U encode(Converter converter, ClassMirror variableType, T value);
  
  T decode(Converter converter, ClassMirror variableType, U value);
}


abstract class StringConverterRule<T> extends ConverterRule<T, String>{
  const StringConverterRule();
  
  String encode(Converter converter, ClassMirror variableType, T value) => value.toString();
  
  T decode(Converter converter, ClassMirror variableType, String value);
}
