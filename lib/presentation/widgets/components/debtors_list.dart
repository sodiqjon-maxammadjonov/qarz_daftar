import 'package:flutter/material.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/presentation/widgets/components/debtor_card.dart';

class DebtorsList extends StatelessWidget {
  final List<Debtor> debtors;

  const DebtorsList({Key? key, required this.debtors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: debtors.length,
      itemBuilder: (context, index) {
        final debtor = debtors[index];
        return DebtorCard(debtor: debtor,onTap: (){},);
      },
    );
  }
}