import 'user_model.dart';

class UserResponseModel {
  final int? page;
  final int? perPage;
  final int? total;
  final int? totalPages;
  final List<UserModel> users;

  UserResponseModel({
    this.page,
    this.perPage,
    this.total,
    this.totalPages,
    required this.users,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      page: json['page'],
      perPage: json['per_page'],
      total: json['total'],
      totalPages: json['total_pages'],
      users: json['data'] != null
          ? (json['data'] as List)
          .map(
            (user) => UserModel.fromJson(user),
      )
          .toList()
          : [],
    );
  }
}