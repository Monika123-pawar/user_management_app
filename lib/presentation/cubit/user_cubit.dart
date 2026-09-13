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

  bool isLoadingMore = false;

  Future<void> getUsers() async {
    emit(UserLoading());

    try {
      final hasInternet =
      await InternetConnection().hasInternetAccess;

      if (hasInternet) {
        currentPage = 1;

        final response = await repository.getUsers(
          page: currentPage,
        );

        totalPages = response.totalPages ?? 1;
        allUsers = response.users;

        emit(UserSuccess(allUsers));
      } else {
        await _loadFromCache();
      }
    } catch (e) {
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    final cachedUsers = await repository.getCachedUsers();

    if (cachedUsers != null) {
      totalPages = cachedUsers.totalPages ?? 1;
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

  Future<void> loadMoreUsers() async {
    if (isLoadingMore || currentPage >= totalPages) {
      return;
    }

    isLoadingMore = true;

    try {
      final nextPage = currentPage + 1;

      final response = await repository.getUsers(
        page: nextPage,
      );

      if (response.users.isNotEmpty) {
        currentPage = nextPage;

        allUsers = [
          ...allUsers,
          ...response.users,
        ];

        emit(UserSuccess(allUsers));
      }
    } catch (e) {
      emit(
        UserLoadMoreError(
          allUsers,
          'Failed to load more users',
        ),
      );
    } finally {
      isLoadingMore = false;
    }
  }

  void searchUsers(String query) {
    final searchText = query.trim().toLowerCase();

    if (searchText.isEmpty) {
      emit(UserSuccess(allUsers));
      return;
    }

    final filteredUsers = allUsers.where((user) {
      final name =
      '${user.firstName ?? ''} ${user.lastName ?? ''}'
          .toLowerCase();

      return name.contains(searchText);
    }).toList();

    emit(UserSuccess(filteredUsers));
  }
}