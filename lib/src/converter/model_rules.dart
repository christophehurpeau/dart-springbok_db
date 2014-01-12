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

  Model createInstance(Model$ model$, Map value, Converter converter) {
    return ModelConverters._mapToInstance(model$, value, converter);
  }
  
  Map instanceToMap(Model$ model$, Model value, Converter converter) {
    return ModelConverters._instanceToMap(model$, value, converter);
  }
}

class ModelToMapStoreRule extends ModelToMapRule {
  Converter _converter;
  ModelToMapStoreRule(this._converter);

  Model createInstance(Model$ model$, Map value, Converter converter) {
    return ModelConverters._mapToInstance(model$, value, _converter);
  }
  
  Map instanceToMap(Model$ model$, Model value, Converter converter) {
    return ModelConverters._instanceToMap(model$, value, _converter);
  }
}
