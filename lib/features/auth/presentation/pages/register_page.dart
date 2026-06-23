import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/core/widgets/swiss.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/auth_header.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/custom_button.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Pendaftaran gagal'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Mendaftarkan akun',
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
                    kicker: 'Pasar Malam · 02',
                    title: 'Daftar\nAkun Baru',
                    subtitle:
                        'Lengkapi data di bawah untuk membuat akun Anda.',
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    controller: _nameCtrl,
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
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
                    hint: 'Minimal 8 karakter',
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
                    validator: (v) => (v?.length ?? 0) < 8
                        ? 'Password minimal 8 karakter'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Konfirmasi Password',
                    hint: 'Ulangi password',
                    controller: _pass2Ctrl,
                    obscureText: !_showPass,
                    validator: (v) =>
                        v != _passCtrl.text ? 'Password tidak cocok' : null,
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    label: 'Daftar Sekarang',
                    onPressed: _register,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SwissLabel('Sudah punya akun?'),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          AppRouter.login,
                        ),
                        child: Text(
                          'MASUK',
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