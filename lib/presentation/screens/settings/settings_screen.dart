import 'package:flutter/material.dart';

import '../../../config/themes.dart';

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