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

  var _profilePic = ''.obs;
  String get profilePic => _profilePic.value;
  set profilePic(String value) => _profilePic.value = value;

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  void getProfile() async {
    try {
      _phone.value = await storage.read(key: 'phone') ?? '';
      _email.value = await storage.read(key: 'email') ?? '';
      _firstName.value = await storage.read(key: 'firstName') ?? '';
      _profilePic.value = await storage.read(key: 'profilePic') ?? '';
      print(_profilePic);
    } catch (e) {
      print(e);
    }
  }
}
