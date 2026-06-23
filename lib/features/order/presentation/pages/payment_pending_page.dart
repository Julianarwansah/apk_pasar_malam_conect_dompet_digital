import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/core/services/global_institute_pay_service.dart';
import 'package:pasar_malam/core/widgets/swiss.dart';
import 'package:pasar_malam/features/order/data/models/order_model.dart';
import 'package:pasar_malam/features/order/presentation/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

void _log(String msg) => debugPrint('[PasarMalam/PaymentPending] $msg');

class PaymentPendingPage extends StatefulWidget {
  final OrderModel order;

  const PaymentPendingPage({super.key, required this.order});

  @override
  State<PaymentPendingPage> createState() => _PaymentPendingPageState();
}

class _PaymentPendingPageState extends State<PaymentPendingPage>
    with WidgetsBindingObserver {
  bool _payLaunched = false;
  StreamSubscription<PaymentCallbackData>? _callbackSub;

  @override
  void initState() {
    super.initState();
    _log('─────────────────────────────────────────');
    _log('initState | orderId=${widget.order.id} '
        'paymentMethod=${widget.order.paymentMethod} '
        'amount=${widget.order.totalAmount}');

    WidgetsBinding.instance.addObserver(this);

    if (widget.order.paymentMethod == 'global_institute_pay') {
      _log('Akan auto-launch Dompet Kampus Global setelah frame pertama');
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _launchGlobalInstitutePay());
    } else {
      _log('ℹ Metode bukan global_institute_pay → skip auto-launch '
          '(method=${widget.order.paymentMethod})');
    }

    _log('⏱ Memulai polling backend (orderId=${widget.order.id})');
    context.read<OrderProvider>().startPaymentPolling(widget.order.id);

    final pending = GlobalInstitutePayService().consumePendingCallback();
    if (pending != null) {
      _log('Cold-start callback ditemukan: $pending');
      if (pending.isSuccess) {
        _log('Cold-start callback sukses → navigasi ke OrderSuccess');
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _onPaymentSuccess());
      } else {
        _log('Cold-start callback gagal (status=${pending.status})');
      }
    } else {
      _log('ℹ Tidak ada pending cold-start callback');
    }

    _log('Subscribe GlobalInstitutePayService.onCallback stream...');
    _callbackSub = GlobalInstitutePayService().onCallback.listen((data) {
      _log('Callback diterima dari stream: $data');
      if (!mounted) {
        _log('Widget sudah di-dispose, callback diabaikan');
        return;
      }
      if (data.isSuccess) {
        _log('Status sukses → navigasi ke OrderSuccess');
        _onPaymentSuccess();
      } else {
        _log('Status gagal (status=${data.status}) → tampil snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pembayaran gagal atau dibatalkan (status: ${data.status})',
            ),
          ),
        );
      }
    });
    _log('initState selesai.');
  }

  @override
  void dispose() {
    _log('dispose | orderId=${widget.order.id}');
    _callbackSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    context.read<OrderProvider>().stopPaymentPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _log('AppLifecycle: $state | _payLaunched=$_payLaunched');
    if (state == AppLifecycleState.resumed && _payLaunched) {
      _log('Resumed setelah launch → cek status sekali '
          '(orderId=${widget.order.id})');
      context.read<OrderProvider>().checkPaymentStatus(widget.order.id);
    }
  }

  Future<void> _launchGlobalInstitutePay() async {
    _log('─── _launchGlobalInstitutePay ───');
    _log('orderId=${widget.order.id} | amount=${widget.order.totalAmount} '
        '| notes="${widget.order.notes}"');

    final notes = widget.order.notes.isNotEmpty ? widget.order.notes : null;

    final deeplinkUrl = GlobalInstitutePayService.buildDeeplinkUrl(
      orderId: widget.order.id,
      amount: widget.order.totalAmount,
      description: notes,
    );

    final uri = Uri.parse(deeplinkUrl);
    _log('URI yang akan diluncurkan: $uri');

    _log('Mengecek canLaunchUrl (diagnosis saja)...');
    final canLaunch = await canLaunchUrl(uri);
    _log('canLaunchUrl → $canLaunch');
    if (!canLaunch) {
      _log('canLaunchUrl=false — tetap mencoba launchUrl langsung...');
    }

    _log('Memanggil launchUrl (mode=externalApplication)...');
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      _log('launchUrl → $launched');
      if (launched) {
        _log('Dompet Kampus Global berhasil dibuka');
        setState(() => _payLaunched = true);
      } else {
        _log('launchUrl=false — aplikasi ada tapi tidak merespons');
        if (!mounted) return;
        _showAppNotFoundDialog();
      }
    } catch (e) {
      _log('Exception launchUrl: $e');
      _log('→ Aplikasi Dompet Kampus Global kemungkinan tidak terinstal');
      if (!mounted) return;
      _showAppNotFoundDialog();
    }
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp. ${buffer.toString().split('').reversed.join()}';
  }

  void _onPaymentSuccess() {
    _log('_onPaymentSuccess dipanggil — hentikan polling & navigasi');
    context.read<OrderProvider>().stopPaymentPolling();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.orderSuccess,
      (route) => route.settings.name == AppRouter.dashboard,
      arguments: context.read<OrderProvider>().lastOrder ?? widget.order,
    );
  }

  void _showAppNotFoundDialog() {
    _log('Menampilkan dialog: aplikasi tidak ditemukan');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aplikasi Tidak Ditemukan'),
        content: const Text(
          'Aplikasi Dompet Kampus Global tidak terinstal di perangkat ini. '
          'Pesanan Anda tetap tersimpan dan bisa dibayar nanti dari halaman '
          '"Pesanan Saya".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('MENGERTI'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<OrderProvider>()
                  .checkPaymentStatus(widget.order.id);
            },
            child: const Text('CEK STATUS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final payStatus = orderProv.paymentCheckStatus;
    final order = orderProv.lastOrder ?? widget.order;

    if (payStatus == PaymentCheckStatus.paid) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onPaymentSuccess());
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showCancelConfirmation();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PEMBAYARAN'),
          leading: IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _showCancelConfirmation,
          ),
        ),
        body: order.paymentMethod == 'virtual_account'
            ? _VirtualAccountBody(
                order: order,
                payStatus: payStatus,
                formatPrice: _formatPrice,
                onCheckStatus: () =>
                    context.read<OrderProvider>().checkPaymentStatus(order.id),
              )
            : _GlobalInstitutePayBody(
                order: order,
                payStatus: payStatus,
                formatPrice: _formatPrice,
                payLaunched: _payLaunched,
                onOpenApp: _launchGlobalInstitutePay,
                onCheckStatus: () =>
                    context.read<OrderProvider>().checkPaymentStatus(order.id),
              ),
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text(
          'Pesanan tetap tersimpan. Kamu bisa bayar nanti di '
          'halaman "Pesanan Saya".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('LANJUTKAN BAYAR'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.dashboard,
                (route) => false,
              );
            },
            child: Text(
              'BAYAR NANTI',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Virtual Account Body ─────────────────────────────────────
class _VirtualAccountBody extends StatelessWidget {
  final OrderModel order;
  final PaymentCheckStatus payStatus;
  final String Function(double) formatPrice;
  final VoidCallback onCheckStatus;

  const _VirtualAccountBody({
    required this.order,
    required this.payStatus,
    required this.formatPrice,
    required this.onCheckStatus,
  });

  static const List<_BankInfo> _banks = [
    _BankInfo('BCA', '888'),
    _BankInfo('Mandiri', '888'),
    _BankInfo('BNI', '8808'),
    _BankInfo('BRI', '889'),
  ];

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final vaNumber = order.vaNumber ?? '-';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          children: [
            SwissLabel('Pasar Malam · VA · 04'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: onSurface, width: 1),
              ),
              child: Text(
                'VIRTUAL ACCOUNT',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(width: 24, height: 1, color: onSurface),
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: onSurface, width: 1),
            ),
            child: Icon(Icons.credit_card_outlined, size: 26),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Selesaikan Pembayaran\nvia Virtual Account',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  height: 1.15,
                  letterSpacing: -0.3,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: SwissNumber(
            'ORDER #${order.id} · ${formatPrice(order.totalAmount)}',
            size: 12,
          ),
        ),

        const SizedBox(height: 32),
        SwissLabel('Nomor Virtual Account'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: onSurface, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  vaNumber,
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: vaNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nomor VA disalin'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
                tooltip: 'Salin nomor VA',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: onSurface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL PEMBAYARAN',
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              Text(
                formatPrice(order.totalAmount),
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        SwissLabel('Cara Pembayaran'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: onSurface, width: 1),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _banks.length; i++) ...[
                _BankStepTile(bank: _banks[i]),
                if (i < _banks.length - 1) const SwissHairline(),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),
        SwissOutlineButton(
          label: 'Cek Status Pembayaran',
          icon: Icons.refresh,
          loading: payStatus == PaymentCheckStatus.checking,
          onPressed: payStatus == PaymentCheckStatus.checking
              ? null
              : onCheckStatus,
        ),

        if (payStatus == PaymentCheckStatus.idle) ...[
          const SizedBox(height: 16),
          Center(
            child: SwissLabel('Belum ada pembayaran terdeteksi'),
          ),
        ],
      ],
    );
  }
}

