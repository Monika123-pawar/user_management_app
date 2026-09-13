import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_management_app/presentation/screens/user_detail_screen.dart';
import '../cubit/user_cubit.dart';
import '../states/user_state.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().getUsers();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    // Don't paginate while searching
    if (_searchController.text.trim().isNotEmpty) {
      return;
    }
    final position = _scrollController.position;
    // Load next page near bottom
    if (position.pixels >= position.maxScrollExtent - 120) {
      context.read<UserCubit>().loadMoreUsers();
    }
  }

  Future<void> _refreshUsers() async {
    await context.read<UserCubit>().getUsers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
          ),
          child: Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.all(16),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, child) {
                    return TextField(
                      controller: _searchController,
                      onChanged: (text) {
                        context.read<UserCubit>().searchUsers(text);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: value.text.isNotEmpty
                            ? IconButton(
                          onPressed: () {
                            _searchController.clear();

                            context
                                .read<UserCubit>()
                                .searchUsers('');
                          },
                          icon: const Icon(Icons.clear),
                        )
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                    );
                  },
                ),
              ),

              // User list
              Expanded(
                child: BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    // Initial loading
                    if (state is UserLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // API error
                    if (state is UserError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.message),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                context.read<UserCubit>().getUsers();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Load more error
                    if (state is UserLoadMoreError) {
                      return _buildUserList(
                        users: state.users,
                        loadMoreError: state.message,
                      );
                    }

                    // Success
                    if (state is UserSuccess) {
                      if (state.users.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _refreshUsers,
                          child: ListView(
                            physics:
                            const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 250),
                              Center(
                                child: Text('No users found'),
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildUserList(
                        users: state.users,
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList({
    required List users,
    String? loadMoreError,
  }) {
    final cubit = context.read<UserCubit>();
    final bool isSearching =
        _searchController.text.trim().isNotEmpty;
    final bool hasMorePages =
        cubit.currentPage < cubit.totalPages;

    return RefreshIndicator(
      onRefresh: _refreshUsers,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),

          itemCount: users.length +
              (!isSearching && hasMorePages ? 1 : 0),

          itemBuilder: (context, index) {
            // Pagination footer
            if (index == users.length) {
              return _buildPaginationFooter(
                cubit: cubit,
                loadMoreError: loadMoreError,
              );
            }

            final user = users[index];

            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserDetailScreen(
                      user: user,
                    ),
                  ),
                );
              },

              //  profile image
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: user.avatar != null &&
                        user.avatar!.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        user.avatar!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                          );
                        },
                      ),
                    )
                        : const Icon(Icons.person),
                  ),
                ],
              ),

              // Name
              title: Text(
                '${user.firstName ?? ''} ${user.lastName ?? ''}',
              ),

              // Email
              subtitle: Text(
                user.email ?? 'Email not available',
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaginationFooter({
    required UserCubit cubit,
    String? loadMoreError,
  }) {
    // Loading more
    if (cubit.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Loading more users...'),
          ],
        ),
      );
    }

    // Load more error
    if (loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 16,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              loadMoreError,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                cubit.loadMoreUsers();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // More pages available
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.keyboard_arrow_down,
            size: 30,
          ),
          SizedBox(height: 6),
          Text(
            'Scroll down to load more users',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}