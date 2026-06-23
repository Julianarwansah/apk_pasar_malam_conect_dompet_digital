import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/core/widgets/swiss.dart';
import 'package:pasar_malam/features/order/data/models/order_model.dart';

class OrderSuccessPage extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessPage({super.key, required this.order});

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

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'gopay':
        return 'GoPay';
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'virtual_account':
        return 'Virtual Account';
      case 'global_institute_pay':
        return 'Global Institute Pay';
      default:
        return method;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Sedang Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Diterima';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('STATUS PESANAN'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const SwissLabel('Pasar Malam · Sukses · 03'),
              const SizedBox(height: 8),
              Container(
                width: 24,
                height: 1,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'PESANAN\nBERHASIL.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        height: 1.0,
                        letterSpacing: -0.5,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SwissNumber(
                  'ORDER #${order.id}',
                  size: 12,
                ),
              ),
              const SizedBox(height: 32),
              // Info box
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Metode Pembayaran',
                      value: _paymentMethodLabel(order.paymentMethod),
                    ),
                    const SwissHairline(),
                    _InfoRow(
                      label: 'Total Pembayaran',
                      value: _formatPrice(order.totalAmount),
                      mono: true,
                    ),
                    const SwissHairline(),
                    _InfoRow(
                      label: 'Status',
                      value: _statusLabel(order.status).toUpperCase(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SwissOutlineButton(
                label: 'Lihat Detail Pesanan',
                icon: Icons.receipt_long_outlined,
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.myOrders);
                },
              ),
              const SizedBox(height: 12),
              SwissPrimaryButton(
                label: 'Kembali ke Beranda',
                icon: Icons.home_outlined,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.dashboard,
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const _InfoRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwissLabel(label),
          const SizedBox(height: 6),
          Container(
            width: 16,
            height: 1,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: mono
                ? TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )
                : Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}