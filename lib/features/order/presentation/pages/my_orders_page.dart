import 'package:flutter/material.dart';
import 'package:pasar_malam/core/widgets/swiss.dart';
import 'package:pasar_malam/features/order/data/models/order_model.dart';
import 'package:pasar_malam/features/order/presentation/providers/order_provider.dart';
import 'package:provider/provider.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchMyOrders();
    });
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

  String _formatDate(String createdAt) {
    if (createdAt.isEmpty) return '-';
    try {
      final dt = DateTime.parse(createdAt);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PESANAN SAYA')),
      body: Consumer<OrderProvider>(
        builder: (context, orderProv, _) {
          if (orderProv.checkoutStatus == OrderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProv.checkoutStatus == OrderStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(orderProv.error ?? 'Terjadi kesalahan'),
                  const SizedBox(height: 16),
                  SwissOutlineButton(
                    label: 'Coba Lagi',
                    icon: Icons.refresh,
                    onPressed: () => orderProv.fetchMyOrders(),
                  ),
                ],
              ),
            );
          }

          if (orderProv.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
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
                        Icons.receipt_long_outlined,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 24,
                      height: 1,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'BELUM ADA\nPESANAN.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            height: 1.0,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pesanan Anda akan muncul di sini.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderProv.fetchMyOrders(),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SwissLabel('Pasar Malam · Pesanan · 04'),
                        SwissNumber('${orderProv.orders.length} ITEM'),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SwissHairline()),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList.separated(
                    itemCount: orderProv.orders.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                    itemBuilder: (ctx, i) => _OrderCard(
                      order: orderProv.orders[i],
                      index: i + 1,
                      formatPrice: _formatPrice,
                      formatDate: _formatDate,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Order Card ───────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final int index;
  final String Function(double) formatPrice;
  final String Function(String) formatDate;

  const _OrderCard({
    required this.order,
    required this.index,
    required this.formatPrice,
    required this.formatDate,
  });

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'MENUNGGU PEMBAYARAN';
      case 'processing':
        return 'SEDANG DIPROSES';
      case 'shipped':
        return 'DIKIRIM';
      case 'delivered':
        return 'DITERIMA';
      case 'cancelled':
        return 'DIBATALKAN';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: onSurface, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: muted,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 12, color: muted),
                const SizedBox(width: 8),
                Text(
                  'ORDER #${order.id}',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: onSurface, width: 1),
                  ),
                  child: Text(
                    _statusLabel(order.status),
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(width: 16, height: 1, color: muted),
            const SizedBox(height: 12),
            Text(
              formatDate(order.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} ITEM',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  formatPrice(order.totalAmount),
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
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