import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:driver/constants.dart';
import 'package:driver/constants/headers.dart';
import 'package:driver/controllers/profile_controller.dart';
import 'package:driver/models/TripRequestDetail.dart';
import 'package:driver/screens/home_screen2.dart';
import 'package:driver/services/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
// import 'package:get/get.dart';
import 'package:driver/screens/home_screen.dart';
import 'package:driver/screens/login_screen.dart';
import 'package:driver/screens/otp_screen.dart';
import 'package:driver/screens/edit_profile_screen.dart';
import 'package:driver/utilities/secure_storage_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestController extends GetxController {
  final Dio _dio = Dio();
  String? baseUrl;

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  SecureStorageHelper storageHelper = new SecureStorageHelper();
  final storage = new FlutterSecureStorage();
  ProfileController profileController = Get.put(ProfileController());

    DatabaseReference driverRef = FirebaseDatabase.instance.ref('drivers');

  @override
  void onInit() async {
    print("call onInit"); // this line not printing
    _dio.options.connectTimeout = Duration(seconds: 5); // 5 seconds
    _dio.options.receiveTimeout = Duration(seconds: 5); // 3 seconds
    if (!PRODUCTION) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
      baseUrl = DEV_BASE_URL;
    } else {
      baseUrl = PROD_BASE_URL;
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          // Do something before request is sent.
          // If you want to resolve the request with custom data,
          // you can resolve a `Response` using `handler.resolve(response)`.
          // If you want to reject the request with a error message,
          // you can reject with a `DioException` using `handler.reject(dioError)`.
          return handler.next(options);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          // Do something with response data.
          // If you want to reject the request with a error message,
          // you can reject a `DioException` object using `handler.reject(dioError)`.
          return handler.next(response);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) {
          // Do something with response error.
          // If you want to resolve the request with some custom data,
          // you can resolve a `Response` object using `handler.resolve(response)`.
          // if()

          print(e.error);
          print(e.message);
//  print(e.);

          return handler.next(e);
        },
      ),
    );

    super.onInit();
  }

  Future<void> sendVerificationCode(String phone) async {
    try {
      _isLoading.value = true;

      final response = await _dio.post('$baseUrl/functions/sendOtp',
          options: options, data: {"phone": phone});
      print(response);

      if (response.statusCode == 200) {
        _isLoading.value = false;
        Get.to(OTPScreen(
          phoneNumber: phone,
        ));
      } else {
        // Handle error
        _isLoading.value = false;
        print("Response Error: ${response.data}");
        Get.snackbar(
          "Vip Taxi",
          "Request failed ! Try again",
          backgroundColor: Colors.red,
          icon: const Icon(Icons.add_alert),
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      // Handle error
      _isLoading.value = false;
      Get.snackbar(
        "Vip Taxi",
        "Request failed ! Try again",
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add_alert),
        snackPosition: SnackPosition.TOP,
      );
      print("err: ${e.toString()}");
    }
  }

  Future<void> verityOtpAndSignin(String phone, String otp) async {
    try {
      _isLoading.value = true;
  String? fcmToken= await FirebaseMessagingService().getDeviceToken();

      final response = await _dio.post('$baseUrl/functions/auth',
          options: options,
          data: {"phone": phone, "verificationCode": otp, "isDriver": true});
      print(response);
      if (response.statusCode == 200) {
        _isLoading.value = false;
        print(response.data);
        // Map<String, dynamic> jsonData = jsonDecode(response.data);
        bool isNewUser = response.data['result']['newUser'];
        bool driverProfileCreated =
            response.data['result']['driverProfileCreated'];

        String userId = response.data['result']['userObj']['objectId'];
        String sessionToken =
            response.data['result']['userObj']['sessionToken'];
        print('data_______userId' + userId);
        print('data_______userId' + sessionToken);
        await storage.write(key: 'phone', value: phone);
        await storage.write(key: 'userId', value: userId);
        await storage.write(key: 'sessionToken', value: sessionToken);

        if (isNewUser == true || driverProfileCreated == false) {
          await storage.write(key: 'profileStatus', value: 'isNotCompleted');
           
          Get.offAll(() => EditProfileScreen());
        } else {
          String firstName = response.data['result']['driver']['firstName'];
          String lastName = response.data['result']['driver']['firstName'];
          String email = response.data['result']['driver']['email'];
                    String profile = response.data['result']['driver']['profilePic'];

          String driverId = response.data['result']['driver']['objectId'];
          updateDriver(driverId);

          await storage.write(key: 'firstName', value: firstName);
          await storage.write(key: 'lastName', value: lastName);
          await storage.write(key: 'email', value: email);
          await storage.write(key: 'driverId', value: driverId);

            await storage.write(key: 'profilePic', value: profile);

      profileController.firstName = firstName;
      profileController.profilePic = profile;
          await storage.write(key: 'profileStatus', value: 'isCompleted');

          Get.offAll(() => HomeScreen2());
        }
      } else {
        // Handle error
        _isLoading.value = false;
        print("Response Error: ${response.data}");
      }
    } catch (e) {
      // Handle error
      _isLoading.value = false;

      print("err: ${e.toString()}");
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;

      final response = await _dio.post(
        '$baseUrl/logout',
        options: options,
      );

      if (response.statusCode == 200) {
        await storage.deleteAll();
        _isLoading.value = false;
        Get.offAll(() => LoginScreen());

        // Get.to(LoginScreen());
      } else {
        // Handle error
        print("could not logout");
        _isLoading.value = false;
      }
    } catch (e) {
      // Handle error
      // print("could not logout");
      Get.snackbar(
        "Vip Taxi",
        "could not logout try again",
          backgroundColor: Colors.red,
        icon: const Icon(Icons.add_alert),
        snackPosition: SnackPosition.TOP,
      );
      
      _isLoading.value = false;

      print(e);
    }
  }
  Future<void> updateDriver(String driverId) async {
    // String driverId = await storage.read(key: 'driverId') ?? '';
  
  String? fcmToken= await FirebaseMessagingService().getDeviceToken();
    dynamic data = {
      // 'firstName': firstName,
      // 'lastName': lastName,
      // 'email': email,
      // 'phoneNumber': phone,
      'fcmTocken': fcmToken,
      // 'driverId': {
      //   "__type": "Pointer",
      //   "className": "_User",
      //   "objectId": userId
      // }
    };

    Response? response = await makeRequest('classes/drivers/${driverId}', 'put', data);
    print('responsCode: ${response?.statusCode}');
    if (response?.statusCode == 200 || response?.statusCode == 201) {
      print("Fcm uodated updated success-----------");
    
    } else {
      print("error:--$response");
    }
  }
  Future<bool> createDriver(
      String firstName, String lastName, String email, String profile,String licenseImage) async {
    String userId = await storage.read(key: 'userId') ?? '';
    String phone = await storage.read(key: 'phone') ?? '';
  String? fcmToken= await FirebaseMessagingService().getDeviceToken();
    dynamic data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phone,
      'fcmTocken': fcmToken,
      'profilePic': profile,
      'licenseImage':licenseImage,
      'driverId': {
        "__type": "Pointer",
        "className": "_User",
        "objectId": userId
      }
    };

    Response? response = await makeRequest('functions/drivers', 'post', data);
    print('responsCode: ${response?.statusCode}');
    if (response?.statusCode == 200 || response?.statusCode == 201) {
      print("profile updated success");
      print(response?.data);
      print(response?.data['result']['objectId']);
      String driverId = response?.data['result']['objectId'];
      await storage.write(key: 'firstName', value: firstName);
      await storage.write(key: 'lastName', value: lastName);
      await storage.write(key: 'email', value: email);
      await storage.write(key: 'driverId', value: driverId);
      await storage.write(key: 'profilePic', value: profile);

      profileController.firstName = firstName;
      profileController.profilePic = profile;

      await storage.write(key: 'profileStatus', value: 'isCompleted');
      
      return true;

    } else {
      print("error:--$response");
            return false;

    }
  }

 Future<dynamic> getTripDetail(String tripId) async {
    String driverId = await storage.read(key: 'driverId') ?? '';
    // var data ={
    //   "tripDetail": tripRequestDetail.toJson(),
    //   "updateType":updateType
    // };
    Response? response = await makeRequest('classes/clientRequest/${tripId}', 'get',{});
    print("trip create response $response");
    if (response?.statusCode == 200 || response?.statusCode == 201) {
      print("accpet trip success");


      return true;
    } else {
            print("accpet trip failed");

      return false;
    }
  }
 Future<bool> updateTripStatus(String requestId,String updateType) async {
    String driverId = await storage.read(key: 'driverId') ?? '';
    var data ={
      "tripReqestsId":requestId,
      "updateType":updateType
    };
    Response? response = await makeRequest('functions/acceptTrip', 'post', data);
    print("trip create response $response");
    if (response?.statusCode == 200 || response?.statusCode == 201) {
      print("accpet trip success");


      return true;
    } else {
            print("accpet trip failed");

      return false;
    }
  }
  Future<bool> startTripRequest(dynamic startLocation,String riderName,String riderPhone,String pickUpAddress,String destinationAddress) async {
    String driverId = await storage.read(key: 'driverId') ?? '';
    print("make trip start request");
    dynamic data = {
      'startLocation': startLocation,
      'status': 'started',
      'totalFair': 0.0,
      'waitingTime': '00:00:00',
      'riderName':riderName,
      'riderPhone':riderPhone,
      'pickUpAddress':pickUpAddress,
      'destinationAddress':destinationAddress,

      'driver': {
        "__type": "Pointer",
        "className": "drivers",
        "objectId": driverId
      }
    };
    Response? response = await makeRequest('classes/trip', 'post', data);
    print("trip create response $response");
    if (response?.statusCode == 200 || response?.statusCode == 201) {
      print("Trip created updated success $response");
      String tripId = response!.data['objectId'];
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('tripId', tripId);

      return true;
    } else {
      return false;
    }
  }

  Future<bool> stopTripRequest(String tripId, dynamic endLocation, num distance,
      int price, String waitingTime) async {
    // String userId = await storage.read(key: 'userId') ?? '';

    dynamic data = {
      // 'startLocation': startLocation,
      'endLocation': endLocation,
      'distnace': distance,
      'totalFair': price,
      'waitingTime': waitingTime,
      'status': 'stoped',
      // 'driver': {"__type": "Pointer", "className": "_User", "objectId": userId}
    };
    Response? response = await makeRequest('classes/trip/$tripId', 'put', data);
    if (response?.statusCode == 200) {
      print("Trip stop  updated success");

      return true;
    } else {
      return false;
    }
  }



  Future<Response<dynamic>?> makeRequest(
      String path, String method, dynamic data) async {
    Response response;
    try {
      _isLoading.value = true;
      String sessionToken = await storage.read(key: 'sessionToken') ?? '';

      Options authOptions = Options(
        headers: {
          'X-Parse-Application-Id': APP_NAME,
          'X-Parse-REST-API-Key': APP_REST_API_KEY,
          'X-Parse-Session-Token': sessionToken
        },
      );
      String basUrl = '$baseUrl/' + path;
      if (method == 'post') {
        response = await _dio.post(basUrl, options: authOptions, data: data);
        _isLoading.value = false;
        return response;
      } else if (method == 'get') {
        response = await _dio.get(basUrl, options: authOptions, data: data);

        _isLoading.value = false;
        return response;
      } else if (method == 'put') {
        response = await _dio.put(basUrl, options: authOptions, data: data);

        _isLoading.value = false;
        return response;
      } else {
        response = await _dio.delete(basUrl, options: authOptions, data: data);

        _isLoading.value = false;
        return response;
      }
    } catch (error) {
      // Handle error
      // print("could not make request ${error}");

      _isLoading.value = false;
      // throw Exception('Error occurred: $e');
      // return  Response
      // return null;
      Get.snackbar(
        "Vip Taxi",
        "Request failed ! Try again",
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add_alert),
        snackPosition: SnackPosition.TOP,
      );
      // if (error is DioException) {
      //   if (error.response != null) {
      //     // The request was made and the server responded with a status code
      //     int statusCode = error.response!.statusCode!;
      //     print('Error status code: $statusCode');
      //   } else {
      //     // Something went wrong during the request setup
      //     print('Error: ${error.message}');
      //   }
      // } else {
      //   // Something else went wrong
      //   print('Error: $error');
      // }
    }
    return null;
  }

}
