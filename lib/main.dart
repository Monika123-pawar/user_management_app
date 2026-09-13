import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_management_app/presentation/cubit/user_cubit.dart';
import 'core/dependency_injection/injection.dart';
import 'presentation/screens/user_list_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('usersBox');
  // await Hive.box('usersBox').clear(); // TEMPORARY


  setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management App',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => getIt<UserCubit>(),
        child: const UserListScreen(),
      ),
    );
  }
}
