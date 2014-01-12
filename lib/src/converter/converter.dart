part of springbok_db;

abstract class Converter<T, U> {
  final Map<ClassMirror, ConverterRule<T, U>> rules = {
    reflectClass(List): const IterableConverterRule(),
    reflectClass(Set): const IterableConverterRule(),
    reflectClass(Map): const MapConverterRule(),
  };
  
  final ConverterOutput output;

  final bool allowNull;
  
  Converter(this.output, {Map<ClassMirror, ConverterRule> rules, this.allowNull:false}) {
    if (rules != null) {
      this.rules.addAll(rules);
    }
  }
  
  ConverterRule searchRule(ClassMirror variableType) {
    var model$ = variableType.hasReflectedType ?
        Model$.modelsInfos[variableType.reflectedType]
        : null;
    //print('searchRule: $variableType, ${model$}');
    return rules[model$ != null ? reflectClass(Model) : variableType.originalDeclaration];
  }
  
  U convert(ClassMirror variableType, T value) {
    var rule = searchRule(variableType);
    //print('convert: ${variableType.originalDeclaration}, $rule');
    return rule == null ? value : convertFromRule(rule, variableType, value);
  }

  U convertFromRule(ConverterRule rule, ClassMirror variableType, T value) {
    return output.convert(this, rule, variableType, value);
  }
}


class InstanceToMapConverter extends Converter<Object, dynamic> {
  InstanceToMapConverter({Map<ClassMirror, ConverterRule> rules, bool allowNull:false})
      : super(const EncoderInstanceToMap(), rules: rules, allowNull: allowNull);
}

class MapToInstanceConverter extends Converter<Object, dynamic> {
  MapToInstanceConverter({Map<ClassMirror, ConverterRule> rules, bool allowNull:false})
      : super(const DecoderMapToInstance(), rules: rules, allowNull: allowNull);
}

class _MapToMapConverter extends Converter<dynamic, dynamic> {
  _MapToMapConverter(ConverterOutput output, {Map<ClassMirror, ConverterRule> rules, bool allowNull:false})
    : super(output, rules: rules, allowNull: allowNull);

  ConverterRule searchRule(ClassMirror variableType, [value]) {
    assert(value != null);
    if (value is Model) {
      return rules[reflectClass(Model)];
    } else if (value is Map) {
      return const MapSimpleConverterRule();
    } else if (value is Iterable) {
      return const IterableSimpleConverterRule();
    } else {
      return rules[variableType.originalDeclaration];
    }
    return null;
  }
  
  convert(ClassMirror variableType, value) {
    var rule = searchRule(variableType, value);
    
    //print('convertSimple: ${variableType.originalDeclaration}, $rule');
    if (rule == null) {
      if (value is String || value is num) {
        return value;
      }
      return value.toJson();
    }
    return convertFromRule(rule, variableType, value);
  }
}


class MapToStoreMapConverter extends _MapToMapConverter {
  MapToStoreMapConverter({Map<ClassMirror, ConverterRule> rules, bool allowNull:false})
  : super(const EncoderMapToMap(), rules: rules, allowNull: allowNull);
  
}

class StoreMapToMapConverter extends _MapToMapConverter {
  StoreMapToMapConverter({Map<ClassMirror, ConverterRule> rules, bool allowNull:false})
  : super(const DecoderMapToMap(), rules: rules, allowNull: allowNull);
  
}
