import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_management_app/data/models/user_model.dart';
import 'package:user_management_app/data/models/user_response_model.dart';
import 'package:user_management_app/data/repositories/user_repository.dart';
import 'package:user_management_app/presentation/cubit/user_cubit.dart';
import 'package:user_management_app/presentation/states/user_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository repository;
  late UserCubit cubit;

  setUp(() {
    repository = MockUserRepository();
    cubit = UserCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  // Test  Pagination

  test('loadMoreUsers should append page 2 users', () async {
    final page1Users = [
      UserModel(
        id: 1,
        firstName: 'George',
        lastName: 'Bluth',
        email: 'george.bluth@reqres.in',
      ),
      UserModel(
        id: 2,
        firstName: 'Janet',
        lastName: 'Weaver',
        email: 'janet.weaver@reqres.in',
      ),
    ];

    final page2Users = [
      UserModel(
        id: 3,
        firstName: 'Emma',
        lastName: 'Wong',
        email: 'emma.wong@reqres.in',
      ),
      UserModel(
        id: 4,
        firstName: 'Eve',
        lastName: 'Holt',
        email: 'eve.holt@reqres.in',
      ),
    ];

    // Mock page 1 API response
    when(
          () => repository.getUsers(page: 1),
    ).thenAnswer(
          (_) async => UserResponseModel(
        page: 1,
        totalPages: 2,
        users: page1Users,
      ),
    );

    // Mock page 2 API response
    when(
          () => repository.getUsers(page: 2),
    ).thenAnswer(
          (_) async => UserResponseModel(
        page: 2,
        totalPages: 2,
        users: page2Users,
      ),
    );

    // Load page 1
    await cubit.getUsers();

    expect(cubit.currentPage, 1);
    expect(cubit.allUsers.length, 2);

    // Load page 2
    await cubit.loadMoreUsers();

    // Page should now be 2
    expect(cubit.currentPage, 2);

    // 2 + 2 = 4 users
    expect(cubit.allUsers.length, 4);

    // Check users
    expect(cubit.allUsers[0].firstName, 'George');
    expect(cubit.allUsers[1].firstName, 'Janet');
    expect(cubit.allUsers[2].firstName, 'Emma');
    expect(cubit.allUsers[3].firstName, 'Eve');

    // State should be success
    expect(cubit.state, isA<UserSuccess>());

    // Page 2 API should be called once
    verify(
          () => repository.getUsers(page: 2),
    ).called(1);
  });

  // Test 2: Search

  test('searchUsers should return matching users', () async {
    final users = [
      UserModel(
        id: 1,
        firstName: 'George',
        lastName: 'Bluth',
        email: 'george.bluth@reqres.in',
      ),
      UserModel(
        id: 2,
        firstName: 'Janet',
        lastName: 'Weaver',
        email: 'janet.weaver@reqres.in',
      ),
      UserModel(
        id: 3,
        firstName: 'Emma',
        lastName: 'Wong',
        email: 'emma.wong@reqres.in',
      ),
    ];

    when(
          () => repository.getUsers(page: 1),
    ).thenAnswer(
          (_) async => UserResponseModel(
        page: 1,
        totalPages: 1,
        users: users,
      ),
    );

    // Load users first
    await cubit.getUsers();

    // Search for George
    cubit.searchUsers('george');

    expect(cubit.state, isA<UserSuccess>());

    final state = cubit.state as UserSuccess;

    // Only George should match
    expect(state.users.length, 1);
    expect(state.users[0].firstName, 'George');
    expect(state.users[0].lastName, 'Bluth');
  });

  // Test 3: Last page protection

  test(
    'loadMoreUsers should not call API when on last page',
        () async {
      final users = [
        UserModel(
          id: 1,
          firstName: 'George',
          lastName: 'Bluth',
          email: 'george.bluth@reqres.in',
        ),
      ];

      when(
            () => repository.getUsers(page: 1),
      ).thenAnswer(
            (_) async => UserResponseModel(
          page: 1,
          totalPages: 1,
          users: users,
        ),
      );

      // Load page 1
      await cubit.getUsers();

      expect(cubit.currentPage, 1);
      expect(cubit.totalPages, 1);

      // Try to load another page
      await cubit.loadMoreUsers();

      // Still page 1
      expect(cubit.currentPage, 1);

      // Page 1 API should only be called once
      verify(
            () => repository.getUsers(page: 1),
      ).called(1);

      // Page 2 should never be called
      verifyNever(
            () => repository.getUsers(page: 2),
      );
    },
  );
}