import 'package:flutter/material.dart';
import '../theme/text_styles.dart';

extension AppTextExtension on String {
  // ── 12px — captions, helper text ──────────────────────────────
  Text textSmall({
    Color? color,
    FontWeight? fontWeight,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    double? height,
    double? letterSpacing,
    TextDecoration? underLine,
  }) =>
      Text(
        this,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        textScaler: const TextScaler.linear(1.0),
        style: AppTextStyles.textSmall.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: underLine,
          height: height,
          letterSpacing: letterSpacing,
        ),
      );

  // ── 14px — body text (DEFAULT) ────────────────────────────────
  Text textRegular({
    Color? color,
    FontWeight? fontWeight,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    double? height,
    double? letterSpacing,
    TextDecoration? underLine,
  }) =>
      Text(
        this,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        textScaler: const TextScaler.linear(1.0),
        style: AppTextStyles.textRegular.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: underLine,
          decorationThickness: 1.0,
          height: height,
          letterSpacing: letterSpacing,
        ),
      );

  // ── 16px — slightly prominent body text ───────────────────────
  Text textMedium({
    Color? color,
    FontWeight? fontWeight,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    double? height,
    double? letterSpacing,
    TextDecoration? underLine,
  }) =>
      Text(
        this,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        textScaler: const TextScaler.linear(1.0),
        style: AppTextStyles.textMedium.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: underLine,
          height: height,
          letterSpacing: letterSpacing,
        ),
      );

  // ── 18px — section titles, tab labels ─────────────────────────
  Text textLarge({
    Color? color,
    FontWeight? fontWeight,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    double? height,
    double? letterSpacing,
    TextDecoration? underLine,
  }) =>
      Text(
        this,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        textScaler: const TextScaler.linear(1.0),
        style: AppTextStyles.textLarge.copyWith(
          color: color,
          fontWeight: fontWeight,
          decoration: underLine,
          height: height,
          letterSpacing: letterSpacing,
        ),
      );

  // ── 24px — screen headings ────────────────────────────────────
  Text textExtraLarge({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    double? height,
    double? letterSpacing,
    TextDecoration? underLine,
  }) =>
      Text(
        this,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        textScaler: const TextScaler.linear(1.0),
        style: AppTextStyles.textExtraLarge.copyWith(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          decoration: underLine,
          height: height,
          letterSpacing: letterSpacing,
        ),
      );
}
