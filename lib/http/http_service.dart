import 'package:dio/dio.dart';
import 'dart:convert' show utf8, base64;

import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    as secureStorage;

class HttpService {
  Dio _dio = Dio();
  final storage = new secureStorage.FlutterSecureStorage();

  final baseUrl = "http://192.168.1.245:5000/";

  HttpService() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
    initializeInterceptors();
  }

  Future<Response> postRequest({
    String endPoint,
    Map<String, dynamic> data,
  }) async {
    Response response;
    String email = await storage.read(key: 'email') != null
        ? await storage.read(key: 'email')
        : "";
    String password = await storage.read(key: 'password') != null
        ? await storage.read(key: 'password')
        : "";
    String key = await storage.read(key: 'key') != null
        ? await storage.read(key: 'key')
        : "";
    String credentials = base64.encode(utf8.encode('$email:$password'));
    try {
      response = await _dio.post(endPoint,
          data: data,
          options: Options(headers: {
            'Basic_Token': 'Basic $credentials',
            'Authorization': 'Token $key',
          }));
    } on DioError catch (e) {
      print(e.message);
      return Future.error(e, StackTrace.current);
    }

    return response;
  }

  void initializeInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      // Do something before request is sent
      return handler.next(options); //continue
      // If you want to resolve the request with some custom data，
      // you can resolve a `Response` object eg: return `dio.resolve(response)`.
      // If you want to reject the request with a error message,
      // you can reject a `DioError` object eg: return `dio.reject(dioError)`
    }, onResponse: (response, handler) {
      // Do something with response data
      return handler.next(response); // continue
      // If you want to reject the request with a error message,
      // you can reject a `DioError` object eg: return `dio.reject(dioError)`
    }, onError: (DioError e, handler) {
      // Do something with response error
      return handler.next(e); //continue
      // If you want to resolve the request with some custom data，
      // you can resolve a `Response` object eg: return `dio.resolve(response)`.
    }));
  }
}
