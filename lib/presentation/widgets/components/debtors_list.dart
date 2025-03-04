import 'package:flutter/material.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/presentation/widgets/debd_card.dart';

class DebtorsList extends StatelessWidget {
  final List<Debtor> debtor;
  final ScrollController? scrollController;
  const DebtorsList({super.key, required this.debtor, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: debtor.length,
      itemBuilder: (context, index) {
        return DebtCard(debtor: debtor[index]);
      },
    );
  }
}
