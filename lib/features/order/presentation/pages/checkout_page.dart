import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/core/widgets/swiss.dart';
import 'package:pasar_malam/features/cart/presentation/providers/cart_provider.dart';
import 'package:pasar_malam/features/order/presentation/providers/order_provider.dart';
import 'package:provider/provider.dart';

void _log(String msg) => debugPrint('[PasarMalam/Checkout] $msg');

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _selectedPaymentMethod;

  static const List<_PaymentOption> _paymentOptions = [
    _PaymentOption(
      value: 'global_institute_pay',
      label: 'Global Institute Pay',
      subtitle: 'Bayar via Dompet Kampus Global',
      icon: Icons.school_outlined,
    ),
    _PaymentOption(
      value: 'bank_transfer',
      label: 'Transfer Bank',
      subtitle: 'BCA · Mandiri · BNI · BRI',
      icon: Icons.account_balance_outlined,
    ),
    _PaymentOption(
      value: 'virtual_account',
      label: 'Virtual Account',
      subtitle: 'Nomor VA otomatis digenerate',
      icon: Icons.credit_card_outlined,
    ),
  ];

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
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

  Future<void> _placeOrder(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu'),
        ),
      );
      return;
    }

    final orderProv = context.read<OrderProvider>();
    final cartProv = context.read<CartProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );

    _log('─── _placeOrder ───');
    _log('Mengirim order | paymentMethod="$_selectedPaymentMethod"');

    final success = await orderProv.checkout(
      shippingAddress: _addressCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      paymentMethod: _selectedPaymentMethod!,
    );

    if (!context.mounted) return;
    Navigator.pop(context);

    _log('checkout selesai | success=$success | error="${orderProv.error}"');

    if (success) {
      await cartProv.clearCart();
      if (!context.mounted) return;

      final order = orderProv.lastOrder!;

      final needsPaymentFlow =
          _selectedPaymentMethod == 'virtual_account' ||
              _selectedPaymentMethod == 'global_institute_pay';

      if (needsPaymentFlow) {
        final orderToPass = order.paymentMethod == _selectedPaymentMethod
            ? order
            : order.copyWith(paymentMethod: _selectedPaymentMethod!);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.paymentPending,
          (route) => route.settings.name == AppRouter.dashboard,
          arguments: orderToPass,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.orderSuccess,
          (route) => route.settings.name == AppRouter.dashboard,
          arguments: order,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderProv.error ?? 'Gagal membuat pesanan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProv = context.watch<CartProvider>();
    final cart = cartProv.cart;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('CHECKOUT')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ── 01 Ringkasan ─────────────────────────────
            const SwissLabel('Pasar Malam · Checkout · 01'),
            const SizedBox(height: 8),
            Container(width: 24, height: 1, color: onSurface),
            const SizedBox(height: 16),
            if (cart != null) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: onSurface, width: 1),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < cart.items.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              (i + 1).toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cart.items[i].product.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${cart.items[i].quantity} × ${_formatPrice(cart.items[i].product.price)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _formatPrice(cart.items[i].subtotal),
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < cart.items.length - 1) const SwissHairline(),
                    ],
                    const SwissHairline(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            _formatPrice(cart.total),
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── 02 Alamat ────────────────────────────────
            const SizedBox(height: 32),
            const SwissLabel('02 · Alamat Pengiriman'),
            const SizedBox(height: 8),
            Container(width: 24, height: 1, color: onSurface),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 3,
              cursorColor: onSurface,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'ALAMAT LENGKAP',
                hintText: 'Jalan, nomor rumah, RT/RW, kelurahan, kecamatan, kota',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Alamat pengiriman wajib diisi';
                }
                return null;
              },
            ),

            // ── 03 Catatan ───────────────────────────────
            const SizedBox(height: 32),
            const SwissLabel('03 · Catatan (opsional)'),
            const SizedBox(height: 8),
            Container(width: 24, height: 1, color: onSurface),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              cursorColor: onSurface,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'CATATAN UNTUK PENJUAL',
                hintText: 'Tambahkan catatan untuk penjual',
              ),
            ),

            // ── 04 Metode Pembayaran ─────────────────────
            const SizedBox(height: 32),
            const SwissLabel('04 · Metode Pembayaran'),
            const SizedBox(height: 8),
            Container(width: 24, height: 1, color: onSurface),
            const SizedBox(height: 16),
            ..._paymentOptions.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PaymentOptionCard(
                  option: option,
                  isSelected: _selectedPaymentMethod == option.value,
                  onSelect: () =>
                      setState(() => _selectedPaymentMethod = option.value),
                ),
              ),
            ),

            // ── Place Order ──────────────────────────────
            const SizedBox(height: 32),
            SwissPrimaryButton(
              label: 'Buat Pesanan',
              icon: Icons.arrow_forward,
              onPressed: () => _placeOrder(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption {
  final String value;
  final String label;
  final String subtitle;
  final IconData icon;

  const _PaymentOption({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}

class _PaymentOptionCard extends StatelessWidget {
  final _PaymentOption option;
  final bool isSelected;
  final VoidCallback onSelect;

  const _PaymentOptionCard({
    required this.option,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onSelect,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: onSurface,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? onSurface.withValues(alpha: 0.04)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: onSurface, width: 1),
              ),
              child: Icon(option.icon, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Radio kotak ala Swiss
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: onSurface, width: 1),
                color: isSelected ? onSurface : Colors.transparent,
              ),
              child: isSelected
                  ? Container(
                      width: 6,
                      height: 6,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}