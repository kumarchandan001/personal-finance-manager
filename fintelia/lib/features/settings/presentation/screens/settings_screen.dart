/// FINTELIA — Settings Screen
library;
import 'package:fintelia/shared/providers/auth_provider.dart';
import 'package:fintelia/shared/providers/theme_provider.dart';
import 'package:fintelia/themes/app_colors.dart';
import 'package:fintelia/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // Appearance section
          _sectionHeader(theme, 'Appearance'),
          SwitchListTile(
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: Text(themeMode == ThemeMode.dark ? 'On' : (themeMode == ThemeMode.light ? 'Off' : 'System')),
            value: themeMode == ThemeMode.dark,
            onChanged: (v) => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          AppSpacing.verticalBase,

          // General section
          _sectionHeader(theme, 'General'),
          _settingsTile(theme, Icons.notifications_outlined, 'Notifications', 'Manage alerts & reminders', () {}),
          _settingsTile(theme, Icons.currency_exchange_rounded, 'Currency', 'INR (₹)', () {}),
          _settingsTile(theme, Icons.language_rounded, 'Language', 'English', () {}),
          AppSpacing.verticalBase,

          // Security section
          _sectionHeader(theme, 'Security'),
          _settingsTile(theme, Icons.lock_outline_rounded, 'Change Password', null, () {}),
          _settingsTile(theme, Icons.fingerprint_rounded, 'Biometric Login', null, () {}),
          _settingsTile(theme, Icons.shield_outlined, 'Privacy Settings', null, () {}),
          AppSpacing.verticalBase,

          // About section
          _sectionHeader(theme, 'About'),
          _settingsTile(theme, Icons.info_outline_rounded, 'About FINTELIA', 'v0.1.0', () {}),
          _settingsTile(theme, Icons.description_outlined, 'Terms of Service', null, () {}),
          _settingsTile(theme, Icons.privacy_tip_outlined, 'Privacy Policy', null, () {}),
          AppSpacing.verticalXl,

          // Sign out
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.expense),
              label: Text('Sign Out', style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.expense, fontWeight: FontWeight.w600)),
            ),
          ),
          AppSpacing.verticalXl,
        ],
      ),
    );
  }

  Widget _sectionHeader(ThemeData t, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(title, style: t.textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
  );

  Widget _settingsTile(ThemeData t, IconData icon, String title, String? subtitle, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: ListTile(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    ),
  );
}
