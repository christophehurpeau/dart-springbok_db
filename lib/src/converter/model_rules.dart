part of springbok_db;


class ModelToMapRule implements ConverterRule<Model, Map> {
  const ModelToMapRule();
  
  Model decode(Converter converter, ClassMirror variableType, Map value) {
    if (value == null) return null;
    var model$ = Model$._modelsInfos[variableType.reflectedType];
    return createInstance(model$, value, converter);
  }

  Map encode(Converter converter, ClassMirror variableType, Model value) {
    if (value == null) return null;
    var model$ = Model$._modelsInfos[variableType.reflectedType];
    return instanceToMap(model$, value, converter);
  }

  Model createInstance(Model$ model$, Map value, Converter converter)
    => ModelConverters._mapToInstance(model$, value, converter);
  Map instanceToMap(Model$ model$, Model value, Converter converter)
    => ModelConverters._instanceToMap(model$, value, converter);
}

class ModelToMapStoreRule extends ModelToMapRule {
  const ModelToMapStoreRule();
}
