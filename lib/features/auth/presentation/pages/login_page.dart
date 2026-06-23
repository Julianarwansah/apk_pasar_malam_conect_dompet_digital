import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/core/widgets/swiss.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/auth_header.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/custom_button.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/divider_with_text.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  Future<void> _loginGoogle() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithGoogle();
    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  void _handleLoginResult(bool ok, AuthProvider auth) {
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else if (auth.status == AuthStatus.emailNotVerified) {
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login gagal')),
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Password'),
        content: CustomTextField(
          label: 'Email',
          hint: 'Email terdaftar',
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: ctrl.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('KIRIM'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Masuk ke akun',
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const AuthHeader(
                    kicker: 'Pasar Malam · 01',
                    title: 'Masuk\nke Akun',
                    subtitle:
                        'Lanjutkan ke etalase, keranjang, dan pesanan Anda.',
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    label: 'Email',
                    hint: 'contoh@email.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Email wajib diisi';
                      if (!EmailValidator.validate(v!)) {
                        return 'Format email salah';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Masukkan password',
                    controller: _passCtrl,
                    obscureText: !_showPass,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _showPass = !_showPass),
                    ),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordDialog(context),
                      child: const Text('LUPA PASSWORD?'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'Masuk',
                    onPressed: _loginEmail,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 32),
                  const DividerWithText(text: 'atau'),
                  const SizedBox(height: 32),
                  GoogleSignInButton(
                    onPressed: _loginGoogle,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SwissLabel('Belum punya akun?'),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          AppRouter.register,
                        ),
                        child: Text(
                          'DAFTAR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            decoration: TextDecoration.underline,
                            decorationThickness: 1,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}