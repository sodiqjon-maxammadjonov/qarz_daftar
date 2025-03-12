import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/service/balance_service.dart';
import '../../../presentation/bloc/debtor/debtor_bloc.dart';
import 'number_text.dart';
class BalanceCard extends StatefulWidget {
  final bool isCheckedOnly;

  const BalanceCard({super.key, required this.isCheckedOnly});

  @override
  _BalanceCardState createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  final BalanceService _balanceService = BalanceService(); // BalanceService ni ishlatish

  Map<String, double> _balances = {
    'totalNegativeBalanceUZS': 0.0,
    'totalPositiveBalanceUZS': 0.0,
    'totalBalanceUZS': 0.0,
    'totalNegativeBalanceUSD': 0.0,
    'totalPositiveBalanceUSD': 0.0,
    'totalBalanceUSD': 0.0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBalances();
  }

  @override
  void didUpdateWidget(covariant BalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCheckedOnly != widget.isCheckedOnly) {
      _fetchBalances();
    }
  }

  Future<void> _fetchBalances() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final balances = widget.isCheckedOnly
          ? await _balanceService.calculateCheckedBalances()
          : await _balanceService.calculateTotalBalances();

      setState(() {
        _balances = balances;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Xatolik sodir bo'lsa, UI da xabar ko'rsatish mumkin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Balanslarni yuklashda xatolik: $e")),
      );
    }

    // Debtorlar ro'yxatini yuklash (UI refresh qilish uchun)
    context.read<DebtorBloc>().add(
        widget.isCheckedOnly ? LoadSelectedDebtors() : LoadDebtorsEvent()
    );
  }

  Color _getBalanceColor(double amount) {
    if (amount < 0) return Colors.red;
    if (amount > 0) return Colors.green;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Balanslar (UZS / USD)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _fetchBalances,
                icon: const Icon(Icons.refresh, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              _balanceRow("Jami balans", _balances['totalBalanceUZS'] ?? 0.0,
                  _balances['totalBalanceUSD'] ?? 0.0),
              _balanceRow("Musbat balans",
                  _balances['totalPositiveBalanceUZS'] ?? 0.0,
                  _balances['totalPositiveBalanceUSD'] ?? 0.0),
              _balanceRow("Manfiy balans",
                  _balances['totalNegativeBalanceUZS'] ?? 0.0,
                  _balances['totalNegativeBalanceUSD'] ?? 0.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceRow(String title, double uzs, double usd) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Row(
            children: [
              NumberText(
                number: uzs.toInt(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getBalanceColor(uzs),
                ),
              ),
              const Text(" UZS / "),
              NumberText(
                number: usd.toInt(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getBalanceColor(usd),
                ),
              ),
              const Text(" USD"),
            ],
          ),
        ],
      ),
    );
  }
}