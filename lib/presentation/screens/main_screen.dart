import 'package:flutter/material.dart';
import '../../config/themes.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Ekranlar ro'yxati
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: AppTheme.cardColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.lightTextColor,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Asosiy",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: "Sozlamalar",
            ),
          ],
        ),
      ),
    );
  }
}

// Asosiy ekran
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Qarz Daftari",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                IconButton(
                  onPressed: () {
                    // Yangi qarz qo'shish
                    _showAddDebtDialog(context);
                  },
                  icon: Icon(
                    Icons.add_circle,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Umumiy balans kartasi
            _buildBalanceCard(context),

            const SizedBox(height: 24),

            // So'nggi qarzlar ro'yxati
            Text(
              "So'nggi qarzlar",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _buildRecentDebtsList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppTheme.primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Umumiy balans",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "1,250,000 UZS",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBalanceItem(
                  context,
                  "Siz qarzdorsiz",
                  "250,000 UZS",
                  AppTheme.debtColor,
                  Icons.arrow_upward,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: AppTheme.lightTextColor.withOpacity(0.2),
                ),
                _buildBalanceItem(
                  context,
                  "Sizga qarzdor",
                  "1,500,000 UZS",
                  AppTheme.creditColor,
                  Icons.arrow_downward,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(
      BuildContext context,
      String title,
      String amount,
      Color color,
      IconData icon,
      ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDebtsList(BuildContext context) {
    // Ma'lumotlar ro'yxati (haqiqiy ilovada bazadan olinadi)
    final dummyDebts = [
      {
        'name': 'Abdulloh Ahmadov',
        'amount': '500,000',
        'date': '15.02.2025',
        'isDebt': false, // false = sizga qarzdor
      },
      {
        'name': 'Sardor Karimov',
        'amount': '250,000',
        'date': '10.02.2025',
        'isDebt': true, // true = siz qarzdorsiz
      },
      {
        'name': 'Dilshod Toshmatov',
        'amount': '1,000,000',
        'date': '05.02.2025',
        'isDebt': false,
      },
    ];

    return ListView.builder(
      itemCount: dummyDebts.length,
      itemBuilder: (context, index) {
        final debt = dummyDebts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: debt['isDebt'] == true
                  ? AppTheme.debtColor.withOpacity(0.2)
                  : AppTheme.creditColor.withOpacity(0.2),
              child: Icon(
                debt['isDebt'] == true ? Icons.arrow_upward : Icons.arrow_downward,
                color: debt['isDebt'] == true ? AppTheme.debtColor : AppTheme.creditColor,
              ),
            ),
            title: Text(
              debt['name'].toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: Text(
              debt['date'].toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Text(
              '${debt['isDebt'] == true ? "-" : "+"} ${debt['amount']!} UZS',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: debt['isDebt'] == true ? AppTheme.debtColor : AppTheme.creditColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // Batafsil ma'lumotlarni ko'rsatish
            },
          ),
        );
      },
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              decoration: const InputDecoration(
                hintText: "Ism",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
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
                    onPressed: () {},
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
                    onPressed: () {},
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
      ),
    );
  }
}

// Sozlamalar ekrani
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sozlamalar",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSettingsItem(
                    context,
                    "Profil",
                    "Shaxsiy ma'lumotlaringizni o'zgartirish",
                    Icons.person_outline,
                        () {},
                  ),
                  const Divider(),
                  _buildSettingsItem(
                    context,
                    "Xabarnomalar",
                    "Xabarnoma sozlamalari",
                    Icons.notifications_outlined,
                        () {},
                  ),
                  const Divider(),
                  _buildSettingsItem(
                    context,
                    "Ma'lumotlar eksporti",
                    "Barcha ma'lumotlarni eksport qilish",
                    Icons.download_outlined,
                        () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSettingsItem(
                    context,
                    "Yordam",
                    "Ko'p so'raladigan savollar",
                    Icons.help_outline,
                        () {},
                  ),
                  const Divider(),
                  _buildSettingsItem(
                    context,
                    "Biz haqimizda",
                    "Ilova haqida ma'lumot",
                    Icons.info_outline,
                        () {},
                  ),
                ],
              ),
            ),

            const Spacer(),

            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout),
                label: const Text("Chiqish"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.lightTextColor,
      ),
      onTap: onTap,
    );
  }
}