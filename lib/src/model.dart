part of springbok_db;

abstract class Model {
  Model$ get _modelInfos => Model$._modelsInfos[this.runtimeType]; // TODO : final attribute ?

  Map toMap() => _modelInfos.instanceToMap(this);
  Map toStoreMap() => _modelInfos.instanceToStoreMap(this);
  toJson() => toMap();
  
  Future save() => _modelInfos.save(toStoreMap());
  Future insert() => _modelInfos.insert(toStoreMap());
}
