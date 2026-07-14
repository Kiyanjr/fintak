import 'package:fintak/core/providers/app_providers.dart';
import 'package:fintak/data/datasources/local_datasource.dart';
import 'package:fintak/features/auth/viewmodels/auth_viewmodel.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class SettingsState {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final String selectedCurrency;
  final String userName;
  final String userEmail;
  final double monthlyBudget;
  final bool isLoading;

  SettingsState({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.selectedCurrency = 'USD',
    this.userName = '',
    this.userEmail = '',
    this.monthlyBudget = 0.0,
    this.isLoading = false,
  });
  SettingsState copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    String? selectedCurrency,
    String? userName,
    String? userEmail,
    double? monthlyBudget,
    bool? isLoading,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsViewmodel extends StateNotifier<SettingsState> {
  final LocalDatasource _localDataSource;
  SettingsViewmodel(this._localDataSource) : super(SettingsState()) {
    loadSettings();
  }

  // Load user data and theme settings from local storage
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _localDataSource.getUser();
      final isDark = await _localDataSource.getTheme();
      // updating the state
      state = state.copyWith(
        userName: user?.name ?? '',
        userEmail: user?.email ?? '',
        monthlyBudget: user?.monthlyBudget ?? 0.0,
        isDarkMode: isDark,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
     // Toggle dark mode and notify appStateProvider to update UI globally
  Future<void> toggleDarkMode(WidgetRef ref) async {
    final newValue = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newValue);
    await _localDataSource.saveTheme(newValue);
    ref.read(appStateProvider.notifier).toggleTheme();
  }
  // Toggle local notification setting
  void toggleNotifications(){
    //no persistence needed for now since we don't have real push notifications
    state=state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }
  // Toggle local biometric which is enable for now
  void toggleBiometric(){
    state=state.copyWith(biometricEnabled: !state.biometricEnabled);
  }
  Future <void> signOut(WidgetRef ref)async{
    await ref.read(authViewModelProvider.notifier).signOut(ref);
    //No navigation needed — the router detects currentUserId is null and automatically redirects to /login
  }
  // Updates selected currency in state
// Persistence can be added to LocalDataSource later
Future<void> updateCurrency(String currency) async {
  state = state.copyWith(selectedCurrency: currency);
}
}

 // Provider Definition
 final settingsViewModelProvider=StateNotifierProvider<SettingsViewmodel,SettingsState>((ref){
 final datasource=ref.watch(localDataSourceProvider).requireValue;
 return SettingsViewmodel(datasource);
 });