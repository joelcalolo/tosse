import 'package:flutter/material.dart';

// Modern Minimalist Color Palette with 3D Depth
const kMedicalBlue = Color(0xFF6366F1); // Indigo vibrante
const kMedicalBlueDark = Color(0xFF4F46E5);
const kMedicalBlueLight = Color(0xFF818CF8);
const kMedicalGreen = Color(0xFF10B981); // Verde esmeralda
const kMedicalGreenDark = Color(0xFF059669);
const kMedicalGreenLight = Color(0xFF34D399);

// Text Colors - Soft and Modern
const kTextColor = Color(0xFF2D3748);
const kTextLightColor = Color(0xFF718096);
const kTextSecondary = Color(0xFFA0AEC0);

// Background Colors - Clean and Minimal with Gradients
const kClinicalWhite = Color(0xFFFAFBFC);
const kBackgroundWhite = Color(0xFFFFFFFF);
const kCardBackground = Color(0xFFFFFFFF);
const kBackgroundGradientStart = Color(0xFFFAFBFC);
const kBackgroundGradientEnd = Color(0xFFF1F5F9);

// Status Colors - Vibrant and Modern
const kBronquiteColor = Color(0xFFF59E0B); // Âmbar vibrante
const kBronquiteLight = Color(0xFFFBBF24);
const kPneumoniaColor = Color(0xFFEF4444); // Vermelho vibrante
const kPneumoniaLight = Color(0xFFF87171);
const kNormalColor = Color(0xFF22C55E); // Verde vibrante
const kNormalLight = Color(0xFF4ADE80);

// Gradient Colors - Enhanced for 3D Effect
const kGradientBlueStart = Color(0xFF6366F1);
const kGradientBlueEnd = Color(0xFF4F46E5);
const kGradientGreenStart = Color(0xFF10B981);
const kGradientGreenEnd = Color(0xFF059669);
const kGradientBronquiteStart = Color(0xFFF59E0B);
const kGradientBronquiteEnd = Color(0xFFD97706);
const kGradientPneumoniaStart = Color(0xFFEF4444);
const kGradientPneumoniaEnd = Color(0xFFDC2626);

// 3D Elevation System - Multi-layer Shadows
List<BoxShadow> getElevation3D(Color color, {double intensity = 1.0}) {
  return [
    // Main shadow - colored and soft
    BoxShadow(
      color: color.withOpacity(0.15 * intensity),
      blurRadius: 20 * intensity,
      offset: Offset(0, 8 * intensity),
      spreadRadius: 0,
    ),
    // Secondary shadow - for depth
    BoxShadow(
      color: color.withOpacity(0.1 * intensity),
      blurRadius: 40 * intensity,
      offset: Offset(0, 16 * intensity),
      spreadRadius: -8 * intensity,
    ),
    // Highlight shadow - top light
    BoxShadow(
      color: Colors.white.withOpacity(0.6 * intensity),
      blurRadius: 15 * intensity,
      offset: Offset(-4 * intensity, -4 * intensity),
      spreadRadius: 0,
    ),
  ];
}

// Deep 3D Elevation - For prominent elements
List<BoxShadow> getDeepElevation3D(Color color) {
  return [
    BoxShadow(
      color: color.withOpacity(0.25),
      blurRadius: 30,
      offset: const Offset(0, 12),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: color.withOpacity(0.15),
      blurRadius: 60,
      offset: const Offset(0, 24),
      spreadRadius: -12,
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.8),
      blurRadius: 20,
      offset: const Offset(-6, -6),
      spreadRadius: 0,
    ),
  ];
}

// Subtle 3D Elevation - For cards and surfaces
List<BoxShadow> getSubtleElevation3D(Color color) {
  return [
    BoxShadow(
      color: color.withOpacity(0.08),
      blurRadius: 15,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.7),
      blurRadius: 10,
      offset: const Offset(-3, -3),
      spreadRadius: 0,
    ),
  ];
}

// Spacing
const kDefaultPaddin = 24.0;
const kCardRadius = 24.0;
const kButtonRadius = 16.0;
const kLargeCardRadius = 32.0;

// Animation Durations
const kAnimationDurationFast = Duration(milliseconds: 200);
const kAnimationDurationNormal = Duration(milliseconds: 300);
const kAnimationDurationSlow = Duration(milliseconds: 500);
const kAnimationDurationVerySlow = Duration(milliseconds: 800);
