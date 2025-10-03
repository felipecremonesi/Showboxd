import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkYellowTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.amber[700],
  scaffoldBackgroundColor: Colors.black,

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.amber[700],
    elevation: 2,
    titleTextStyle: TextStyle(
      color: Colors.amber[700],
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.amber[700]),
  ),

  // Cards
  cardTheme: CardThemeData(
    color: Colors.grey[900],
    shadowColor: Colors.black,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),

  // Inputs
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[850],
    labelStyle: TextStyle(color: Colors.amber[700]),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.amber[700]!),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.amber[400]!),
      borderRadius: BorderRadius.circular(8),
    ),
  ),

  // Texto
  textTheme: GoogleFonts.breeSerifTextTheme(ThemeData.light().textTheme)
      .copyWith(
        bodyLarge: GoogleFonts.breeSerif(
          fontSize: 20,
          color: Colors.amber[100],
        ),
        bodyMedium: GoogleFonts.breeSerif(
          fontSize: 18,
          color: Colors.amber[100],
        ),
        titleLarge: GoogleFonts.breeSerif(
          fontSize: 22,
          color: Colors.amberAccent,
          fontWeight: FontWeight.bold,
        ),
      ),

  // Botões
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.amber[700],
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),

  // Switch
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(Colors.amber[700]),
    trackColor: MaterialStateProperty.all(Colors.amber[200]?.withOpacity(0.5)),
  ),

  // Slider
  sliderTheme: SliderThemeData(
    activeTrackColor: Colors.amber[700],
    inactiveTrackColor: Colors.amber[200]?.withOpacity(0.5),
    thumbColor: Colors.amber[700],
    overlayColor: Colors.amber[200]?.withOpacity(0.2),
    valueIndicatorColor: Colors.amber[700],
  ),

  // Chips
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[800]!,
    labelStyle: TextStyle(color: Colors.amber[100]),
    deleteIconColor: Colors.amber[700],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    secondaryLabelStyle: TextStyle(color: Colors.amber[100]),
  ),

  // Icones
  iconTheme: IconThemeData(color: Colors.amber[700]),

  // FloatingActionButton
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.amber[700],
    foregroundColor: Colors.black,
  ),
);
