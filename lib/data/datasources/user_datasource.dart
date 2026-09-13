import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_response_model.dart';

class UserDataSource {
  final Dio dio;

  UserDataSource(this.dio);

  Future<UserResponseModel> getUsers({
    required int page,
    int perPage = 10,
  }) async {
    final response = await dio.get(
      '/users',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );

    final userResponse =
    UserResponseModel.fromJson(response.data);

    final box = Hive.box('usersBox');

    // Get existing cached users
    List<dynamic> cachedUsers = [];

    final existingData = box.get('users');

    if (existingData != null) {
      final existingJson = jsonDecode(existingData);

      if (existingJson['data'] != null) {
        cachedUsers = existingJson['data'];
      }
    }

    // Add new users from current page
    final newUsers = response.data['data'] ?? [];

    final existingIds = cachedUsers
        .map((user) => user['id'])
        .toSet();

    for (final user in newUsers) {
      if (!existingIds.contains(user['id'])) {
        cachedUsers.add(user);
      }
    }

    // Save combined users
    await box.put(
      'users',
      jsonEncode({
        'page': response.data['page'],
        'per_page': response.data['per_page'],
        'total': response.data['total'],
        'total_pages': response.data['total_pages'],
        'data': cachedUsers,
      }),
    );

    // Save cache time
    await box.put(
      'cachedTime',
      DateTime.now().toIso8601String(),
    );

    return userResponse;
  }

  Future<UserResponseModel?> getCachedUsers() async {
    final box = Hive.box('usersBox');

    final cachedData = box.get('users');

    if (cachedData == null) {
      return null;
    }

    final cachedTimeString = box.get('cachedTime');

    if (cachedTimeString == null) {
      return null;
    }

    final cachedTime = DateTime.parse(cachedTimeString);

    final cacheAge =
    DateTime.now().difference(cachedTime);

    // Cache valid for 30 minutes
    if (cacheAge.inMinutes > 30) {
      return null;
    }

    final jsonData = jsonDecode(cachedData);

    return UserResponseModel.fromJson(jsonData);
  }
}