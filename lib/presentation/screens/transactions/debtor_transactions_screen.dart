import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/core/models/transaction.dart';
import 'package:qarz_daftar/presentation/blocs/debtor/debtor_bloc.dart';

class DebtorTransactionsPage extends StatelessWidget {
  final Debtor debtor;

  const DebtorTransactionsPage({super.key, required this.debtor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(debtor.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Yangi tranzaksiya qo'shish logikasi
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => DebtorBloc()..add(GetTransactionsForDebtorEvent(debtorId: debtor.id)),
        child: BlocBuilder<DebtorBloc, DebtorState>(
          builder: (context, state) {
            if (state is DebtorLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DebtorTransactionsLoaded) {
              return _buildTransactionList(state.transactions);
            } else if (state is DebtorFailure) {
              return Center(child: Text(state.errorMessage));
            }
            return const Center(child: Text("Ma'lumot topilmadi"));
          },
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transactions> transactions) {
    return Column(
      children: [
        _buildBalanceCard(),
        Expanded(
          child: transactions.isEmpty
              ? const Center(child: Text("Tranzaksiyalar yo'q"))
              : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return ListTile(
                leading: Icon(
                  transaction.isDebt ? Icons.arrow_upward : Icons.arrow_downward,
                  color: transaction.isDebt ? Colors.red : Colors.green,
                ),
                title: Text("${transaction.amount} UZS"),
                subtitle: Text(DateFormat.yMMMMd().format(transaction.date)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Joriy balans:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              "${debtor.balance} UZS",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: debtor.isDebt ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
