import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:closetshare/features/login/register_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:closetshare/core/di/injection_container.dart' as di;
import 'package:closetshare/core/repositories/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscure = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _showedAutoLogout = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_showedAutoLogout) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && (args['autoLogout'] == true)) {
        final String msg =
            args['message'] as String? ??
            'Session expired, please log in again';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(msg)));
          }
        });
        _showedAutoLogout = true;
      }
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = di.sl<AuthRepository>();
      await authRepo.login(email, password);
      // After successful login, go to onboarding first, then user will proceed to home
      Navigator.pushReplacementNamed(context, '/onboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandNavy = Color(0xFF00073E);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Closet Share"),
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: const Color(0xFFF3F4F6),
        foregroundColor: Colors.black87,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
          fontStyle: FontStyle.italic,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please log in to continue",
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
            const SizedBox(height: 60),

            // Email
            const Text(
              "Email",
              style: TextStyle(fontSize: 14, color: Color(0xFF797878)),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: "Enter your email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Password
            const Text(
              "Password",
              style: TextStyle(fontSize: 14, color: Color(0xFF797878)),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: "Enter your password",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                  tooltip: _obscure ? "Show password" : "Hide password",
                ),
              ),
            ),

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/forgot-password'),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Color(0xFF01559A),
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Login"),
              ),
            ),

            const SizedBox(height: 16),
            // Divider "Or continue with"
            Row(
              children: const [
                Expanded(
                  child: Divider(thickness: 1, color: Color(0x11000000)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Or continue with",
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Divider(thickness: 1, color: Color(0x11000000)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Social sign-in buttons
            SocialSignInButtons(),

            const SizedBox(height: 16),
            // Register link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                    if (result != null && result.isNotEmpty) {
                      setState(() => _emailController.text = result);
                    }
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      color: Color(0xFF01559A),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SocialSignInButtons extends StatelessWidget {
  const SocialSignInButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: signInWithGoogle()
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Colors.black12),
            ),
            elevation: 0,
          ),
          icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
          label: const Text(
            "Continue with Google",
            style: TextStyle(color: Colors.black87),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: signInWithFacebook()
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Colors.black12),
            ),
            elevation: 0,
          ),
          icon: const FaIcon(
            FontAwesomeIcons.facebook,
            color: Color(0xFF1877F2),
          ),
          label: const Text(
            "Continue with Facebook",
            style: TextStyle(color: Color(0xFF1877F2)),
          ),
        ),
      ),
    ];

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      buttons.insertAll(0, [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: signInWithApple()
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            icon: const FaIcon(FontAwesomeIcons.apple, color: Colors.white),
            label: const Text(
              "Continue with Apple",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ]);
    }

    return Column(children: buttons);
  }
}
