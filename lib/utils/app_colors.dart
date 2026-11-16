import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------- Background ----------
  static const Color softPink = Color(0xFFF9E8EF);
  static const Color lavender = Color(0xFFECE4F8);
  static const Color lightPurpleBg = Color(0xFFF5ECFA);
  static const Color babyBlue = Color(0xFFE5EAFB);
  static const Color white = Color(0xFFFFFFFF);

  /// Warna dasar scaffold (dipakai kalau tidak ada GradientBackground).
  static const Color background = lightPurpleBg;
  static const Color backgroundDeep = lavender;
  static const Color surface = white;
  static const Color fieldFill = Color(0xFFF6F1FB);

  /// Gradasi utama aplikasi: kiri atas ke kanan bawah.
  static const List<Color> backgroundGradient = [
    softPink,
    lightPurpleBg,
    lavender,
    babyBlue,
  ];

  // ---------- Primary ----------
  static const Color purple = Color(0xFF9667D8);
  static const Color purpleDark = Color(0xFF7650BC);
  static const Color purpleSoft = Color(0xFFE5D5F8);
  static const Color purpleLight = Color(0xFFF1E8FC);

  /// Gradasi tombol ungu.
  static const List<Color> buttonGradient = [Color(0xFFB48BEA), purple];

  // ---------- Accent ----------
  static const Color pink = Color(0xFFF4BBD3);
  static const Color pinkSoft = Color(0xFFFBE0EC);
  static const Color mint = Color(0xFFD5F0E8);
  static const Color softYellow = Color(0xFFFFF0D1);
  static const Color blue = Color(0xFFE0E9FC);

  // ---------- Teks ----------
  static const Color ink = Color(0xFF30283D); // teks utama
  static const Color secondaryText = Color(0xFF777083);
  static const Color hintText = Color(0xFFAAA2B4);
  static const Color text = ink;

  // ---------- Sumber berita ----------
  //'NASA', '', '', '', '', ''
  static const Color NASA = Color(0xFF55B99A);
  static const Color SpacePolicyOnline = Color(0xFFEE8198);
  static const Color Space_Scout = Color.fromARGB(255, 129, 74, 104);
  static const Color SpaceFlight_Now = Color.fromARGB(255, 68, 183, 99);
  static const Color Arstechnica = Color.fromARGB(255, 101, 67, 143);
  static const Color European_Spaceflight = Color.fromARGB(255, 233, 255, 154);
  static const Color unknown = Color.fromARGB(255, 104, 104, 103);


  // ---------- Efek kaca (glass) ----------
  /// Putih transparan untuk kartu kaca (opacity 65-85%).
  static Color glassFill([double opacity = 0.72]) =>
      white.withValues(alpha: opacity);
  static Color glassBorder([double opacity = 0.9]) =>
      white.withValues(alpha: opacity);
  static Color softShadow([double opacity = 0.14]) =>
      purple.withValues(alpha: opacity);

  // ---------- Alias lama (jangan dihapus) ----------
  static const Color glaucous = purple;
  static const Color powderBlue = lavender;
  static const Color vanilla = softYellow;
  // static const Color mossGreen = alive;
  static const Color darkGreen = ink;
  static const Color steel = purple;
  static const Color steelDark = purpleDark;
  // static const Color olive = alive;
  // static const Color oliveDark = alive;
  static const Color yellow = softYellow;
  static const Color teal = mint;
  // static const Color coral = dead;
  static const Color success = NASA;
  static const Color primary = purple;
  static const Color secondary = pink;
  static const Color accent = softYellow;
  static const Color peach = pinkSoft;
  static const Color grey = Color(0xFFE6E1EC);
}
