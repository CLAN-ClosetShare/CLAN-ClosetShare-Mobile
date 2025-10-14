import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _confirmCtl = TextEditingController();
  String? _phoneFull; // +84xxx

  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[A-Za-z]{2,}$').hasMatch(s);
    if (!ok) return 'Invalid email';
    return null;
  }

  String? _passwordValidator(String? v) {
    final s = (v ?? '');
    if (s.isEmpty) return 'Password is required';
    if (s.length < 6) return 'At least 6 characters';
    return null;
  }

  String? _confirmValidator(String? v) {
    if ((v ?? '').isEmpty) return 'Confirm your password';
    if (v != _passCtl.text) return 'Passwords do not match';
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // TODO: call API register with: _emailCtl.text, _passCtl.text, _phoneFull
      // For now return the email to the previous screen so it can be prefilled
      Navigator.of(context).pop(_emailCtl.text.trim());
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
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome!",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create an account to get started",
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // Email
              const Text(
                "Email",
                style: TextStyle(fontSize: 14, color: Color(0xFF797878)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: "Enter your email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: _emailValidator,
              ),
              const SizedBox(height: 16),

              // Phone

              // Password
              const Text(
                "Password",
                style: TextStyle(fontSize: 14, color: Color(0xFF797878)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passCtl,
                obscureText: _obscure1,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure1 ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
                validator: _passwordValidator,
              ),
              const SizedBox(height: 16),

              // Confirm
              const Text(
                "Confirm Password",
                style: TextStyle(fontSize: 14, color: Color(0xFF797878)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmCtl,
                obscureText: _obscure2,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: "Re-enter your password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure2 ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
                validator: _confirmValidator,
              ),
              const SizedBox(height: 16),
              const Text(
                "Phone",
                style: TextStyle(fontSize: 14, color: Color(0xFF797878)),
              ),
              const SizedBox(height: 6),
              IntlPhoneField(
                decoration: const InputDecoration(
                  hintText: "Your number",
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: 'VN',
                onChanged: (p) => _phoneFull = p.completeNumber,
                validator: (p) {
                  if (p == null || (p.number).trim().isEmpty) {
                    return 'Phone is required';
                  }
                  if (p.number.trim().length < 8) {
                    return 'Phone seems too short';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandNavy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text("Sign Up"),
                ),
              ),

              const SizedBox(height: 16),
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

              const _SocialSignInButtons(),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: const Text(
                      "Login",
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
      ),
    );
  }
}

class _SocialSignInButtons extends StatelessWidget {
  const _SocialSignInButtons();

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            /* TODO: signInWithGoogle() */
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
            /* TODO: signInWithFacebook() */
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
              /* TODO: signInWithApple() */
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
