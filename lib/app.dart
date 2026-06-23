import 'package:flutter/material.dart';
import 'config/routes/app_routes.dart';
import 'config/routes/route_generator.dart';
import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.generate,
    );
  }
}
