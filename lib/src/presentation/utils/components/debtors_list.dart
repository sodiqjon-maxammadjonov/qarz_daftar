import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/src/presentation/utils/components/transactions_list.dart';
import 'package:qarz_daftar/src/presentation/utils/utilite/floating_snackbar.dart';

import '../../bloc/debtor/debtor_bloc.dart';
import '../widgets/debtor_card.dart';

class DebtorsList extends StatefulWidget {
  const DebtorsList({super.key});

  @override
  DebtorsListState createState() => DebtorsListState();
}

class DebtorsListState extends State<DebtorsList> {
  @override
  void initState() {
    super.initState();
    loadDebtors();
  }

  void loadDebtors() {
    context.read<DebtorBloc>().add(LoadDebtorsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DebtorBloc, DebtorState>(
      listener: (context, state) {
        if (state is DebtorSuccess) {
          FloatingSnackbar.show(context: context, message: state.message);
        } else if (state is DebtorError) {
          FloatingSnackbar.show(context: context, message: state.message, isError: true);
        }
      },
      child: BlocBuilder<DebtorBloc, DebtorState>(
        builder: (context, state) {
          if (state is DebtorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DebtorLoaded) {
            return RefreshIndicator(
              onRefresh: () async => loadDebtors(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.debtors.length,
                itemBuilder: (context, index) {
                  final debtor = state.debtors[index];
                  return DebtorCard(
                    debtor: debtor,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TransactionsList(debtor: debtor),
                      ));
                    },
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('Ma\'lumot yo\'q'));
          }
        },
      ),
    );
  }
}
