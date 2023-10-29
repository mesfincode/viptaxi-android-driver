import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class SecureStorageHelper{
  final storage = new FlutterSecureStorage();

  Future<void> storeValue(String key,String value) async{
      await storage.write(key: key, value: value);

  }

Future<String> getValue(String key) async{
     return await storage.read(key: key)??'';

  }

}