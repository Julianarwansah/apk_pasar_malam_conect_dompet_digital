import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/core/widgets/swiss.dart';
import 'package:pasar_malam/features/cart/data/models/cart_model.dart';
import 'package:pasar_malam/features/cart/presentation/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
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

  Future<void> _confirmClearCart(BuildContext context, CartProvider cartProv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kosongkan Keranjang'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus semua item dari keranjang?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'HAPUS SEMUA',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await cartProv.clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KERANJANG'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProv, _) {
              final hasItems =
                  cartProv.cart != null && cartProv.cart!.items.isNotEmpty;
              if (!hasItems) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: 'Hapus Semua',
                onPressed: () => _confirmClearCart(context, cartProv),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProv, _) {
          if (cartProv.status == CartStatus.loading ||
              cartProv.status == CartStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProv.status == CartStatus.error) {
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
                  Text(cartProv.error ?? 'Terjadi kesalahan'),
                  const SizedBox(height: 16),
                  SwissOutlineButton(
                    label: 'Coba Lagi',
                    icon: Icons.refresh,
                    onPressed: () => cartProv.fetchCart(),
                  ),
                ],
              ),
            );
          }

          final cart = cartProv.cart;
          if (cart == null || cart.items.isEmpty) {
            return const _EmptyCartView();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SwissLabel('Pasar Malam · Keranjang · 02'),
                    SwissNumber('${cart.items.length} ITEM'),
                  ],
                ),
              ),
              const SwissHairline(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cartProv.fetchCart(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (ctx, i) => _CartItemCard(
                      item: cart.items[i],
                      formatPrice: _formatPrice,
                      index: i + 1,
                      onRemove: () => cartProv.removeItem(cart.items[i].id),
                      onDecrease: () {
                        final qty = cart.items[i].quantity - 1;
                        if (qty <= 0) {
                          cartProv.removeItem(cart.items[i].id);
                        } else {
                          cartProv.updateItem(cart.items[i].id, qty);
                        }
                      },
                      onIncrease: () => cartProv.updateItem(
                        cart.items[i].id,
                        cart.items[i].quantity + 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SwissHairline(),
              _CartBottomBar(
                total: cart.total,
                formatPrice: _formatPrice,
                onCheckout: () {
                  Navigator.pushNamed(context, AppRouter.checkout);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Empty Cart View ──────────────────────────────────────────
class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
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
                Icons.shopping_bag_outlined,
                size: 28,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Container(width: 24, height: 1, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(height: 24),
            Text(
              'KERANJANG\nKOSONG.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Yuk, tambahkan produk ke keranjang.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 32),
            SwissPrimaryButton(
              label: 'Mulai Belanja',
              icon: Icons.arrow_forward,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cart Item Card ───────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final String Function(double) formatPrice;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _CartItemCard({
    required this.item,
    required this.formatPrice,
    required this.index,
    required this.onRemove,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.6);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: onSurface, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: onSurface, width: 1),
              ),
              child: item.product.imageUrl.isNotEmpty
                  ? Image.network(
                      item.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stack) => _placeholder(context),
                    )
                  : _placeholder(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: muted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 10, color: muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.product.category.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onRemove,
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          height: 1.2,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatPrice(item.product.price),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _QtyButton(icon: Icons.remove, onTap: onDecrease),
                          Container(
                            width: 40,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: onSurface, width: 1),
                                bottom: BorderSide(color: onSurface, width: 1),
                              ),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          _QtyButton(icon: Icons.add, onTap: onIncrease),
                        ],
                      ),
                      Text(
                        formatPrice(item.subtotal),
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Icon(
          Icons.image_outlined,
          size: 28,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 1,
          ),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }
}

// ── Bottom Bar ───────────────────────────────────────────────
class _CartBottomBar extends StatelessWidget {
  final double total;
  final String Function(double) formatPrice;
  final VoidCallback onCheckout;

  const _CartBottomBar({
    required this.total,
    required this.formatPrice,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwissLabel('Total'),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(total),
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.arrow_forward, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'CHECKOUT',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}