import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/config/themes.dart';
import 'package:qarz_daftar/presentation/blocs/debtor/debtor_bloc.dart';

import '../../widgets/components/debtors_list.dart';
import '../../widgets/empty.dart';
import '../../widgets/loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebtorBloc>().add(LoadDebtorsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qarz Daftari'),
        actions: [
          IconButton(
              onPressed: () {
                _showAddDebtorDialog(context);
              },
              icon: Icon(CupertinoIcons.add)),
          const SizedBox(width: 8,)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ro'yhat",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<DebtorBloc, DebtorState>(
                builder: (context, state) {
                  if (state is DebtorLoading) {
                    return const Loading();
                  } else if (state is DebtorsLoaded) {
                    if (state.debtors.isEmpty) {
                      return const Empty();
                    } else {
                      return DebtorsList(debtors: state.debtors);
                    }
                  } else if (state is DebtorError) {
                    return Center(
                      child: Text(
                        "Xatolik: ${state.message}",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text("Ma'lumot yo'q"),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDebtorDialog(BuildContext context) {
    String name = '';
    double amount = 0.0;
    bool isDebt = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // ✅ StatefulBuilder dan foydalanamiz
          builder: (BuildContext context, StateSetter setState) {
            // ✅ setState funksiyasi
            return AlertDialog(
              title: const Text('Yangi qarz qo\'shish'),
              content: SingleChildScrollView(
                // ➕ kichik ekranlarda ham muammo bo'lmasligi uchun
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Ism',
                        border: OutlineInputBorder(), // ✅ chiroyli dizayn
                      ),
                      onChanged: (value) => name = value,
                    ),
                    const SizedBox(height: 16), // ➕ orasini ochish
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Summa',
                        border: OutlineInputBorder(), // ✅ chiroyli dizayn
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          amount = double.tryParse(value) ?? 0.0,
                    ),
                    const SizedBox(height: 24), // ➕ orasini ochish
                    Row(
                      children: [
                        const Text('Men Qarzdorman'),
                        const SizedBox(width: 8),
                        // ➕ checkbox va text orasini ochish
                        Checkbox(
                          value: isDebt,
                          onChanged: (bool? value) {
                            setState(() {
                              // ✅ setState orqali checkbox holatini yangilaymiz
                              isDebt = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Bekor qilish'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (name.isNotEmpty && amount > 0) {
                      context.read<DebtorBloc>().add(
                            // ✅ context.read<DebtorBloc>()
                            AddDebtorEvent(
                                name: name, amount: amount, isDebt: isDebt),
                          );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Iltimos, ism va summani kiriting.')),
                      );
                    }
                  },
                  child: const Text('Saqlash'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
