import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_response_model.dart';

class UserDataSource {
  final Dio dio;

  UserDataSource(this.dio);

  Future<UserResponseModel> getUsers({
    required int page,
    int perPage = 6,
  }) async {
    final response = await dio.get(
      '/users',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );

    final userResponse = UserResponseModel.fromJson(response.data);

    // save api response
    final box = Hive.box('usersBox');

    await box.put(
      'users',
      jsonEncode(response.data),
    );

    return userResponse;
  }

  Future<UserResponseModel?> getCachedUsers() async {
    final box = Hive.box('usersBox');

// get cache user data response
    final cachedData = box.get('users');

    if (cachedData == null) {
      return null;
    }

    final jsonData = jsonDecode(cachedData);

    return UserResponseModel.fromJson(jsonData);
  }

}