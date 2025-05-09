import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food_recipe_app/auth_gate.dart';
import 'package:food_recipe_app/home_screen.dart';
import 'package:food_recipe_app/listing/blocs/recipe_bloc.dart';
import 'package:food_recipe_app/listing/screens/change_password_screen.dart';
import 'firebase_options.dart';

import 'authentication/bloc/auth_bloc.dart';
import 'authentication/repository/auth_repository.dart';
import 'authentication/screens/login_screen.dart';
import 'listing/repository/recipe_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final recipeRepository = RecipeRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<RecipeBloc>(
          create: (_) => RecipeBloc(repository: recipeRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Food Recipe App',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
        ),
        home: const AuthGate(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/change-password': (context) => ChangePasswordScreen(),
        },

      ),
    );
  }
}
