import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../states/user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository repository;

  UserCubit(this.repository) : super(UserInitial());

  int currentPage = 1;
  int totalPages = 1;
  List<UserModel> allUsers = [];

  Future<void> getUsers() async {
    emit(UserLoading());

    final hasInternet =
    await InternetConnection().hasInternetAccess;

    try {
      if (hasInternet) {
        currentPage = 1;

        final response = await repository.getUsers(
          page: currentPage,
        );

        totalPages = response.totalPages;
        allUsers = response.users;

        emit(UserSuccess(allUsers));
      } else {
        // If no internet then get data from cached users
        final cachedUsers = await repository.getCachedUsers();

        if (cachedUsers != null) {
          totalPages = cachedUsers.totalPages;
          allUsers = cachedUsers.users;

          emit(UserSuccess(allUsers));
        } else {
          emit(UserError('No internet connection'));
        }
      }
    } catch (e) {
      // If api failed then get data from cached users
      final cachedUsers = await repository.getCachedUsers();

      if (cachedUsers != null) {
        totalPages = cachedUsers.totalPages;
        allUsers = cachedUsers.users;

        emit(UserSuccess(allUsers));
      } else {
        emit(
          UserError(
            'Something went wrong. Please try again.',
          ),
        );
      }
    }
  }

  Future<void> loadMoreUsers() async {
    if (currentPage >= totalPages) {
      return;
    }

    try {
      final response = await repository.getUsers(
        page: currentPage + 1,
      );

      currentPage++;

      allUsers = [
        ...allUsers,
        ...response.users,
      ];

      emit(UserSuccess(allUsers));
    } catch (e) {
      // Load more error handled later
    }
  }

  void searchUsers(String query) {
    if (query.trim().isEmpty) {
      emit(UserSuccess(allUsers));
      return;
    }

    final searchText = query.trim().toLowerCase();

    final filteredUsers = allUsers.where((user) {
      final name =
      '${user.firstName} ${user.lastName}'.toLowerCase();

      return name.contains(searchText);
    }).toList();

    emit(UserSuccess(filteredUsers));
  }
}