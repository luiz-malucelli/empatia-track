import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;





class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color.fromRGBO(28, 128, 195, 1);
  static const Color lightSecondary = Color.fromRGBO(218, 216, 226, 1);
  static const Color lightBackground = Color.fromRGBO(243, 243, 250, 1);
  static const Color lightText = Color(0xFF000000);
  static const Color lightButtonBackground = Color(0xFFE0E0E0);
  static const Color onLightPrimary =  Color.fromRGBO(5, 65, 149, 1.0);
  static const Color onLightSecondary = Color.fromRGBO(54, 173, 184, 1.0); // Black for contrast on light secondary
  static const Color lightError = Color(0xFFE0E0E0);
  static const Color onLightError = Color(0xFF000000); // Assuming error color to be darker for contrast
  static const Color onLightBackground = Color.fromRGBO(35, 35, 35, 1.0); // Black for contrast on light background
  static const Color lightSurface = Color.fromRGBO(234, 230, 239, 1);
  static const Color onLightSurface = Color.fromRGBO(43, 43, 43, 1.0); // Black for contrast on light surface

  // Dark Theme Colors
  static const Color darkPrimary = Color.fromRGBO(100, 210, 255, 1);
  static const Color darkSecondary = Color.fromRGBO(30, 30, 30, 1);
  static const Color darkBackground = Color.fromRGBO(76, 76, 76, 1.0); // Assuming this is a darker color
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkButtonBackground = Color(0xFF232323);
  static const Color onDarkPrimary = Color.fromRGBO(100, 210, 255, 1); // Black for contrast on dark primary
  static const Color onDarkSecondary = Color.fromRGBO(30, 30, 30, 1); // White for contrast on dark secondary
  static const Color darkError = Color(0xFFE0E0E0);
  static const Color onDarkError = Color(0xFF000000); // Assuming error color to be darker for contrast
  static const Color onDarkBackground = Color(0xFFFFFFFF); // White for contrast on dark background
  static const Color darkSurface = Color.fromRGBO(64, 68, 72, 1);
  static const Color onDarkSurface = Colors.white; // Black for contrast on dark surface

  // Common Colors
  static const Color errorColor = Color(0xFFB00020);
}



ColorScheme lightColorScheme = const ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.lightPrimary,
  onPrimary: AppColors.onLightPrimary, // A color that stands out on primary color.
  secondary: AppColors.lightSecondary,
  onSecondary: AppColors.onLightSecondary, // A color that stands out on secondary color.
  error: AppColors.lightError, // Typically a bright red.
  onError: AppColors.onLightError, // A color that stands out on error color.
  surface: AppColors.lightBackground,
  onSurface: AppColors.onLightSurface, // A color that stands out on surface color.
);

ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppColors.darkPrimary,
  onPrimary: AppColors.onDarkPrimary, // A color that stands out on primary color.
  secondary: AppColors.darkSecondary,
  onSecondary: AppColors.onDarkSecondary, // A color that stands out on secondary color.
  error: AppColors.darkError, // Typically a dark red.
  onError: AppColors.onDarkError, // A color that stands out on error color.
  surface: AppColors.darkBackground,
  onSurface: AppColors.onDarkSurface, // A color that stands out on surface color.
);


// Modify your ThemeData definitions to include your existing properties
final ThemeData lightTheme = ThemeData(
  fontFamily: kIsWeb ? 'Roboto' : 'DefaultFontFamily',
  scaffoldBackgroundColor: Colors.transparent,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: AppColors.lightBackground,
    selectedItemColor: Colors.lightBlue[700],
    unselectedItemColor: AppColors.onLightSurface,
    selectedLabelStyle: const TextStyle(fontSize: 12),
    unselectedLabelStyle: const TextStyle(fontSize: 12),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.transparent,
  ),
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  popupMenuTheme: const PopupMenuThemeData(color: AppColors.lightBackground, surfaceTintColor: Colors.transparent),
  dividerTheme: const DividerThemeData(color: AppColors.onLightSurface),
  // Incorporate the light color scheme from AppColors
  primaryColor: AppColors.lightPrimary,
  colorScheme: lightColorScheme,
);

final ThemeData darkTheme = ThemeData(
  fontFamily: kIsWeb ? 'Roboto' : 'DefaultFontFamily',
  scaffoldBackgroundColor: Colors.transparent,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: AppColors.darkBackground,
    selectedItemColor: Colors.lightBlue[700],
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: const TextStyle(fontSize: 12),
    unselectedLabelStyle: const TextStyle(fontSize: 12),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.transparent,
  ),
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  popupMenuTheme: PopupMenuThemeData(color: AppColors.darkBackground, surfaceTintColor: Colors.transparent),
  dividerTheme: const DividerThemeData(color: Colors.grey),
  // Incorporate the dark color scheme from AppColors
  primaryColor: AppColors.darkPrimary,
  colorScheme: darkColorScheme,

  // Other properties from AppColors as needed
);
