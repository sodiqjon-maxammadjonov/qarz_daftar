import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/core/models/transaction.dart';
import 'package:qarz_daftar/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:qarz_daftar/data/services/debtor_service.dart';
import '../../widgets/components/monthly_transactions_list.dart';

class TransactionsScreen extends StatefulWidget {
  final Debtor debtor;

  const TransactionsScreen({Key? key, required this.debtor}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Debtor _currentDebtor;
  final _debtorService = DebtorService();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'uz_UZ',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _currentDebtor = widget.debtor;
    _loadTransactions();
  }

  void _loadTransactions() {
    context.read<TransactionBloc>().add(LoadTransactions(debtorId: _currentDebtor.id));
    _refreshDebtorData();
  }

  Future<void> _refreshDebtorData() async {
    try {
      final updatedDebtor = await _debtorService.getDebtorById(_currentDebtor.id);
      setState(() {
        _currentDebtor = updatedDebtor;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debtor ma\'lumotlarini yangilashda xatolik: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentDebtor.name),
            Row(
              children: [
                Text(
                  '${_currencyFormat.format(_currentDebtor.balance)} so\'m',
                  style: TextStyle(
                    fontSize: 14,
                    color: _currentDebtor.isDebt ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _currentDebtor.isDebt ? '(Menga qarzdor)' : '(Men qarzdorman)', // to'g'ri yozuv
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: _currentDebtor.isDebt ? Colors.red[200] : Colors.green[200],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadTransactions();
        },
        child: BlocConsumer<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransactionAdded || state is TransactionUpdated) {
              _refreshDebtorData();
            }
          },
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionsLoaded) {
              if (state.monthlyTransactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Tranzaksiyalar mavjud emas',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Tranzaksiya qo\'shish'),
                        onPressed: () => _showAddTransactionDialog(context),
                      ),
                    ],
                  ),
                );
              }
              return _buildMonthlyTransactionList(state.monthlyTransactions, context);
            } else if (state is TransactionError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Xatolik: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Qayta yuklash'),
                      onPressed: _loadTransactions,
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Kutilmagan holat'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildMonthlyTransactionList(Map<String, List<Transactions>> monthlyTransactions, BuildContext context) {
    if (monthlyTransactions.isEmpty) {
      return const Center(child: Text('Tranzaksiyalar mavjud emas'));
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: monthlyTransactions.length,
      itemBuilder: (context, index) {
        String monthYear = monthlyTransactions.keys.elementAt(index);
        List<Transactions> transactions = monthlyTransactions[monthYear]!;

        return MonthlyTransactionList(
          monthYear: monthYear,
          transactions: transactions,
          onDelete: (transaction) async {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Tranzaksiyani o\'chirish'),
                content: const Text('Siz rostdan ham bu tranzaksiyani o\'chirmoqchimisiz?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Yo\'q'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Ha'),
                  ),
                ],
              ),
            ) ?? false;

            if (shouldDelete) {
              context.read<TransactionBloc>().add(DeleteTransaction(
                transactionId: transaction.id,
                debtorId: transaction.debtorId,
              ));
            }
          },
          onEdit: (transaction) => _showEditTransactionDialog(context, transaction),
        );
      },
    );
  }

  Future<void> _showAddTransactionDialog(BuildContext context) async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isDebt = true;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final numberFormat = NumberFormat("#,##0", "uz_UZ");
    amountController.addListener(() {
      String value = amountController.text;
      // Agar kiritilgan qiymat bo'sh bo'lmasa, formatlash
      if (value.isNotEmpty) {
        // Raqamlarni olib tashlash (agar formatlangan bo'lsa)
        String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
        double parsedValue = double.tryParse(cleanValue) ?? 0.0;
        // Formatlangan qiymatni olish
        String formattedValue = numberFormat.format(parsedValue);
        // TextEditingControllerga formatlangan qiymatni yuklash
        amountController.value = amountController.value.copyWith(
          text: formattedValue,
          selection: TextSelection.collapsed(offset: formattedValue.length),
        );
      }
    });
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tranzaksiya qo\'shish',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tranzaksiya ma\'lumotlarini kiriting:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Miqdor kiritish maydoni
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9), // Maksimal uzunlik - 9 ta belgi
                      ],
                      maxLength: 9,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      decoration: InputDecoration(
                        labelText: 'Miqdor',
                        hintText: 'Tranzaksiya miqdorini kiriting',
                        prefixIcon: const Icon(Icons.money),
                        suffixText: 'so\'m',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (value) {
                        String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                      },
                    ),
                    const SizedBox(height: 20),

                    // Izoh kiritish maydoni
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Izoh',
                        hintText: 'Tranzaksiya izohini kiriting',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 28),

                    // Qarzdorlik turi
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Men Qarzdorman' ,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Switch(
                            value: isDebt,
                            activeColor: colorScheme.primary,
                            onChanged: (bool? value) {
                              setState(() {
                                isDebt = value ?? true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Bekor qilish'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Miqdorni olish va tekshirish
                        final amountText = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
                        final amount = double.tryParse(amountText);
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Iltimos, miqdorni kiriting.')),
                          );
                          return;
                        }

                        // Tranzaksiya qo'shish
                        context.read<TransactionBloc>().add(
                          AddTransaction(
                            debtorId: _currentDebtor.id,
                            amount: amount,
                            isDebt: !isDebt,
                            description: descriptionController.text ?? 'Yangi tranzaksiya',
                          ),
                        );

                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Saqlash'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
  Future<void> _showEditTransactionDialog(BuildContext context, Transactions transaction) async {
    // TextEditingController va boshlang'ich qiymatlarni o'rnatish
    final amountController = TextEditingController(text: transaction.amount.toString());
    final descriptionController = TextEditingController(text: transaction.description);

    // Switch uchun boshlang'ich qiymat - default holati true
    bool isDebt = transaction.isDebt;

    // Valyuta formatlash uchun NumberFormat
    final NumberFormat currencyFormat = NumberFormat("#,##0", "uz_UZ");

    // Miqdor kiritish maydonidagi qiymatni formatlash
    void _formatAmount() {
      String value = amountController.text;
      if (value.isEmpty) return;

      // Faqat raqamlarni ajratib olish
      String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanValue.isEmpty) {
        amountController.text = '';
        return;
      }

      // Raqamni double formatiga o'tkazish
      double parsedValue = double.tryParse(cleanValue) ?? 0;

      // Formatlangan qiymatni olish
      String formattedValue = currencyFormat.format(parsedValue);

      // TextEditingController'ga qiymatni o'rnatish
      amountController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }

    // TextEditingController'ga formatlovchi listener qo'shish
    amountController.addListener(_formatAmount);

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Tranzaksiyani tahrirlash'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Miqdor',
                        prefixIcon: Icon(Icons.money),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Izoh',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        isDebt ? 'Menga qarzdor' : 'Men qarzdorman',
                        style: TextStyle(
                          color: isDebt ? Colors.red : Colors.green,
                        ),
                      ),
                      value: isDebt,
                      activeColor: Colors.red,
                      inactiveThumbColor: Colors.green,
                      inactiveTrackColor: Colors.green.withOpacity(0.5),
                      onChanged: (bool? value) {
                        setState(() {
                          isDebt = value ?? true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Bekor qilish'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Saqlash'),
                  onPressed: () {
                    // Miqdorni tozalab olish
                    final amountText = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
                    final amount = double.tryParse(amountText);

                    // Miqdor validatsiyasi
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Iltimos to\'g\'ri miqdor kiriting')),
                      );
                      return;
                    }

                    // Yangilangan tranzaksiya obyektini yaratish
                    final updatedTransaction = Transactions(
                      id: transaction.id,
                      debtorId: transaction.debtorId,
                      amount: amount,
                      date: transaction.date,
                      description: descriptionController.text.isEmpty
                          ? 'Tahrirlandi ' : descriptionController.text,
                      isDebt: isDebt,
                    );

                    // Blokga yangilash hodisasini yuborish
                    context.read<TransactionBloc>().add(
                      UpdateTransaction(transaction: updatedTransaction),
                    );

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}