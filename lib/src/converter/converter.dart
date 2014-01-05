part of springbok_db;

abstract class Converter<T, U> {
  final Map<ClassMirror, ConverterRule<T, U>> rules = {
  };
  
  final ConverterOutput output;

  final bool allowNull;
  
  Converter(this.output, {Map<ClassMirror, ConverterRule> rules, this.allowNull:false}) {
    if (rules != null) {
      this.rules.addAll(rules);
    }
  }
  
  ConverterRule searchRule(ClassMirror variableType) {
    var model$ = Model$.modelsInfos[variableType.reflectedType];
    //print('searchRule: $variableType, ${model$}');
    return rules[model$ != null ? reflectClass(Model) : variableType.originalDeclaration];
  }
  
  U convert(ClassMirror variableType, T value) {
    var rule = searchRule(variableType);
    //print(convert: '${variableType.originalDeclaration}, $rule');
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
