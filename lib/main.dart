import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/config/constants.dart';
import 'package:qarz_daftar/config/themes.dart';
import 'package:qarz_daftar/presentation/blocs/debtor/debtor_bloc.dart';
import 'package:qarz_daftar/presentation/blocs/splash/splash_bloc.dart';
import 'package:qarz_daftar/presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase'ni ishga tushirish
  await Firebase.initializeApp();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SplashBloc()),
        BlocProvider(create: (context) => DebtorBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: AppTheme.lightTheme(),
      home: SplashScreen(),
    );
  }
}
