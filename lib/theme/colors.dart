import 'package:flutter/material.dart';

class AshenColors {
  static const background  = Color(0xFF0E0C08);
  static const surface     = Color(0xFF1A1208);
  static const surfaceAlt  = Color(0xFF221A0E);
  static const copper      = Color(0xFFB87333);
  static const gold        = Color(0xFFD4AF37);
  static const parchment   = Color(0xFFD4C5A9);
  static const parchmentDim= Color(0xFF8C7B63);
  static const darkRed     = Color(0xFF8B0000);
  static const bloodRed    = Color(0xFFCC2200);
  static const ashGrey     = Color(0xFF4A4535);
  static const border      = Color(0xFF3A2E1E);
  static const healthGreen  = Color(0xFF4A7C3F);
  static const recoverBlue  = Color(0xFF2E5C8A);
  static const manaBlue     = Color(0xFF4A90D9);
  static const deadGrey     = Color(0xFF3A3530);
  // Bloodstained Parchment theme additions
  static const inkRed       = Color(0xFF7A1A10);
  static const parchmentWarm= Color(0xFF231C0D);
  static const sepiaLine    = Color(0xFF4A3218);
}

class AshenText {
  static const heading = TextStyle(
    color: AshenColors.copper,
    fontSize: 13,
    letterSpacing: 3,
    fontWeight: FontWeight.bold,
  );

  static const body = TextStyle(
    color: AshenColors.parchment,
    fontSize: 14,
  );

  static const dim = TextStyle(
    color: AshenColors.parchmentDim,
    fontSize: 12,
  );

  static const gold = TextStyle(
    color: AshenColors.gold,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}
