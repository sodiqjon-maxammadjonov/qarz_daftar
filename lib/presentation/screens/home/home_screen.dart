import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/presentation/blocs/debtor/debtor_bloc.dart';
import 'package:qarz_daftar/presentation/widgets/components/debtors_list.dart';
import 'package:qarz_daftar/presentation/widgets/empty.dart';
import 'package:qarz_daftar/presentation/widgets/loading.dart';
import '../../../config/themes.dart';
import '../../../core/models/debtor.dart';
import '../../widgets/components/add_debt_modal.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebtorBloc>().add(GetDebtorsEvent());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshDebtors() async {
    context.read<DebtorBloc>().add(GetDebtorsEvent());
    return await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Qarz Daftari",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                IconButton(
                  onPressed: () {
                    _showAddDebtDialog(context);
                  },
                  icon: Icon(
                    Icons.add_circle,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildBalanceCard(context),
            const SizedBox(height: 24),
            Text(
              "So'nggi qarzlar",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<DebtorBloc, DebtorState>(
                builder: (context, state) {
                  return _buildDebtorList(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtorList(BuildContext context, DebtorState state) {
    if (state is DebtorLoading) {
      return Loading();
    } else if (state is DebtorFailure) {
      return _buildErrorView(context);
    } else if (state is DebtorsLoaded) {
      return _buildLoadedView(context, state.debtors);
    } else {
      return _buildInitialView(context);
    }
  }

  Widget _buildErrorView(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thickness: 6,
      radius: const Radius.circular(10),
      thumbVisibility: true,
      child: RefreshIndicator(
        onRefresh: _refreshDebtors,
        child: ListView(
          controller: _scrollController,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Empty(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedView(BuildContext context, List<Debtor> debtors) {
    return Scrollbar(
      controller: _scrollController,
      thickness: 6,
      radius: const Radius.circular(10),
      thumbVisibility: false,
      child: RefreshIndicator(
        onRefresh: _refreshDebtors,
        color: AppTheme.primaryColor,
        child: debtors.isEmpty
            ? ListView(
          controller: _scrollController,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Empty(),
            ),
          ],
        )
            : DebtorsList(
          debtor: debtors,
          scrollController: _scrollController,
        ),
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thickness: 6,
      radius: const Radius.circular(10),
      thumbVisibility: true,
      child: RefreshIndicator(
        onRefresh: _refreshDebtors,
        child: ListView(
          controller: _scrollController,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Center(
                child: Text("Ma'lumot yuklanmadi"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppTheme.primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Umumiy balans",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "1,250,000 UZS",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBalanceItem(
                  context,
                  "Siz qarzdorsiz",
                  "250,000 UZS",
                  AppTheme.debtColor,
                  Icons.arrow_upward,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: AppTheme.lightTextColor.withOpacity(0.2),
                ),
                _buildBalanceItem(
                  context,
                  "Sizga qarzdor",
                  "1,500,000 UZS",
                  AppTheme.creditColor,
                  Icons.arrow_downward,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(
      BuildContext context,
      String title,
      String amount,
      Color color,
      IconData icon,
      ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddDebtModal(),
    );
  }
}