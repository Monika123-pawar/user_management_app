import '../datasources/user_datasource.dart';
import '../models/user_response_model.dart';

class UserRepository {
  final UserDataSource dataSource;

  UserRepository(this.dataSource);

  Future<UserResponseModel> getUsers({
    required int page,
    int perPage = 10,
  }) {
    return dataSource.getUsers(
      page: page,
      perPage: perPage,
    );
  }

  Future<UserResponseModel?> getCachedUsers() {
    return dataSource.getCachedUsers();
  }

}