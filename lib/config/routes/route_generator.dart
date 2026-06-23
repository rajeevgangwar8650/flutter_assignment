import 'package:flutter/material.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/stocks/presentation/pages/stocks_page.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';

class RouteGenerator {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      case AppRoutes.stocks:
        return MaterialPageRoute(builder: (_) => const StocksPage());
      case AppRoutes.splash:
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
