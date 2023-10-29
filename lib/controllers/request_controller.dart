import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:driver/constants/headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/route_manager.dart';
// import 'package:get/get.dart';
import 'package:driver/screens/home_screen.dart';
import 'package:driver/screens/login_screen.dart';
import 'package:driver/screens/otp_screen.dart';
import 'package:driver/screens/edit_profile_screen.dart';
import 'package:driver/utilities/secure_storage_helper.dart';

class RequestController extends GetxController {
  final Dio _dio = Dio();
  String? baseUrl;
  final production = false;

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  SecureStorageHelper storageHelper = new SecureStorageHelper();
  final storage = new FlutterSecureStorage();

  @override
  void onInit() async {
    print("call onInit"); // this line not printing

    if (!production) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
      baseUrl = 'http://192.168.0.38:1337/parse';
    } else {
      baseUrl = 'https://sfu.insat.gov.et/restapi/parse';
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
          if (e.response?.statusCode == 404) {}
          print(e.response?.data);
          print(e.error);
          
          Get.snackbar(
            "app",
            "${e.message}",
            icon: Icon(Icons.person, color: Colors.white),
            snackPosition: SnackPosition.TOP,
          );
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
      }
    } catch (e) {
      // Handle error
      _isLoading.value = false;

      print("err: ${e.toString()}");
    }
  }

  Future<void> verityOtpAndSignin(String phone, String otp) async {
    try {
      _isLoading.value = true;

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

          Get.offAll(EditProfileScreen());
        } else {
          String firstName = response.data['result']['driver']['firstName'];
          String lastName = response.data['result']['driver']['firstName'];
          String email = response.data['result']['driver']['email'];
          await storage.write(key: 'firstName', value: firstName);
          await storage.write(key: 'lastName', value: lastName);
          await storage.write(key: 'email', value: email);

          Get.offAll(HomeScreen());
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
        Get.offAll(LoginScreen());

        // Get.to(LoginScreen());
      } else {
        // Handle error
        print("could not logout");
        _isLoading.value = false;
      }
    } catch (e) {
      // Handle error
      print("could not logout");
      Get.snackbar(
        "app",
        "could not logout try again",
        icon: Icon(Icons.person, color: Colors.white),
        snackPosition: SnackPosition.TOP,
      );
      print(e);
    }
  }

  Future<void> createDriver(
      String firstName, String lastName, String email) async {
    String userId = await storage.read(key: 'userId') ?? '';

    dynamic data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      // 'driverId':userId
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

      await storage.write(key: 'profileStatus', value: 'isCompleted');

      Get.offAll(HomeScreen());
    } else {
      print("error:--$response");
    }
  }

  Future<bool> startTripRequest(dynamic startLocation) async {
    String userId = await storage.read(key: 'userId') ?? '';

    dynamic data = {
      'startLocation': startLocation,
      // 'endLocation': endLocation,
      'status': 'started',
      'driver': {"__type": "Pointer", "className": "_User", "objectId": userId}
    };
    Response? response = await makeRequest('classes/trip', 'post', data);
    if (response?.statusCode == 200) {
      print("Trip created updated success");

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
          'X-Parse-Application-Id': 'myAppId',
          'X-Parse-REST-API-Key': 'yourRestApiKey',
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
    } catch (e) {
      // Handle error
      print("could not make request ${e}");

      _isLoading.value = false;
      // throw Exception('Error occurred: $e');
      // return  Response
      // return null;
    }
    return null;
  }
}
