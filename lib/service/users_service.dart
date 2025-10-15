import 'dart:io';

import 'package:dio/dio.dart' as dio_client;
import 'package:flutter/cupertino.dart';

import 'base.dart';

class UsersService {
  static fetchUsers() async {
    try {
      dio_client.Response response;
      response = await BaseUrl.baseUrlMain().get(
        "/2ae5fbfb-ff8d-40bc-a3bb-8971d4ddc2c7",
      );
      debugPrint("fetch users response>> ${response.data}");
      return response;
    } on SocketException {
      debugPrint("fetch users socket exception");
    } on dio_client.DioException catch (e) {
      debugPrint("fetch users dio exception>> $e");
    }
  }
}
