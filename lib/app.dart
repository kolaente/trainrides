import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart' as theme_provider;
import 'presentation/screens/auth/auth_screen.dart';
import 'presentation/screens/home/home_screen.dart';

class TrainRidesApp extends ConsumerWidget {
  const TrainRidesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(theme_provider.themeNotifierProvider);
    final authAsync = ref.watch(authNotifierProvider);

    return themeAsync.when(
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $error'),
          ),
        ),
      ),
      data: (themeMode) => MaterialApp(
        title: 'Train Rides',
        theme: theme_provider.AppTheme.lightTheme,
        darkTheme: theme_provider.AppTheme.darkTheme,
        themeMode: _getThemeMode(themeMode),
        home: authAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${error.toString()}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(authNotifierProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (authState) {
            if (authState.isAuthenticated) {
              return const HomeScreen();
            } else {
              return const AuthScreen();
            }
          },
        ),
      ),
    );
  }

  ThemeMode _getThemeMode(theme_provider.ThemeMode themeMode) {
    switch (themeMode) {
      case theme_provider.ThemeMode.light:
        return ThemeMode.light;
      case theme_provider.ThemeMode.dark:
        return ThemeMode.dark;
      case theme_provider.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}