import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/src/core/constant/constants.dart';
import 'package:qarz_daftar/src/presentation/bloc/debtor/debtor_bloc.dart';
import 'package:qarz_daftar/src/presentation/utils/utilite/balance_card.dart';
import '../../utils/components/add_debtor_modal.dart';
import '../../utils/components/debtors_list.dart';
import '../../utils/components/selected_debtors_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Qidirish...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: theme.appBarTheme.foregroundColor?.withOpacity(0.7) ?? Colors.black54,
              fontSize: 16,
            ),
          ),
          onChanged: (value) {
            context.read<DebtorBloc>().add(LoadDebtorsEvent(name: value));
          },
          // Matn rangini appbar rangiga moslash uchun
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor ?? Colors.black,
            fontSize: 16,
          ),
        )
            : Text(Constants.appName),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  // Qidiruv tugaganda barcha ma'lumotlarni qayta yuklash
                  context.read<DebtorBloc>().add(const LoadDebtorsEvent());
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showAddDebtorModal(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Qarzdorlar'),
            Tab(text: 'Tanlanganlar'),
          ],
        ),
      ),
      body: Column(
        children: [
          BalanceCard(isCheckedOnly: _tabController.index == 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                DebtorsList(),
                SelectedDebtorsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

void showAddDebtorModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const AddDebtorModal(),
  );
}