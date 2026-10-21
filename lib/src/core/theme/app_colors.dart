import 'package:flutter/material.dart';

/// Defines the application design color tokens based on Tailwind Slate, Indigo, and Emerald palettes.
abstract final class AppColors {
  /// Lightest indigo tint (`#EEF2FF`).
  static const Color indigo50 = Color(0xFFEEF2FF);

  /// Soft indigo background tint (`#E0E7FF`).
  static const Color indigo100 = Color(0xFFE0E7FF);

  /// Bright indigo accent for dark mode (`#818CF8`).
  static const Color indigo400 = Color(0xFF818CF8);

  /// Primary brand indigo (`#6366F1`).
  static const Color indigo500 = Color(0xFF6366F1);

  /// Deep brand indigo for light mode primary actions (`#4F46E5`).
  static const Color indigo600 = Color(0xFF4F46E5);

  /// Pressed state indigo (`#4338CA`).
  static const Color indigo700 = Color(0xFF4338CA);

  /// Light mode scaffold background (`#F8FAFC`).
  static const Color slate50 = Color(0xFFF8FAFC);

  /// Subtle neutral container fill (`#F1F5F9`).
  static const Color slate100 = Color(0xFFF1F5F9);

  /// Light mode card and input border color (`#E2E8F0`).
  static const Color slate200 = Color(0xFFE2E8F0);

  /// Muted neutral border and handle color (`#CBD5E1`).
  static const Color slate300 = Color(0xFFCBD5E1);

  /// Secondary muted text and icon color (`#94A3B8`).
  static const Color slate400 = Color(0xFF94A3B8);

  /// Neutral subtitle text color (`#64748B`).
  static const Color slate500 = Color(0xFF64748B);

  /// Medium contrast neutral text color (`#475569`).
  static const Color slate600 = Color(0xFF475569);

  /// Dark neutral border color (`#334155`).
  static const Color slate700 = Color(0xFF334155);

  /// Dark mode elevated container and border color (`#1E293B`).
  static const Color slate800 = Color(0xFF1E293B);

  /// Dark mode card and app bar surface (`#0F172A`).
  static const Color slate900 = Color(0xFF0F172A);

  /// Dark mode scaffold background (`#020617`).
  static const Color slate950 = Color(0xFF020617);

  /// Primary emerald green for completed states and 100% progress bars (`#10B981`).
  static const Color emerald500 = Color(0xFF10B981);

  /// Deep emerald green for confirmation banners (`#059669`).
  static const Color emerald600 = Color(0xFF059669);

  /// Warm amber accent for active streaks and warnings (`#F59E0B`).
  static const Color amber500 = Color(0xFFF59E0B);

  /// Rose red accent for destructive actions and validation errors (`#F43F5E`).
  static const Color rose500 = Color(0xFFF43F5E);

  /// Cyan habit accent color (`#06B6D4`).
  static const Color cyan500 = Color(0xFF06B6D4);

  /// Purple habit accent color (`#A855F7`).
  static const Color purple500 = Color(0xFFA855F7);
}
