import 'package:flutter/material.dart';

class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.targetCount,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int targetCount;
}

class UserBadgeProgress {
  const UserBadgeProgress({
    required this.definition,
    required this.currentProgress,
    required this.isEarned,
    this.earnedAt,
  });

  final BadgeDefinition definition;
  final int currentProgress;
  final bool isEarned;
  final DateTime? earnedAt;
}

final List<BadgeDefinition> kAppBadges = [
  const BadgeDefinition(
    id: 'first_act',
    name: 'First Kind Act',
    description: 'Complete your very first kind act.',
    icon: Icons.favorite,
    targetCount: 1,
  ),
  const BadgeDefinition(
    id: 'three_day_streak',
    name: 'Three-Day Streak',
    description: 'Keep your kindness streak alive for 3 consecutive days.',
    icon: Icons.local_fire_department,
    targetCount: 3,
  ),
  const BadgeDefinition(
    id: 'seven_day_streak',
    name: 'Seven-Day Streak',
    description: 'Reach a full week of consecutive daily kind acts.',
    icon: Icons.military_tech,
    targetCount: 7,
  ),
  const BadgeDefinition(
    id: 'thirty_day_streak',
    name: 'Thirty-Day Streak',
    description: 'Reach 30 consecutive days of uplifting others.',
    icon: Icons.workspace_premium,
    targetCount: 30,
  ),
  const BadgeDefinition(
    id: 'ten_acts',
    name: 'Ten Acts of Kindness',
    description: 'Complete 10 total acts of kindness.',
    icon: Icons.stars,
    targetCount: 10,
  ),
  const BadgeDefinition(
    id: 'explorer',
    name: 'Kindness Explorer',
    description: 'Complete acts across 6 distinct kindness categories.',
    icon: Icons.explore,
    targetCount: 6,
  ),
];
