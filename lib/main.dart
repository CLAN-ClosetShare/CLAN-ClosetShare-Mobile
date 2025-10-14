import 'package:closetshare/features/navigation/main_navigation_page.dart';
import 'package:flutter/material.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/navigation/app_navigator.dart';
import 'features/auth/auth_page.dart';
import 'features/auth/login_page.dart' as auth_login;
import 'features/auth/register_page.dart';
import 'features/auth/forgot_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await di.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CloseShare',
      navigatorKey: appNavigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AuthPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => auth_login.LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/home': (context) => const MainNavigationPage(),
      },
    );
  }
}
