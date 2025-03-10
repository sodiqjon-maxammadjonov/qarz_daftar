import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qarz_daftar/config/themes.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/presentation/blocs/debtor/debtor_bloc.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../widgets/components/debtors_list.dart';
import '../../widgets/components/selected_balance_card.dart';
import '../../widgets/empty.dart';
import '../../widgets/loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Debtor> _selectedDebtors = [];

  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebtorBloc>().add(LoadDebtorsEvent());
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      context.read<DebtorBloc>().add(
        LoadDebtorsEvent(searchQuery: _searchController.text),
      );
    } else {
      context.read<DebtorBloc>().add(LoadDebtorsEvent());
    }
  }

  Future<void> _refreshDebtors() async {
    context.read<DebtorBloc>().add(LoadDebtorsEvent(searchQuery: _isSearchMode ? _searchController.text : null));
    // Yangilanganda tanlangan debitorlar ro'yxatini tozalash
    setState(() {
      _selectedDebtors = [];
    });
  }

  void _onSelectionChanged(List<Debtor> selectedDebtors) {
    setState(() {
      _selectedDebtors = selectedDebtors;
    });
  }

  void _toggleSearchMode() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (!_isSearchMode) {
        _searchController.clear();
        context.read<DebtorBloc>().add(LoadDebtorsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tanlanadiganlar uchun balans karti
            BlocBuilder<DebtorBloc, DebtorState>(
              builder: (context, state) {
                if (state is DebtorsLoaded) {
                  return SelectableBalanceCard(
                    allDebtors: state.debtors,
                    selectedDebtors: _selectedDebtors,
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ro'yhat",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                if (_selectedDebtors.isNotEmpty)
                  Text(
                    "Tanlangan: ${_selectedDebtors.length}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshDebtors,
                child: BlocBuilder<DebtorBloc, DebtorState>(
                  builder: (context, state) {
                    if (state is DebtorLoading) {
                      return const Loading();
                    } else if (state is DebtorsLoaded) {
                      if (state.debtors.isEmpty) {
                        return _isSearchMode
                            ? const Center(
                          child: Text("Qidiruv bo'yicha ma'lumot topilmadi"),
                        )
                            : const Empty();
                      } else {
                        return DebtorsList(
                          debtors: state.debtors,
                          onSelectionChanged: _onSelectionChanged,
                        );
                      }
                    } else if (state is DebtorError) {
                      return Center(
                        child: Text(
                          "Xatolik: ${state.message}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text("Ma'lumot yo'q"),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return _isSearchMode
        ? AppBar(
      title: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Qidirish...',
          border: InputBorder.none,
        ),
        autofocus: true,
        style: const TextStyle(fontSize: 18),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _toggleSearchMode,
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          ),
      ],
    )
        : AppBar(
      title: const Text('Qarz Daftari'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _toggleSearchMode,
        ),
        IconButton(
          onPressed: () {
            _showAddDebtorDialog(context);
          },
          icon: const Icon(CupertinoIcons.add),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showAddDebtorDialog(BuildContext context) {
    String name = '';
    double amount = 0.0;
    bool isDebt = true;

    // TextEditingController yaratish
    final amountController = TextEditingController();

    // Raqamlarni formatlash uchun NumberFormat
    final numberFormat = NumberFormat("#,##0", "uz_UZ");

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // amountControllerga listener qo'shish
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

    showDialog(
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
                    Icons.account_balance_wallet,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Yangi qarz qo\'shish',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Qarz ma\'lumotlarini kiriting:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Ism',
                          hintText: 'Qarzdor ismini kiriting',
                          prefixIcon: const Icon(Icons.person),
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
                        onChanged: (value) => name = value,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: amountController, // amountControllerni ulaymiz
                        decoration: InputDecoration(
                          labelText: 'Summa',
                          hintText: 'Qarz summasini kiriting',
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
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9), // Maksimal uzunlik - 9 ta belgi
                        ],
                        maxLength: 9,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        onChanged: (value) {
                          // tozalangan qiymatni amountga yuklaymiz
                          String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                          amount = double.tryParse(cleanValue) ?? 0.0;
                        },
                      ),
                      const SizedBox(height: 28),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                                const Text(
                                  'Men Qarzdorman',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
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
                        if (name.isNotEmpty && amount > 0) {
                          // isDebt qiymatini to'g'rilash
                          context.read<DebtorBloc>().add(
                            AddDebtorEvent(
                              name: name,
                              amount: amount,
                              isDebt: !isDebt,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Qarz muvaffaqiyatli saqlandi!'),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Iltimos, ism va summani kiriting.'),
                              backgroundColor: Colors.red.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Saqlash'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
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
}