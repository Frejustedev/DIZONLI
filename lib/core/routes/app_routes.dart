import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/groups/groups_screen.dart';
import '../../screens/challenges/challenges_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/social/social_feed_screen.dart';
import '../../screens/badges/badges_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/friends/friends_screen.dart';
import '../../screens/statistics/statistics_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String groups = '/groups';
  static const String challenges = '/challenges';
  static const String profile = '/profile';
  static const String social = '/social';
  static const String settings = '/settings';
  static const String badges = '/badges';
  static const String friends = '/friends';
  static const String statistics = '/statistics';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      main: (context) => const MainScreen(),
      dashboard: (context) => const DashboardScreen(),
      groups: (context) => const GroupsListScreen(),
      challenges: (context) => const ChallengesScreen(),
      profile: (context) => const ProfileScreen(),
      social: (context) => const SocialFeedScreen(),
      badges: (context) => const BadgesScreen(),
      settings: (context) => const SettingsScreen(),
      friends: (context) => const FriendsScreen(),
      statistics: (context) => const StatisticsScreen(),
    };
  }
}

