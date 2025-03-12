import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qarz_daftar/src/data/models/debtor.dart';
import 'package:qarz_daftar/src/presentation/bloc/transaction/transactions_bloc.dart';
import 'package:qarz_daftar/src/presentation/utils/utilite/number_text.dart';
import 'package:qarz_daftar/src/presentation/utils/widgets/transactions_card.dart';
import '../../../data/models/transacrions.dart';
import 'add_transactions_modal.dart';

class TransactionsList extends StatefulWidget {
  final Debtor debtor;
  const TransactionsList({super.key, required this.debtor});

  @override
  TransactionsListState createState() => TransactionsListState();
}

class TransactionsListState extends State<TransactionsList> {
  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  void loadTransactions() {
    context.read<TransactionsBloc>().add(LoadTransactions(widget.debtor.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(widget.debtor.name),
          subtitle: NumberText(number: widget.debtor.balance),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showAddTransactionModal(context, widget.debtor.id);
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => loadTransactions(),
        child: BlocBuilder<TransactionsBloc, TransactionsState>(
          builder: (context, state) {
            if (state is TransactionsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionsLoaded) {
              final transactions = state.transactions;
              if (transactions.isEmpty) {
                return const Center(child: Text("Ma'lumot yo'q"));
              }

              // Tranzaksiyalarni sanaga qarab tartiblash
              transactions.sort((a, b) => b.date.compareTo(a.date));

              // Oylarga ajratish
              final Map<String, List<Transactions>> groupedTransactions = {};
              for (var transaction in transactions) {
                String monthYear = DateFormat('MMMM yyyy', 'uz').format(transaction.date);
                if (!groupedTransactions.containsKey(monthYear)) {
                  groupedTransactions[monthYear] = [];
                }
                groupedTransactions[monthYear]!.add(transaction);
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: groupedTransactions.length,
                itemBuilder: (context, index) {
                  String monthYear = groupedTransactions.keys.elementAt(index);
                  List<Transactions> monthTransactions = groupedTransactions[monthYear]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Oyning nomi (Header)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Text(
                          monthYear,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // O'sha oydagi tranzaksiyalar
                      ...monthTransactions.map((transaction) {
                        return TransactionsCard(
                          transaction: transaction,
                          debtorId: widget.debtor.id,
                        );
                      }).toList(),
                    ],
                  );
                },
              );
            } else if (state is TransactionsError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text('Ma\'lumot yo\'q'));
            }
          },
        ),
      ),
    );
  }

  void showAddTransactionModal(BuildContext context, String debtorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AddTransactionModal(debtorId: debtorId),
    );
  }
}
