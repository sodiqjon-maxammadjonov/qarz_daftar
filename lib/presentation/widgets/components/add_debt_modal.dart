import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/presentation/blocs/debtor/debtor_bloc.dart';
import '../../../config/themes.dart';

class AddDebtModal extends StatefulWidget {
  const AddDebtModal({Key? key}) : super(key: key);

  @override
  State<AddDebtModal> createState() => _AddDebtModalState();
}

class _AddDebtModalState extends State<AddDebtModal> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sumController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    sumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Yangi qarz qo'shish",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),

          // Form elementlarini qo'shing
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Ism",
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: sumController,
            decoration: const InputDecoration(
              hintText: "Summa",
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    double? amount = double.tryParse(sumController.text);
                    if (nameController.text.isNotEmpty && amount != null) {
                      // Add debtor event (Men qarzdorman)
                      context.read<DebtorBloc>().add(
                        AddDebtorEvent(nameController.text, amount, true),
                      );
                      Navigator.pop(context);
                      context.read<DebtorBloc>().add(
                        GetDebtorsEvent()
                      );

                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Iltimos, ism va summani kiriting")),
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text("Men qarzdorman"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.debtColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    double? amount = double.tryParse(sumController.text);
                    if (nameController.text.isNotEmpty && amount != null) {
                      // Add debtor event (Menga qarzdor)
                      context.read<DebtorBloc>().add(
                        AddDebtorEvent(nameController.text, amount, false),
                      );
                      Navigator.pop(context);
                      context.read<DebtorBloc>().add(
                          GetDebtorsEvent()
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Iltimos, ism va summani kiriting")),
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text("Menga qarzdor"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.creditColor,
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}