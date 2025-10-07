import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1E3A8A); // Dark blue for navigation
  static const Color primaryLight = Color(0xFF3B82F6); // Light blue for accents
  static const Color primaryDark = Color(0xFF1E40AF); // Darker blue for hover states
  
  // Background Colors
  static const Color background = Color(0xFFF8FAFC); // Light gray background
  static const Color surface = Color(0xFFFFFFFF); // White surface
  static const Color cardBackground = Color(0xFFFFFFFF); // White card background
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Darker gray for primary text
  static const Color textSecondary = Color(0xFF374151); // Darker medium gray for secondary text
  static const Color textLight = Color(0xFF6B7280); // Darker light gray for tertiary text
  static const Color textWhite = Color(0xFFFFFFFF); // White text
  
  // Status Colors
  static const Color success = Color(0xFF10B981); // Green for "EARLY" status
  static const Color warning = Color(0xFFF59E0B); // Yellow for warnings
  static const Color error = Color(0xFFEF4444); // Red for "LATE" status
  static const Color info = Color(0xFF3B82F6); // Blue for "ON TIME" status
  
  // Progress Ring Colors
  static const Color progressPrimary = Color(0xFF3B82F6);
  static const Color progressSecondary = Color(0xFF8B5CF6);
  static const Color progressTertiary = Color(0xFF06B6D4);
  static const Color progressQuaternary = Color(0xFFEC4899);
  static const Color progressBackground = Color(0xFFE5E7EB);
  
  // Glass Effect Colors
  static const Color glassBackground = Color(0x1AFFFFFF); // Semi-transparent white
  static const Color glassBorder = Color(0x33FFFFFF); // Semi-transparent white border
  
  // Navigation Colors
  static const Color navBackground = Color(0xFF1E3A8A);
  static const Color navActive = Color(0xFF3B82F6);
  static const Color navInactive = Color(0xFF94A3B8);
  
  // Shadow Colors
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Status Badge Colors
  static const Map<String, Color> statusColors = {
    'early': success,
    'on_time': info,
    'late': error,
    'pending': warning,
  };
}
