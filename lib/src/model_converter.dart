part of springbok_db;


class ModelConverter implements Converter<Model, Map> {
  const ModelConverter();
  
  Model decodeValue(Converters converters, ClassMirror variableType, Map value) {
    if (value == null) return null;
    var model$ = Model$._modelsInfos[variableType.reflectedType];
    return createInstance(model$, value, converters);
  }

  Map encodeValue(Converters converters, ClassMirror variableType, Model value) {
    if (value == null) return null;
    var model$ = Model$._modelsInfos[variableType.reflectedType];
    return instanceToMap(model$, value, converters);
  }

  Model createInstance(Model$ model$, Map value, converters) => model$.createInstance(value, converters);
  Map instanceToMap(Model$ model$, Model value, converters) => model$.instanceToMap(value, converters);

  Model decode(ClassMirror variableType, Map value) => null;
  Map encode(ClassMirror variableType, Model value) => null;
}

class ModelStoreConverter extends ModelConverter  {
  const ModelStoreConverter();
  
  Model createInstance(Model$ model$, Map value, converters) => model$.storeMapToInstance(value, converters);
  Map instanceToMap(Model$ model$, Model value, converters) => model$.instanceToStoreMap(value, converters);
}

class ListConverter implements Converter<List, List> {
  const ListConverter();
  
  List decodeValue(Converters converters, ClassMirror variableType, List value) {
    assert(variableType.typeArguments.first != null);
    ClassMirror arg = variableType.typeArguments.first;
    var model$ = Model$._modelsInfos[arg.reflectedType];
    if (model$ != null) {
      return createListOfInstances(model$, value, converters);
    }
    return value;
  }

  List encodeValue(Converters converters, ClassMirror variableType, List value) {
    assert(variableType.typeArguments.first != null);
    ClassMirror arg = variableType.typeArguments.first;
    var model$ = Model$._modelsInfos[arg.reflectedType];
    if (model$ != null) {
      return createListFromInstances(model$, value, converters);
    }
    return value;
  }


  List<Model> createListOfInstances(Model$ model$, List value, converters)
    => model$.createListOfInstances(value, converters);
  List<Map> createListFromInstances(Model$ model$, List value, converters)
    => model$.createListFromInstances(value, converters);

  List decode(ClassMirror variableType, List value) => null;
  List encode(ClassMirror variableType, List value) => null;
}


class ListStoreConverter extends ListConverter {
  const ListStoreConverter();

  List<Model> createListOfInstances(Model$ model$, List value, converters)
    => model$.createListOfInstancesFromStore(value, converters);
  List<Map> createListFromInstances(Model$ model$, List value, converters)
    => model$.createListFromInstancesToStore(value, converters);
}
