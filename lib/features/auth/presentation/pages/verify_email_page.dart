import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/core/widgets/swiss.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/auth_header.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/custom_button.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _resendCooldown = false;
  int _countdown = 60;

  Future<void> _onYes() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.loginAfterEmailVerification();
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else if (auth.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Gagal konek ke server'),
          action: SnackBarAction(
            label: 'COBA LAGI',
            textColor: Theme.of(context).colorScheme.surface,
            onPressed: _onYes,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email belum dikonfirmasi. Cek inbox atau folder spam.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _onNo() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown) return;
    await context.read<AuthProvider>().resendVerificationEmail();

    setState(() {
      _resendCooldown = true;
      _countdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown--);
      if (_countdown <= 0) {
        setState(() => _resendCooldown = false);
        return false;
      }
      return true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verifikasi sudah dikirim ulang')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.firebaseUser;

    return LoadingOverlay(
      isLoading: auth.isLoading,
      message: 'Memverifikasi email',
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const AuthHeader(
                  kicker: 'Pasar Malam · 03',
                  title: 'Verifikasi\nEmail',
                  subtitle:
                      'Kami sudah mengirim link verifikasi. Buka email dan klik link tersebut untuk mengaktifkan akun.',
                ),
                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwissLabel('Email Tujuan'),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? '-',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                SwissLabel('Sudah konfirmasi?'),
                const SizedBox(height: 16),
                CustomButton(
                  label: 'Ya, Sudah Konfirmasi',
                  onPressed: _onYes,
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: 'Kembali ke Login',
                  variant: ButtonVariant.outlined,
                  onPressed: _onNo,
                ),
                const SizedBox(height: 32),
                const SwissHairline(),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      SwissLabel('Tidak menerima email?'),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _resendCooldown ? null : _resendEmail,
                        child: Text(
                          _resendCooldown
                              ? 'KIRIM ULANG ($_countdown detik)'
                              : 'KIRIM ULANG EMAIL',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}