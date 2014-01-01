part of springbok_db;

abstract class Id {
  factory Id([String id]) {
    if (id == null) {
      throw new UnimplementedError('not yet implemented');
    } else {
      return new IdString(id);
    }
  }
  
  String toJson() => toString();
  bool operator==(Id other) => other.toString() == toString();
}

class IdString implements Id{
  final String _string;
  
  const IdString(this._string);
  
  String toString() => _string;
  String toJson() => _string;
  
  int get hashCode => _string.hashCode;

  bool operator==(Id other) => other.toString() == toString();
}