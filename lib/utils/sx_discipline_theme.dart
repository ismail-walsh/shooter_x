import 'package:flutter/material.dart';

typedef DisciplineTheme = ({
  LinearGradient grad,
  Color accent,
  IconData icon,
});

DisciplineTheme getDisciplineTheme(String discipline) {
  final d = discipline.toLowerCase();

  if (d.contains('clay')) {
    return (
      grad: const LinearGradient(
        colors: [Color(0xFF2E1800), Color(0xFF0D0D0D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accent: const Color(0xFFF97316),
      icon: Icons.circle_outlined,
    );
  }

  if (d.contains('deer') || d.contains('stalk')) {
    return (
      grad: const LinearGradient(
        colors: [Color(0xFF0D2010), Color(0xFF0D0D0D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accent: const Color(0xFF3DD162),
      icon: Icons.forest_rounded,
    );
  }

  if (d.contains('game') || d.contains('driven') || d.contains('pheasant') || d.contains('grouse')) {
    return (
      grad: const LinearGradient(
        colors: [Color(0xFF2A1E00), Color(0xFF0D0D0D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accent: const Color(0xFFF59E0B),
      icon: Icons.terrain_rounded,
    );
  }

  if (d.contains('precision') || d.contains('long') || d.contains('f-class') || d.contains('prs')) {
    return (
      grad: const LinearGradient(
        colors: [Color(0xFF001428), Color(0xFF0D0D0D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accent: const Color(0xFF3B82F6),
      icon: Icons.gps_fixed_rounded,
    );
  }

  if (d.contains('pistol') || d.contains('handgun') || d.contains('ipsc') || d.contains('practical')) {
    return (
      grad: const LinearGradient(
        colors: [Color(0xFF280000), Color(0xFF0D0D0D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accent: const Color(0xFFEF4444),
      icon: Icons.adjust_rounded,
    );
  }

  // default
  return (
    grad: const LinearGradient(
      colors: [Color(0xFF0D2010), Color(0xFF0D0D0D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    accent: const Color(0xFF3DD162),
    icon: Icons.my_location_rounded,
  );
}
