import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import '../../../config/themes.dart';

class DebtCard extends StatefulWidget {
  final Debtor debtor;
  final VoidCallback? onTap;

  const DebtCard({
    super.key,
    required this.debtor,
    this.onTap,
  });

  @override
  State<DebtCard> createState() => _DebtCardState();
}

class _DebtCardState extends State<DebtCard> {
  String formatBalance(double balance) {
    final formatter = NumberFormat("#,###", "uz_UZ");
    return formatter.format(balance);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar qismi
              CircleAvatar(
                radius: 24,
                backgroundColor: widget.debtor.isDebt
                    ? AppTheme.debtColor.withOpacity(0.2)
                    : AppTheme.creditColor.withOpacity(0.2),
                child: Icon(
                  widget.debtor.isDebt ? Icons.arrow_upward : Icons.arrow_downward,
                  color: widget.debtor.isDebt ? AppTheme.debtColor : AppTheme.creditColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 16),

              // Ma'lumotlar qismi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.debtor.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Summa qismi
              Text(
                '${widget.debtor.isDebt ? "-" : "+"} ${formatBalance(widget.debtor.balance)} UZS',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: widget.debtor.isDebt ? AppTheme.debtColor : AppTheme.creditColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
