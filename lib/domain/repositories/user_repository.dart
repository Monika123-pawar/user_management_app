import '../../data/models/user_response_model.dart';

abstract class UserRepository {
  Future<UserResponseModel> getUsers({
    required int page,
    int perPage = 6,
  });
}