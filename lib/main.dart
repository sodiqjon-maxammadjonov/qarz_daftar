import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:qarz_daftar/src/core/constant/constants.dart';
import 'package:qarz_daftar/src/core/themes/app_theme.dart';
import 'package:qarz_daftar/src/presentation/bloc/debtor/debtor_bloc.dart';
import 'package:qarz_daftar/src/presentation/bloc/transaction/transactions_bloc.dart';

import 'package:qarz_daftar/src/presentation/bloc/pin/pin_bloc.dart';
import 'package:qarz_daftar/src/presentation/screen/home/pin_screen.dart'; // PIN screen import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await initializeDateFormatting();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DebtorBloc()),
        BlocProvider(create: (context) => TransactionsBloc()),
        BlocProvider(create: (context) => PinBloc()),
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
      home: PinScreen(),
    );
  }
}
