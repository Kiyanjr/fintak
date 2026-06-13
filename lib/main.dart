import 'package:fintak/core/constants/app_colors.dart';
import 'package:fintak/core/providers/app_providers.dart';
import 'package:fintak/core/router/app_router.dart';
import 'package:fintak/data/datasources/local_datasource.dart';
import 'package:fintak/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ProviderScope(
      child: FintrakApp(),
    ),
  );
}

class FintrakApp extends ConsumerWidget {
  const FintrakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDatasource = ref.watch(localDataSourceProvider);
final router = ref.watch(appRouterProvider);
    return asyncDatasource.when(
      loading: () {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
              ),
            ),
          ),
        );
      },
      error: (error, stack) {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Initialization error'),
            ),
          ),
        );
      },
      data: (_) {
        final state = ref.watch(appStateProvider);

        return MaterialApp.router(
          routerConfig: router,
          title: 'Fintrak',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: state.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
        );
      },
    );
  }
}