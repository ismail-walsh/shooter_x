import 'package:flutter/material.dart';

typedef RankInfo = ({
  String label,
  IconData icon,
  Color color,
});

RankInfo getRank(int level) {
  if (level >= 60) {
    return (
      label: 'Field Marshal',
      icon: Icons.star_rounded,
      color: const Color(0xFFFFD700),
    );
  }
  if (level >= 50) {
    return (
      label: 'Brigadier',
      icon: Icons.military_tech_rounded,
      color: const Color(0xFFE5C100),
    );
  }
  if (level >= 45) {
    return (
      label: 'Colonel',
      icon: Icons.shield_rounded,
      color: const Color(0xFFAB8EF0),
    );
  }
  if (level >= 40) {
    return (
      label: 'Lt. Colonel',
      icon: Icons.shield_rounded,
      color: const Color(0xFF8B6FD0),
    );
  }
  if (level >= 35) {
    return (
      label: 'Major',
      icon: Icons.workspace_premium_rounded,
      color: const Color(0xFF3B82F6),
    );
  }
  if (level >= 30) {
    return (
      label: 'Captain',
      icon: Icons.stars_rounded,
      color: const Color(0xFF60A5FA),
    );
  }
  if (level >= 25) {
    return (
      label: 'Lieutenant',
      icon: Icons.arrow_upward_rounded,
      color: const Color(0xFF34D399),
    );
  }
  if (level >= 20) {
    return (
      label: 'Staff Sergeant',
      icon: Icons.trending_up_rounded,
      color: const Color(0xFF3DD162),
    );
  }
  if (level >= 15) {
    return (
      label: 'Sergeant',
      icon: Icons.bolt_rounded,
      color: const Color(0xFFF59E0B),
    );
  }
  if (level >= 10) {
    return (
      label: 'Corporal',
      icon: Icons.chevron_right_rounded,
      color: const Color(0xFFF97316),
    );
  }
  if (level >= 5) {
    return (
      label: 'Private',
      icon: Icons.person_rounded,
      color: const Color(0xFF94A3B8),
    );
  }
  return (
    label: 'Recruit',
    icon: Icons.fiber_new_rounded,
    color: const Color(0xFF64748B),
  );
}
