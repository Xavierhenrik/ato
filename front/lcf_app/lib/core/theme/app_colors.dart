import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background      = Color(0xFF1A0800);
  static const Color backgroundCard  = Color(0xFF2D1200);
  static const Color backgroundSheet = Color(0xFF3D1200);
  static const Color backgroundNav   = Color(0xFF140600);

  // Gold / Accent
  static const Color accent      = Color(0xFFC9922A);
  static const Color accentDark  = Color(0xFF9A6B1A);
  static const Color accentLight = Color(0xFFE8B84B);

  // Bordas
  static const Color border       = Color(0xFF3D2010);
  static const Color borderAccent = Color(0xFFC9922A);
  static const Color borderMuted  = Color(0xFF2A1508);

  // Textos
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E8472);
  static const Color textMuted     = Color(0xFF6B5240);
  static const Color textAccent    = Color(0xFFC9922A);

  // Semânticas
  static const Color tagBackground = Color(0xFF5A1A1A);
  static const Color success       = Color(0xFF4CAF50);
  static const Color info          = Color(0xFF2A4A7A);
  static const Color error         = Color(0xFF8B2020);
  static const Color errorBg       = Color(0xFF3A1A1A);

  // Streak / Progresso
  static const Color streakFire   = Color(0xFFFF6B00);
  static const Color progressRing = Color(0xFFC9922A);
  static const Color progressBg   = Color(0xFF3D2010);

  // Avatares / Status
  static const Color onlineDot = Color(0xFF4CAF50);

  // Quiz — feedback correto/errado
  static const Color quizCorrect         = Color(0xFF4CAF50);
  static const Color quizCorrectBg       = Color(0xFF1A3A1A);
  static const Color quizCorrectLetterBg = Color(0xFF2A5A2A);
  static const Color quizWrongBg         = Color(0xFF3A1A1A);
  static const Color quizWrongLetterBg   = Color(0xFF5A2A2A);

  // Tags de matéria
  static const Map<String, Color> subjectTagColors = {
    'Constitucional': Color(0xFF1A3A5C),
    'Civil':          Color(0xFF1A3A2A),
    'Penal':          Color(0xFF5C1A1A),
    'Trabalho':       Color(0xFF3A2A1A),
    'Proc. Civil':    Color(0xFF2A1A5C),
    'Administrativo': Color(0xFF1A3A3A),
    'OAB':            Color(0xFF3A3A1A),
  };

  // Gradientes
  static const LinearGradient progressGradient = LinearGradient(
    colors: [Color(0xFFC9922A), Color(0xFFE8B84B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
