import 'dart:io' show Platform;
import 'package:closetshare/features/login/onboard_slide.dart';
import 'package:closetshare/features/login/register_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscure = true;

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
            const TextField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
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
                onPressed: () => Navigator.pushNamed(context, '/forgot'),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text("Login"),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
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

    if (Platform.isIOS) {
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