class _BankInfo {
  final String name;
  final String prefix;

  const _BankInfo(this.name, this.prefix);
}

class _BankStepTile extends StatelessWidget {
  final _BankInfo bank;

  const _BankStepTile({required this.bank});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: onSurface, width: 1),
            ),
            child: Text(
              bank.name,
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BANK ${bank.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  'Transfer → Virtual Account → masukkan nomor VA',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Global Institute Pay Body ────────────────────────────────
class _GlobalInstitutePayBody extends StatelessWidget {
  final OrderModel order;
  final PaymentCheckStatus payStatus;
  final String Function(double) formatPrice;
  final bool payLaunched;
  final VoidCallback onOpenApp;
  final VoidCallback onCheckStatus;

  const _GlobalInstitutePayBody({
    required this.order,
    required this.payStatus,
    required this.formatPrice,
    required this.payLaunched,
    required this.onOpenApp,
    required this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          children: [
            SwissLabel('Pasar Malam · Pay · 04'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: onSurface, width: 1),
              ),
              child: Text(
                'GLOBAL INSTITUTE PAY',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(width: 24, height: 1, color: onSurface),
        const SizedBox(height: 24),

        Center(
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: onSurface, width: 1),
            ),
            child: Icon(Icons.school_outlined, size: 26),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Bayar dengan\nGlobal Institute Pay',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  height: 1.15,
                  letterSpacing: -0.3,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: SwissNumber(
            'ORDER #${order.id} · ${formatPrice(order.totalAmount)}',
            size: 12,
          ),
        ),

        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: onSurface, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pembayaran akan diverifikasi dengan PIN dan kode 2FA di '
                  'aplikasi Dompet Kampus Global.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: onSurface, width: 1),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwissLabel('Langkah Pembayaran'),
              const SizedBox(height: 8),
              Container(width: 16, height: 1, color: onSurface),
              const SizedBox(height: 16),
              _StepItem(
                number: '1',
                text: payLaunched
                    ? 'Aplikasi Dompet Kampus Global sudah dibuka'
                    : 'Kamu akan diarahkan ke Dompet Kampus Global',
                done: payLaunched,
              ),
              const SizedBox(height: 14),
              _StepItem(
                number: '2',
                text:
                    'Masukkan PIN dan kode verifikasi 2FA, lalu konfirmasi '
                    'pembayaran ${formatPrice(order.totalAmount)}',
                done: false,
              ),
              const SizedBox(height: 14),
              _StepItem(
                number: '3',
                text:
                    'Kembali ke aplikasi — status diperbarui otomatis via '
                    'callback atau polling',
                done: false,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        SwissPrimaryButton(
          label: payLaunched
              ? 'Buka Kembali Dompet Kampus'
              : 'Buka Dompet Kampus',
          icon: Icons.open_in_new,
          onPressed: onOpenApp,
        ),
        const SizedBox(height: 12),
        SwissOutlineButton(
          label: 'Cek Status Pembayaran',
          icon: Icons.refresh,
          loading: payStatus == PaymentCheckStatus.checking,
          onPressed: payStatus == PaymentCheckStatus.checking
              ? null
              : onCheckStatus,
        ),

        if (payStatus == PaymentCheckStatus.idle && payLaunched) ...[
          const SizedBox(height: 16),
          Center(
            child: SwissLabel(
              'Menunggu konfirmasi dari Dompet Kampus Global...',
            ),
          ),
        ],
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String text;
  final bool done;

  const _StepItem({
    required this.number,
    required this.text,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwissNumberBox(number: number, filled: done),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: done
                        ? onSurface
                        : onSurface.withValues(alpha: 0.85),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}