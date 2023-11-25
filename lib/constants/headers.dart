
import 'package:dio/dio.dart';
import 'package:driver/constants.dart';

Options options = Options(
      headers: {
        'X-Parse-Application-Id': APP_NAME,
        'X-Parse-REST-API-Key': APP_REST_API_KEY,
      },
    );

