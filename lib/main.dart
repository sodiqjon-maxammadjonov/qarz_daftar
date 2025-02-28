import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/config/constants.dart';
import 'package:qarz_daftar/config/themes.dart';
import 'package:qarz_daftar/presentation/blocs/splash/splash_bloc.dart';
import 'package:qarz_daftar/presentation/screens/splash/splash_screen.dart';

void main() {
  runApp(MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SplashBloc()),
      ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: AppTheme.lightTheme(),
      home: SplashScreen(),
    );
  }
}
