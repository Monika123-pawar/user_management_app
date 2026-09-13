import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile image
                CircleAvatar(
                  radius: 60,
                  child: user.avatar != null &&
                      user.avatar!.isNotEmpty
                      ? ClipOval(
                    child: Image.network(
                      user.avatar!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 50,
                        );
                      },
                    ),
                  )
                      : const Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                // Name
                Text(
                  '${user.firstName ?? ''} ${user.lastName ?? ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Email
                Text(
                  user.email ?? 'Email not available',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // Phone
                Text(
                  'Phone: ${user.phone ?? 'Not available'}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}