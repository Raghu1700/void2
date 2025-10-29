import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Red & Gold Colors
  static const Color primaryRed = Color(0xFFDC143C); // Crimson Red
  static const Color primaryRedLight = Color(0xFFFF6B6B); // Light Red
  static const Color primaryRedDark = Color(0xFFB22222); // Dark Red
  static const Color accentGold = Color(0xFFFFD700); // Gold
  static const Color lightGold = Color(0xFFFFE97F); // Light gold

  // White & Neutral Colors
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFFFBF5); // Warm off-white
  static const Color lightCream = Color(0xFFFFF8E1); // Light cream
  static const Color warmGray = Color(0xFF757575);
  static const Color darkGray = Color(0xFF424242);
  static const Color textDark = Color(0xFF2C2C2C);

  // Status Colors
  static const Color successGreen = Color(0xFF66BB6A);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color dangerRed = Color(0xFFEF5350);
  static const Color infoBlue = Color(0xFF42A5F5);

  // Legacy colors for compatibility
  static const Color primaryYellow = accentGold; // Redirected to gold
  static const Color primaryBlue = infoBlue;
  static const Color primaryGreen = successGreen;
  static const Color primaryPurple = Color(0xFFAB47BC);

  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFBF5);
  static const Color backgroundDark = Color(0xFF1A1A2E);

  // Card Colors
  static const Color cardLight = pureWhite;
  static const Color cardDark = Color(0xFF16213E);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRedLight, primaryRed],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGold, accentGold],
  );

  static const LinearGradient redGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, accentGold],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [offWhite, pureWhite],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        secondary: accentGold,
        tertiary: primaryRedLight,
        error: dangerRed,
        surface: cardLight,
        background: backgroundLight,
        onPrimary: pureWhite,
        onSecondary: textDark,
        onSurface: textDark,
        onBackground: textDark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: textDark,
            letterSpacing: -0.5,
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textDark,
            letterSpacing: -0.3,
          ),
          displaySmall: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            color: textDark,
            height: 1.6,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            color: warmGray,
            height: 1.5,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            color: warmGray,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 6,
        shadowColor: primaryRed.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        color: cardLight,
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textDark,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: primaryRed,
          foregroundColor: pureWhite,
          shadowColor: primaryRed.withOpacity(0.5),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryRed,
        foregroundColor: pureWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryRed.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryRed.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: pureWhite,
        selectedItemColor: primaryRed,
        unselectedItemColor: warmGray,
        elevation: 16,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        secondary: accentGold,
        tertiary: primaryRedLight,
        error: dangerRed,
        surface: cardDark,
        background: backgroundDark,
        onPrimary: pureWhite,
        onSecondary: textDark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displaySmall: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white70,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: primaryRed.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        color: cardDark,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundDark,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: primaryRed,
          foregroundColor: pureWhite,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
      ),
    );
  }
}
