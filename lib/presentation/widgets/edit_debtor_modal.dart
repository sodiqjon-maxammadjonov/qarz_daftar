// edit_debtor_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/config/themes.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/presentation/blocs/debtor/debtor_bloc.dart';

class EditDebtorModal extends StatefulWidget {
  final Debtor debtor;

  const EditDebtorModal({Key? key, required this.debtor}) : super(key: key);

  @override
  State<EditDebtorModal> createState() => _EditDebtorModalState();
}

class _EditDebtorModalState extends State<EditDebtorModal> {
  late TextEditingController nameController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.debtor.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // viewInsets.bottom klaviaturaning balandligini aniqlab oladi
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      // Klaviatura balandligiga teng padding beramiz, modal ko'tarilishi uchun
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        // Aniq balandlik emas, o'zgaruvchan balandlik uchun wrap_content analog
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          minHeight: 200,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Modal o'z contentiga qarab kichrayadi
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag indicator - swipe bilan yopish uchun
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Text(
                  'Debtorni tahrirlash',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: nameController,
                  // autofocus: false qoldiramiz, modal ochilgandan so'ng fokus bo'lishini oldini oladi
                  autofocus: false,
                  decoration: const InputDecoration(
                    labelText: 'Ism',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Iltimos, ismni kiriting';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Klaviatura ochilganda ham buttonlar ko'rinishi uchun
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Bekor qilish'),
                    ),
                    const SizedBox(width: 12),
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _updateDebtor,
                      child: const Text('Saqlash'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateDebtor() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      await Future.delayed(Duration.zero);

      try {
        final name = nameController.text;
        final updatedDebtor = Debtor(
          id: widget.debtor.id,
          name: name,
          balance: widget.debtor.balance,
          isDebt: widget.debtor.isDebt,
        );

        if (mounted) {
          context.read<DebtorBloc>().add(UpdateDebtorEvent(updatedDebtor));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Xatolik yuz berdi: $e')),
          );
        }
      }
    }
  }
}