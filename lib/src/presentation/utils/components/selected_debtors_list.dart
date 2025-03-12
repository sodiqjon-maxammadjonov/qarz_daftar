import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/debtor/debtor_bloc.dart';
import '../widgets/debtor_card.dart';

class SelectedDebtorsList extends StatefulWidget {

  const SelectedDebtorsList({super.key});

  @override
  DebtorsListState createState() => DebtorsListState();
}

class DebtorsListState extends State<SelectedDebtorsList> {
  @override
  void initState() {
    super.initState();
    loadDebtors();
  }

  void loadDebtors() {
    context.read<DebtorBloc>().add(LoadSelectedDebtors());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => loadDebtors(),
      child: BlocBuilder<DebtorBloc, DebtorState>(
        builder: (context, state) {
          print('emit qilngan $state');
          if (state is DebtorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DebtorLoaded) {
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.debtors.length,
              itemBuilder: (context, index) {
                final debtor = state.debtors[index];
                return DebtorCard(debtor: debtor);
              },
            );
          } else if (state is DebtorError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Ma\'lumot yo\'q'));
          }
        },
      ),
    );
  }
}
