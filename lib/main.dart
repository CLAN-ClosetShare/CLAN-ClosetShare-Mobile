import 'package:closetshare/features/navigation/main_navigation_page.dart';
import 'package:closetshare/features/login/login_page.dart';
import 'package:closetshare/features/login/welcome.dart';
import 'package:flutter/material.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CloseShare',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const WelcomePage(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainNavigationPage(),
      },
    );
  }
}
