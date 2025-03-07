import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/config/themes.dart';
import 'package:qarz_daftar/presentation/blocs/debtor/debtor_bloc.dart';
import 'package:qarz_daftar/presentation/widgets/edit_debtor_modal.dart';

class DebtorCard extends StatelessWidget {
  final Debtor debtor;
  final VoidCallback? onTap;

  const DebtorCard({super.key, required this.debtor, this.onTap});
  String formatNumber(double number) {
    final formatter = NumberFormat.currency(locale: 'uz_UZ', symbol: '', decimalDigits: 0);
    return formatter.format(number);
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell( // InkWell ga wrap qilamiz
        onTap: onTap, // Berilgan onTap funksiyasini chaqiramiz
        borderRadius: BorderRadius.circular(12), // Cardning burchaklari bilan bir xil
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          title: Text(
            debtor.name,
            style: Theme.of(context).textTheme.headlineMedium,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Balans: ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400,
                ),
              ),
              Text(
                " ${formatNumber(debtor.signedBalance)} UZS",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: debtor.isDebt ? AppTheme.debtColor : AppTheme.creditColor,
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String result) {
              if (result == 'tahrirlash') {
                _showEditDebtorModal(context, debtor);
              } else if (result == 'ochirish') {
                _showDeleteConfirmationDialog(context, debtor.id);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'tahrirlash',
                child: Text('Tahrirlash'),
              ),
              const PopupMenuItem<String>(
                value: 'ochirish',
                child: Text('O\'chirish'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDebtorModal(BuildContext context, Debtor debtor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: BlocProvider.of<DebtorBloc>(context),
          child: EditDebtorModal(debtor: debtor),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String debtorId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('O\'chirishni tasdiqlang'),
          content: Text('Rostdan ham ${debtor.name} o\'chirmoqchimisiz?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Future.microtask(() {
                  context.read<DebtorBloc>().add(DeleteDebtorEvent(debtorId));
                });
                Navigator.of(context).pop();
              },
              child: const Text('O\'chirish'),
            ),
          ],
        );
      },
    );
  }
}