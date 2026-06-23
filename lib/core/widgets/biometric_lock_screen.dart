import 'package:flutter/material.dart';
import 'package:flutter_biometric_kit/flutter_biometric_kit.dart';
import 'package:provider/provider.dart';

import '../services/biometric_lock_provider.dart';
import 'swiss.dart';

/// Membungkus seluruh widget tree dan menampilkan layar kunci
/// jika [BiometricLockProvider.isLocked] bernilai true.
class BiometricLockScreen extends StatefulWidget {
  final Widget child;

  const BiometricLockScreen({super.key, required this.child});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen>
    with WidgetsBindingObserver {
  DateTime? _backgroundedAt;

  static const _lockTimeout = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BiometricLockProvider>();
      if (provider.isLocked) provider.unlock();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.paused:
        final provider = context.read<BiometricLockProvider>();
        if (!provider.isLocked) {
          _backgroundedAt = DateTime.now();
        }
      case AppLifecycleState.resumed:
        final bg = _backgroundedAt;
        if (bg != null && DateTime.now().difference(bg) >= _lockTimeout) {
          _backgroundedAt = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final provider = context.read<BiometricLockProvider>();
            provider.lock();
            provider.unlock();
          });
        }
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BiometricLockProvider>();
    if (!provider.isLocked) return widget.child;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              SwissLabel('Pasar Malam · Secure'),
              const SizedBox(height: 32),
              Container(
                width: 32,
                height: 1,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const Spacer(),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: provider.isAuthenticating
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        )
                      : Container(
                          key: const ValueKey('icon'),
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            size: 22,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Aplikasi Terkunci',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      height: 1.0,
                      letterSpacing: -0.8,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Verifikasi identitas untuk melanjutkan.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
              if (provider.errorMessage != null) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: Theme.of(context).colorScheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              SwissPrimaryButton(
                label: 'Buka Kunci',
                icon: Icons.fingerprint,
                onPressed:
                    provider.isAuthenticating ? null : provider.unlock,
                loading: provider.isAuthenticating,
              ),
              if (provider.errorCode == BiometricErrorCode.notEnrolled) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: const Text('DAFTARKAN BIOMETRIK DI PENGATURAN'),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}