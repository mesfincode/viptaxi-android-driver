import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final storage = new FlutterSecureStorage();

  var _firstName = ''.obs;
  String get firstName => _firstName.value;
  set firstName(String value) => _firstName.value = value;


  var _phone = ''.obs;
  String get phone => _phone.value;
  var _email = ''.obs;
  String get email => _email.value;
  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  void getProfile() async {
    _phone.value = await storage.read(key: 'phone') ?? '';
    _email.value = await storage.read(key: 'email') ?? '';
    _firstName.value = await storage.read(key: 'firstName') ?? '';
  }
}
