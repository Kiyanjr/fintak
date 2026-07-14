import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../widgets/profile_card.dart';
import '../widgets/settings_row.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state so UI rebuilds when anything changes
    final settingsState = ref.watch(settingsViewModelProvider);
    // Read notifier for calling methods — no rebuild needed here
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Show spinner while loading user data from SharedPreferences
    if (settingsState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 90),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Page title ──────────────────────────
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Profile card ─────────────────────────
                // Shows user name, email, initials avatar, pro badge
                ProfileCard(
                  name: settingsState.userName,
                  email: settingsState.userEmail,
                ),

                const SizedBox(height: 24),

                // ── Preferences section ──────────────────
                _buildSectionLabel('Preferences', context),

                // Dark mode toggle — switches entire app theme
                SettingsRow(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark mode',
                  trailing: AppToggle(
                    value: settingsState.isDarkMode,
                    // Pass ref so viewmodel can update appStateProvider globally
                    onChanged: (_) => viewModel.toggleDarkMode(ref),
                  ),
                ),

                // Notifications toggle — local state only for now
                SettingsRow(
                  icon: Icons.notifications_rounded,
                  label: 'Notifications',
                  trailing: AppToggle(
                    value: settingsState.notificationsEnabled,
                    onChanged: (_) => viewModel.toggleNotifications(),
                  ),
                ),

                // Currency picker — opens bottom sheet
                SettingsRow(
                  icon: Icons.currency_exchange_rounded,
                  label: 'Currency',
                  onTap: () => _showCurrencyPicker(context, ref),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Shows currently selected currency code
                      Text(
                        settingsState.selectedCurrency,
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: onSurface.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Security section ─────────────────────
                _buildSectionLabel('Security', context),

                // Biometric toggle — local state only for now
                SettingsRow(
                  icon: Icons.fingerprint_rounded,
                  label: 'Biometric login',
                  trailing: AppToggle(
                    value: settingsState.biometricEnabled,
                    onChanged: (_) => viewModel.toggleBiometric(),
                  ),
                ),

                // Change password — placeholder for now
                SettingsRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change password',
                  onTap: () {},
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: onSurface.withOpacity(0.3),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Account section ──────────────────────
                _buildSectionLabel('Account', context),

                // Export data — placeholder for now
                SettingsRow(
                  icon: Icons.download_rounded,
                  label: 'Export data',
                  onTap: () {},
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: onSurface.withOpacity(0.3),
                  ),
                ),

                // Help & support — placeholder for now
                SettingsRow(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & support',
                  onTap: () {},
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: onSurface.withOpacity(0.3),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Sign out button ──────────────────────
                // Red styled — always confirm before signing out
                GestureDetector(
                  onTap: () => _confirmSignOut(context, ref),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.redSoft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.red.withOpacity(0.2),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Sign out',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section label helper ─────────────────────
  // Reused for every section header — Preferences, Security, Account
  Widget _buildSectionLabel(String label, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          // Muted color to look like a section divider label
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }

  // ── Sign out confirmation dialog ─────────────
  // Never sign out immediately — always ask first
  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in again to access your account.',
        ),
        actions: [
          // Cancel — close dialog, do nothing
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          // Confirm — sign out then router auto-redirects to /login
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(settingsViewModelProvider.notifier).signOut(ref);
            },
            child: const Text(
              'Sign out',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Currency picker bottom sheet ─────────────
  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    // Supported currencies list
    final currencies = ['USD', 'EUR', 'GBP', 'AED', 'Toman'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final onSurface = Theme.of(context).colorScheme.onSurface;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet title
              Text(
                'Select Currency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),

              const SizedBox(height: 16),

              // Map each currency to a tappable row
              ...currencies.map((currency) {
                // Check if this currency is currently selected
                final isSelected =
                    ref.read(settingsViewModelProvider).selectedCurrency ==
                        currency;

                return GestureDetector(
                  onTap: () {
                    // Update selected currency in viewmodel
                    ref
                        .read(settingsViewModelProvider.notifier)
                        .updateCurrency(currency);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      // Highlight selected currency with accent background
                      color: isSelected
                          ? AppColors.accent.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            currency,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: onSurface,
                            ),
                          ),
                        ),
                        // Checkmark only on selected currency
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            color: AppColors.accent,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}