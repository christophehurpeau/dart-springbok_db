part of springbok_db;

/// Key of the db from the config file. Works on both server and browser.
class DbKey {
  final String key;
  
  const DbKey([this.key]);
}

/// Key of the db from the config file. Works only on server.
class DbServerKey extends DbKey{
  const DbServerKey([String key]) : super(key);
}

/// Key of the db from the config file. Works only on the browser.
class DbClientKey extends DbKey{
  const DbClientKey([String key]) : super(key);
}

/// key in the store for the db.
class StoreKey {
  final String key;
  
  const StoreKey(this.key);
}

class Transient {
  
  const Transient();
  
  String toString() => 'transient';
}

class ServerSideOnly {
  const ServerSideOnly();
  
  String toString() => 'ServerSideOnly';
}

class ClientSideOnly {
  const ClientSideOnly();
  
  String toString() => 'ClientSideOnly';
}



