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
  final bool isSelectionMode;
  final bool isSelected;

  const DebtorCard({
    super.key,
    required this.debtor,
    this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  String formatNumber(double number) {
    final formatter = NumberFormat("#,##0", "uz_UZ");
    if (number > 0) {
      return "+${formatter.format(number)}"; // Ijobiy bo'lsa + qo'shamiz
    } else if (number < 0) {
      return formatter.format(number); // Manfiy bo'lsa hech narsa qo'shmaymiz (manfiy ishora avtomatik qo'shiladi)
    } else {
      return formatter.format(number); // Nolga teng bo'lsa
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          leading: isSelectionMode
              ? Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              if (onTap != null) onTap!();
            },
          )
              : null,
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
                "${formatNumber(debtor.balance)} UZS", // debtor.balance dan foydalanamiz
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: debtor.isDebt ? AppTheme.debtColor : AppTheme.creditColor,
                ),
              ),
            ],
          ),
          trailing: isSelectionMode
              ? null
              : PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String result) {
              if (result == 'tahrirlash') {
                _showEditDebtorModal(context, debtor);
              } else if (result == 'ochirish') {
                _showDeleteConfirmationDialog(context, debtor);
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

  void _showDeleteConfirmationDialog(BuildContext context, Debtor debtor) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth * 0.8;

            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red[700],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text('O\'chirishni tasdiqlang'),
                ],
              ),
              content: SizedBox(
                width: maxWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rostdan ham "${debtor.name}" ni o\'chirmoqchimisiz?'),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.red[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                debtor.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                debtor.isDebt ? Icons.arrow_upward : Icons.arrow_downward,
                                color: debtor.isDebt ? Colors.red[700] : Colors.green[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${formatNumber(debtor.balance)} so\'m', // formatNumberni debtor.balanceni берdik
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: debtor.isDebt ? Colors.red[700] : Colors.green[700],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${debtor.isDebt ? 'Men qarzdorman' : 'Menga qarzdor'})',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Diqqat! Bu amaliyot qaytarib bo\'lmaydi.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Bekor qilish'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Future.microtask(() {
                          context.read<DebtorBloc>().add(DeleteDebtorEvent(debtor.id));
                          _showDeleteSuccessSnackBar(context, debtor.name);
                        });
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('O\'chirish'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteSuccessSnackBar(BuildContext context, String debtorName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$debtorName muvaffaqiyatli o\'chirildi'),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}