import 'package:flutter/material.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/presentation/screens/home/transactions_screen.dart';
import 'package:qarz_daftar/presentation/widgets/components/debtor_card.dart';

class DebtorsList extends StatefulWidget {
  final List<Debtor> debtors;
  final Function(List<Debtor>) onSelectionChanged;

  const DebtorsList({
    Key? key,
    required this.debtors,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<DebtorsList> createState() => _DebtorsListState();
}

class _DebtorsListState extends State<DebtorsList> {
  bool _isSelectionMode = false;
  final Set<String> _selectedDebtorIds = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isSelectionMode)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanlangan: ${_selectedDebtorIds.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _selectAll,
                      child: const Text('Barchasini tanlash'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _cancelSelection,
                      child: const Text('Bekor qilish'),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Debtorlar ro'yxati
        Expanded(
          child: ListView.builder(
            itemCount: widget.debtors.length,
            itemBuilder: (context, index) {
              final debtor = widget.debtors[index];
              return GestureDetector(

                onLongPress: () {
                  if (!_isSelectionMode) {
                    _startSelectionMode(debtor.id);
                  }
                },
                child: DebtorCard(
                  debtor: debtor,
                  isSelectionMode: _isSelectionMode,
                  isSelected: _selectedDebtorIds.contains(debtor.id),
                  onTap: () {
                    if (_isSelectionMode) {
                      _toggleSelection(debtor.id);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionsScreen(debtor: debtor),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _startSelectionMode(String debtorId) {
    setState(() {
      _isSelectionMode = true;
      _selectedDebtorIds.add(debtorId);
      _notifySelectionChanged();
    });
  }

  void _toggleSelection(String debtorId) {
    setState(() {
      if (_selectedDebtorIds.contains(debtorId)) {
        _selectedDebtorIds.remove(debtorId);
      } else {
        _selectedDebtorIds.add(debtorId);
      }

      if (_selectedDebtorIds.isEmpty) {
        _isSelectionMode = false;
      }

      _notifySelectionChanged();
    });
  }

  void _selectAll() {
    setState(() {
      _selectedDebtorIds.clear();
      for (var debtor in widget.debtors) {
        _selectedDebtorIds.add(debtor.id);
      }
      _notifySelectionChanged();
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedDebtorIds.clear();
      _notifySelectionChanged();
    });
  }

  void _notifySelectionChanged() {
    // Tanlangan debtorlar ro'yxatini qaytarish
    final selectedDebtors = widget.debtors
        .where((d) => _selectedDebtorIds.contains(d.id))
        .toList();

    widget.onSelectionChanged(selectedDebtors);
  }
}