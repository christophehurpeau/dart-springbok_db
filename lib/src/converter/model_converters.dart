part of springbok_db;

class ModelConverters<T extends Model> {
  static final Converter _instanceToMapConverter = new InstanceToMapConverter(rules: {
    reflectClass(DateTime): const DateTimeToIntRule(),
    reflectClass(Id): const IdToStringRule(),
    reflectClass(Model): const ModelToMapRule(),
  });
  
  static final Converter _mapToInstanceConverter = new MapToInstanceConverter(rules: {
    reflectClass(DateTime): const DateTimeToIntRule(),
    reflectClass(Id): const IdToStringRule(),
    reflectClass(Model): const ModelToMapRule(),
  });
  
  Model$ model$;
  Converter _instanceToStoreMapConverter;
  Converter _storeMapToInstanceConverter;
  MapToStoreMapConverter _mapToStoreMapConverter;
  
  ModelConverters(this.model$);
  
  void updateStore(AbstractStoreInstance<T> store) {
    _storeMapToInstanceConverter = new MapToInstanceConverter(rules: store.converterRules, allowNull: true);
    _instanceToStoreMapConverter = new InstanceToMapConverter(rules: store.converterRules, allowNull: true);
    _mapToStoreMapConverter = new MapToStoreMapConverter(rules: store.converterRules);
    _mapToStoreMapConverter.rules.addAll({
      reflectClass(List): const ListSimpleConverterRule(),
      reflectClass(Map): const MapSimpleConverterRule(),
      reflectClass(String): const StringToIdConverterRule(),
    });
  }
  
  
  static _mapToInstance(Model$ model$, Map values, Converter converter) {
    var instance = model$.newInstanceMirror();
    values.forEach((String fieldName, value) {
      var variable = model$.variables[fieldName];
      if (variable == null) {
        return;
      }
      
      if (value != null) {
        ClassMirror variableType = variable.type;
        value = converter.convert(variableType, value);
      }

      instance.setField(variable.simpleName, value);
    });
    return instance.reflectee;
  }
  
  static _instanceToMap(Model$ model$, Model object, Converter converter) {
    assert(object != null);
    InstanceMirror mirror = reflect(object);
    
    Map result = {};
    model$.variables.forEach((String fieldName, VariableMirror variable) {
      Object value = mirror.getField(variable.simpleName).reflectee;
      
      if (value != null) {
        ClassMirror variableType = variable.type;
        value = converter.convert(variableType, value);
        if (converter.allowNull || value != null) {
          result[fieldName] = value;
        }
      }
    });
    return result;
  }
  
  static _mapToMap(Model$ model$, Map values, Converter converter) {
    Map result = {};
    values.forEach((String fieldName, value) {
      var variable = model$.variables[fieldName];
      if (variable == null) {
        return;
      }
      
      if (value != null) {
        ClassMirror variableType = variable.type;
        value = converter.convert(variableType, value);
        
        if (converter.allowNull || value != null) {
          result[fieldName] = value;
        }
      }
    });
    return result;
  }
    
  
  T mapToInstance(Map values)
    => _mapToInstance(model$, values, _mapToInstanceConverter);

  List<T> listOfMapsToInstances(Iterable<Map<String, dynamic>> listOfValues)
    => listOfValues.map(mapToInstance).toList();
  
  T storeMapToInstance(Map values)
    => _mapToInstance(model$, values, _storeMapToInstanceConverter);
  
  List<T> listOfStoreMapsToInstances(Iterable<Map<String, dynamic>> listOfValues)
    => listOfValues.map(storeMapToInstance).toList();
  
  Map instanceToMap(T instance)
    => _instanceToMap(model$, instance, _instanceToMapConverter);

  List<Map> listOfInstancesToMaps(Iterable<T> listOfValues)
    => listOfValues.map(instanceToMap).toList();
  
  Map instanceToStoreMap(T instance)
    => _instanceToMap(model$, instance, _instanceToStoreMapConverter);
  
  List<Map> listOfInstancesToStoreMaps(Iterable<T> listOfValues)
    => listOfValues.map(instanceToStoreMap).toList();
 
  
  Map mapToStoreMap(Map values)
    => _mapToMap(model$, values, _instanceToStoreMapConverter);

  Map storeMapToMap(Map values)
    => _mapToMap(model$, values, _storeMapToInstanceConverter);
  
  Map dataToStoreData(Map value) {
    Map result = {};
    value.forEach((String fieldName, value) {
      if (value != null) {
        value = _mapToStoreMapConverter.convert(reflectClass(value.runtimeType), value);
        result[fieldName] = value;
      }
    });
    return result;
  }
}