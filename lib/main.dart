import 'package:closetshare/features/navigation/main_navigation_page.dart';
import 'package:flutter/material.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/navigation/app_navigator.dart';
import 'features/login/welcome.dart';
import 'features/login/onboard_slide.dart';
import 'features/login/login_page.dart' as auth_login;
import 'features/login/register_page.dart';
import 'features/auth/forgot_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await di.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CloseShare',
      navigatorKey: appNavigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const WelcomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => auth_login.LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/onboard': (context) => const OnboardingPage(),
        '/home': (context) => const MainNavigationPage(),
      },
    );
  }
}
