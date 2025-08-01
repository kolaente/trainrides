import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

enum ThemeMode { light, dark, system }

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeKey = 'theme_mode';

  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);

    if (themeString != null) {
      return ThemeMode.values.firstWhere(
        (mode) => mode.name == themeString,
        orElse: () => ThemeMode.system,
      );
    }

    return ThemeMode.system;
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
    state = AsyncValue.data(mode);
  }

  Future<void> toggleTheme() async {
    final currentState = await future;
    final newMode = currentState == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setTheme(newMode);
  }
}

class AppTheme {
  // Vibrant gradient color palette
  static const Color _color1 = Color(0xFFf72585); // Pink
  static const Color _color2 = Color(0xFFb5179e); // Purple pink
  static const Color _color3 = Color(0xFF7209b7); // Purple
  static const Color _color4 = Color(0xFF560bad); // Dark purple
  static const Color _color5 = Color(0xFF480ca8); // Darker purple
  static const Color _color6 = Color(0xFF3a0ca3); // Deep purple
  static const Color _color7 = Color(0xFF3f37c9); // Blue purple
  static const Color _color8 = Color(0xFF4361ee); // Blue
  static const Color _color9 = Color(0xFF4895ef); // Light blue
  static const Color _color10 = Color(0xFF4cc9f0); // Cyan

  static const Map<String, Color> typeColors = {
    'dark-blue': Color(0xFF1E3A8A),
    'light-pink': Color(0xFFFBBBBB),
    'darker-gray': Color(0xFF374151),
    'light-yellow': Color(0xFFFEF3C7),
    'darker-purple': Color(0xFF581C87),
    'light-blue': Color(0xFFBFDBFE),
  };

  static Color getColorForType(String? typeValue) {
    if (typeValue == null) return typeColors['dark-blue']!;

    switch (typeValue) {
      case 'DPSG Bund':
        return typeColors['dark-blue']!;
      case 'DPSG Sonstiges':
        return typeColors['light-pink']!;
      case 'Spaß':
        return typeColors['darker-gray']!;
      case 'Hannah besuchen':
        return typeColors['light-yellow']!;
      case 'WSJ':
        return typeColors['darker-purple']!;
      case 'Ironscout 26 Orga':
        return typeColors['light-blue']!;
      default:
        return typeColors['dark-blue']!;
    }
  }

  // Helper method to get appropriate text color for a background color
  static Color getTextColorForBackground(Color backgroundColor) {
    // Calculate the luminance to determine if we should use light or dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Helper method to parse color from hex string
  static Color parseColor(String? hex) {
    final v = (hex ?? '').replaceAll('#', '');
    if (v.length == 6) {
      return Color(int.parse('FF$v', radix: 16));
    }
    if (v.length == 8) {
      return Color(int.parse(v, radix: 16));
    }
    return const Color(0xFF4895EF);
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: _color8,
            brightness: Brightness.light,
          ).copyWith(
            primary: _color8,
            secondary: _color5,
            tertiary: _color2,
            surface: const Color(0xFFFAFAFA),
            surfaceVariant: const Color(0xFFF5F5F5),
          ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: CircleBorder(),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: _color8,
            brightness: Brightness.dark,
          ).copyWith(
            primary: _color8,
            secondary: _color5,
            tertiary: _color2,
            surface: const Color(0xFF1A1A1A),
            surfaceVariant: const Color(0xFF2D2D2D),
          ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: CircleBorder(),
      ),
    );
  }
}

extension ThemeModeExtension on ThemeMode {
  String get displayName {
    switch (this) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  IconData get icon {
    switch (this) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
