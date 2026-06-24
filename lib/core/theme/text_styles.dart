import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextSize {
  AppTextSize._();

  static const double ts10 = 10;   // version text, badges
  static const double ts12 = 12;   // captions, labels, helper text
  static const double ts14 = 14;   // body text (DEFAULT)
  static const double ts16 = 16;   // section titles, tab labels
  static const double ts18 = 18;   // page sub-headings
  static const double ts20 = 20;   // page headings
  static const double ts24 = 24;   // screen headings

}

class AppTextStyles {
  AppTextStyles._();

  // ── 12px — captions, helper text, secondary info ──────────────
  static TextStyle textSmall = GoogleFonts.inter(
    fontSize: AppTextSize.ts12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ── 14px — body text (DEFAULT) ────────────────────────────────
  static TextStyle textRegular = GoogleFonts.inter(
    fontSize: AppTextSize.ts14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── 16px — slightly prominent body text ───────────────────────
  static TextStyle textMedium = GoogleFonts.inter(
    fontSize: AppTextSize.ts16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // ── 18px — section titles, tab labels ─────────────────────────
  static TextStyle textLarge = GoogleFonts.inter(
    fontSize: AppTextSize.ts18,
    fontWeight: FontWeight.w600,
    height: 1.6,
  );

  // ── 24px — screen headings ────────────────────────────────────
  static TextStyle textExtraLarge = GoogleFonts.inter(
    fontSize: AppTextSize.ts24,
    fontWeight: FontWeight.w800,
    height: 1.3,
  );
}