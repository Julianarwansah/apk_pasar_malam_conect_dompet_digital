import 'package:flutter/material.dart';
import 'package:pasar_malam/core/services/secure_storage.dart';
import 'package:pasar_malam/features/auth/presentation/pages/login_page.dart';
import 'package:pasar_malam/features/auth/presentation/pages/register_page.dart';
import 'package:pasar_malam/features/auth/presentation/pages/verify_email_page.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/cart/presentation/pages/cart_page.dart';
import 'package:pasar_malam/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pasar_malam/features/order/data/models/order_model.dart';
import 'package:pasar_malam/features/order/presentation/pages/checkout_page.dart';
import 'package:pasar_malam/features/order/presentation/pages/my_orders_page.dart';
import 'package:pasar_malam/features/order/presentation/pages/order_success_page.dart';
import 'package:pasar_malam/features/order/presentation/pages/payment_pending_page.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard = '/dashboard';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String myOrders = '/my-orders';
  static const String paymentPending = '/payment-pending';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(),
        login: (_) => const LoginPage(),
        register: (_) => const RegisterPage(),
        verifyEmail: (_) => const VerifyEmailPage(),
        dashboard: (_) => const AuthGuard(child: DashboardPage()),
        cart: (_) => const CartPage(),
        checkout: (_) => const CheckoutPage(),
        myOrders: (_) => const MyOrdersPage(),
        orderSuccess: (context) {
          final order =
              ModalRoute.of(context)!.settings.arguments as OrderModel;
          return OrderSuccessPage(order: order);
        },
        paymentPending: (context) {
          final order =
              ModalRoute.of(context)!.settings.arguments as OrderModel;
          return PaymentPendingPage(order: order);
        },
      };
}

/// Proteksi halaman — hanya user terautentikasi yang dapat masuk
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;
    return switch (status) {
      AuthStatus.authenticated => child,
      AuthStatus.emailNotVerified => const VerifyEmailPage(),
      _ => const LoginPage(),
    };
  }
}

/// Halaman splash — cek token tersimpan, redirect otomatis
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final token = await SecureStorageService.getToken();
    if (!mounted) return;
    final route = token != null ? AppRouter.dashboard : AppRouter.login;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Pasar Malam · 00',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 32),
                Container(
                  width: 32,
                  height: 1,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const Spacer(),
                Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'LOADING',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const Spacer(),
                Text(
                  'Pasar Malam',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Etalase · Dompet · Pesanan.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
}
