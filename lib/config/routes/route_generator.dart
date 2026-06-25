import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injection_container.dart';
import '../../features/indices/presentation/bloc/indices_bloc.dart';
import '../../features/indices/presentation/bloc/indices_event.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/stocks/presentation/bloc/stocks_bloc.dart';
import '../../features/stocks/presentation/bloc/stocks_event.dart';
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
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<IndicesBloc>(
                create: (_) =>
                    injector<IndicesBloc>()..add(const GetIndicesEvent()),
              ),
              BlocProvider<StocksBloc>(
                create: (_) =>
                    injector<StocksBloc>()..add(const GetStocksEvent()),
              ),
            ],
            child: const StocksPage(),
          ),
        );
      case AppRoutes.splash:
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
