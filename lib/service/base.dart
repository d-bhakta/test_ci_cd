import 'package:dio/dio.dart' as dio_client;

class BaseUrl {
  static dio_client.Dio baseUrlMain() {
    dio_client.BaseOptions options = dio_client.BaseOptions();
    options.baseUrl = ApiConfig.baseUrl;
    dio_client.Dio dio = dio_client.Dio(options);
    return dio;
  }
}

class ApiConfig {
  static const baseUrl = "https://mocki.io/v1";
  static const baseurl2 = "https://nz.testapi.com";
}
