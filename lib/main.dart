import 'package:flutter/material.dart';
import 'controllers/game_controller.dart';
import 'controllers/game_scope.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BuddyFightLifeCounterApp());
}

class BuddyFightLifeCounterApp extends StatefulWidget {
  const BuddyFightLifeCounterApp({super.key});

  @override
  State<BuddyFightLifeCounterApp> createState() => _BuddyFightLifeCounterAppState();
}

class _BuddyFightLifeCounterAppState extends State<BuddyFightLifeCounterApp> {
  final GameController _gameController = GameController();

  ThemeData _buildTheme(String themeMode) {
    if (themeMode == 'dark') {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF388AF6),
          secondary: Color(0xFF00C853),
          surface: Color(0xFF1E1E1E),
          onSurface: Color(0xFFEDEDED),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Color(0xFFEDEDED),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2C2C2C),
          thickness: 1,
        ),
      );
    } else if (themeMode == 'gray') {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF2F3640),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A90E2),
          secondary: Color(0xFF2ECC71),
          surface: Color(0xFF38414E),
          onSurface: Color(0xFFF5F6FA),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2F3640),
          foregroundColor: Color(0xFFF5F6FA),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF38414E),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF38414E),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF475364),
          thickness: 1,
        ),
      );
    } else {
      // Clean Minimalist Light theme
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF10B981),
          surface: Colors.white,
          onSurface: Color(0xFF1E293B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F9FA),
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE2E8F0),
          thickness: 1,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameScope(
      controller: _gameController,
      child: ListenableBuilder(
        listenable: _gameController,
        builder: (context, child) {
          return MaterialApp(
            title: 'Buddy Fight Life Counter',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(_gameController.themeMode),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
