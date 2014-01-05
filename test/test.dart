import 'dart:async';
import 'package:unittest/unittest.dart';
import '../lib/springbok_db.dart';

class Account extends Model {
  static final $ = new Model$<Account>(Account);
  
  String provider;
}

class User extends Model {
  static final $ = new Model$<User>(User);
  
  String firstName;
  String lastName;
  int age;
  
  List<User> related;
  List<Account> accounts;
}


main() {
  Future.wait([ User.$.init(), Account.$.init() ])
    .then((_){});
  test('ModelInfos',(){
    expect(User.$.variables.length, 5);
    expect(Model$.modelsInfos.length, 2);
    User u = User.$.mapToInstance({
      'firstName': 'John',
      'lastName': 'Doe',
      'age': 24,
      
      'related': [
        { 'firstName': 'Jane', 'lastName': 'Doe', 'age': 33 }
      ],
      
      'accounts': [
        { 'provider': 'Twitter' }
      ]
    });
    expect(u.firstName, 'John');
    expect(u.lastName, 'Doe');
    expect(u.age, 24);
    expect(u.related.runtimeType.toString(), 'List');
    expect(u.related.length, 1);
    expect(u.related.first.runtimeType.toString(), 'User');
    expect(u.related.first.firstName, 'Jane');
    expect(u.related.first.age, 33);
    expect(u.accounts.runtimeType.toString(), 'List');
    expect(u.accounts.length, 1);
    expect(u.accounts.first.runtimeType.toString(), 'Account');
    expect(u.accounts.first.provider, 'Twitter');
    
    expect(u.toMap(),{
      'firstName': 'John',
      'lastName': 'Doe',
      'age': 24,
      'related': [{'firstName': 'Jane', 'lastName': 'Doe', 'age': 33}],
      'accounts': [{'provider': 'Twitter'}]
    });
  });
}
