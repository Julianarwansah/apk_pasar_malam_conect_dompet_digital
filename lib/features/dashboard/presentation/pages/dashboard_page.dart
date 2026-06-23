import 'package:flutter/material.dart';
import 'package:pasar_malam/core/providers/theme_provider.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/core/widgets/swiss.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/cart/presentation/providers/cart_provider.dart';
import 'package:pasar_malam/features/dashboard/data/models/product_model.dart';
import 'package:pasar_malam/features/dashboard/presentation/providers/product_provider.dart';
import 'package:pasar_malam/features/order/presentation/providers/order_provider.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedNav = 0;
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();

  static const List<_CategoryItem> _categories = [
    _CategoryItem(label: 'All', icon: Icons.apps),
    _CategoryItem(label: 'Running', icon: Icons.directions_run),
    _CategoryItem(label: 'Lifestyle', icon: Icons.style),
    _CategoryItem(label: 'Football', icon: Icons.sports_soccer),
    _CategoryItem(label: 'Volleyball', icon: Icons.sports_volleyball),
    _CategoryItem(label: 'Tennis', icon: Icons.sports_tennis),
    _CategoryItem(label: 'Badminton', icon: Icons.sports),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ProductModel> _filteredProducts(List<ProductModel> products) {
    final query = _searchCtrl.text.toLowerCase();
    return products.where((p) {
      final matchCategory = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
      return matchCategory && matchSearch;
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProv = context.watch<ProductProvider>();
    // ignore: unused_local_variable
    final _ = context.watch<OrderProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwissLabel('Pasar Malam · Etalase'),
                        const SizedBox(height: 8),
                        Container(
                          width: 24,
                          height: 1,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Halo,\n${auth.firebaseUser?.displayName ?? "Pembeli"}.',
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    height: 1.1,
                                    letterSpacing: -0.3,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.receipt_long_outlined),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRouter.myOrders,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Search bar ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SearchBar(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
              ),
            ),

            // ── Body scroll ───────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => productProv.fetchProducts(),
                child: CustomScrollView(
                  slivers: [
                    // ── Banner ─────────────────────────────
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: _BannerCard(),
                      ),
                    ),

                    // ── Categories ─────────────────────────
                    SliverToBoxAdapter(
                      child: SwissSection(
                        label: 'Kategori · 01',
                        trailing: TextButton(
                          onPressed: () {},
                          child: const Text('SEMUA'),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _categories.length,
                          separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final cat = _categories[i];
                            return SwissTag(
                              label: cat.label,
                              icon: cat.icon,
                              selected: _selectedCategory == cat.label,
                              onTap: () =>
                                  setState(() => _selectedCategory = cat.label),
                            );
                          },
                        ),
                      ),
                    ),

                    // ── For You label ─────────────────────
                    SliverToBoxAdapter(
                      child: SwissSection(
                        label: 'Untuk Anda · 02',
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      ),
                    ),

                    // ── Product Grid ──────────────────────
                    switch (productProv.status) {
                      ProductStatus.loading || ProductStatus.initial =>
                        const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ProductStatus.error => SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 12),
                                Text(productProv.error ?? 'Terjadi kesalahan'),
                                const SizedBox(height: 16),
                                SwissOutlineButton(
                                  label: 'Coba Lagi',
                                  icon: Icons.refresh,
                                  onPressed: () => productProv.fetchProducts(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ProductStatus.loaded => () {
                          final items = _filteredProducts(productProv.products);
                          if (items.isEmpty) {
                            return const SliverFillRemaining(
                              child: Center(
                                child: Text('Tidak ada produk ditemukan'),
                              ),
                            );
                          }
                          return SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => _ProductCard(
                                  product: items[i],
                                  formatPrice: _formatPrice,
                                ),
                                childCount: items.length,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.6,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                            ),
                          );
                        }(),
                    },
                  ],
                ),
              ),
            ),

            // ── Bottom Navigation ────────────────────────
            _BottomNav(
              selectedIndex: _selectedNav,
              onTap: (i) {
                if (i == 1) {
                  Navigator.pushNamed(context, AppRouter.cart).then((_) {
                    if (context.mounted) {
                      context.read<CartProvider>().fetchCart();
                    }
                  });
                } else if (i == 3) {
                  _showAccountSheet(context, auth);
                } else {
                  setState(() => _selectedNav = i);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountSheet(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      builder: (_) => _AccountSheet(auth: auth),
    );
  }
}

// ── Search Bar ───────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: Theme.of(context).colorScheme.onSurface,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Cari produk, kategori, atau merek',
        prefixIcon: Icon(
          Icons.search,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
      ),
    );
  }
}

// ── Banner ───────────────────────────────────────────────────
class _BannerCard extends StatelessWidget {
  const _BannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Pola garis Swiss samar di background
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SwissLabel('Promo · 01'),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 12,
                      color: Theme.of(context).colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text(
                      '50% OFF',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Koleksi\nBaru.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        height: 0.95,
                        letterSpacing: -1.0,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Diskon hingga 50%\nuntuk transaksi pertama.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'BELANJA SEKARANG',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        decoration: TextDecoration.underline,
                        decorationThickness: 1,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 16.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Product Card ─────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final String Function(double) formatPrice;

  const _ProductCard({required this.product, required this.formatPrice});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isFavorite = false;

  void _showProductDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => _ProductDetailSheet(
        product: widget.product,
        formatPrice: widget.formatPrice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: () => _showProductDetail(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: onSurface, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gambar ────────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: p.imageUrl.isNotEmpty
                        ? Image.network(
                            p.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) =>
                                _imagePlaceholder(context),
                          )
                        : _imagePlaceholder(context),
                  ),
                  // Nomor indeks Swiss
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(color: onSurface, width: 1),
                      ),
                      child: Text(
                        '01',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: onSurface,
                        ),
                      ),
                    ),
                  ),
                  // Heart button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _isFavorite = !_isFavorite),
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          border: Border.all(color: onSurface, width: 1),
                        ),
                        child: Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 14,
                          color: _isFavorite ? onSurface : muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info ───────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.category.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          width: 1,
                          height: 10,
                          color: onSurface,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.6',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ 5.0',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 11,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.formatPrice(p.price),
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Icon(
        Icons.image_outlined,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        size: 40,
      ),
    );
  }
}

// ── Product Detail Bottom Sheet ──────────────────────────────
class _ProductDetailSheet extends StatefulWidget {
  final ProductModel product;
  final String Function(double) formatPrice;

  const _ProductDetailSheet({
    required this.product,
    required this.formatPrice,
  });

  @override
  State<_ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cartProv = context.watch<CartProvider>();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  // Image
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: onSurface, width: 1),
                      ),
                      child: p.imageUrl.isNotEmpty
                          ? Image.network(
                              p.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, error, stack) => _placeholderBox(
                                context,
                                icon: Icons.image_outlined,
                              ),
                            )
                          : _placeholderBox(context, icon: Icons.image_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwissLabel(p.category),
                            const SizedBox(height: 6),
                            Container(
                              width: 24,
                              height: 1,
                              color: onSurface,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              p.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: onSurface, width: 1),
                        ),
                        child: Text(
                          '#${p.id}',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.formatPrice(p.price),
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SwissHairline(),
                  const SizedBox(height: 16),
                  SwissLabel('Deskripsi'),
                  const SizedBox(height: 8),
                  Text(
                    p.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: onSurface.withValues(alpha: 0.8),
                        ),
                  ),
                  const SizedBox(height: 24),
                  SwissLabel('Jumlah'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QtyStep(
                        icon: Icons.remove,
                        onTap: _qty > 1 ? () => setState(() => _qty--) : null,
                      ),
                      Container(
                        width: 56,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: onSurface, width: 1),
                            bottom: BorderSide(color: onSurface, width: 1),
                          ),
                        ),
                        child: Text(
                          '$_qty',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: onSurface,
                          ),
                        ),
                      ),
                      _QtyStep(
                        icon: Icons.add,
                        onTap: () => setState(() => _qty++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SwissHairline(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: SwissPrimaryButton(
                label: 'Tambah ke Keranjang',
                icon: Icons.add_shopping_cart,
                loading: cartProv.isAdding,
                onPressed: cartProv.isAdding
                    ? null
                    : () async {
                        final success = await context
                            .read<CartProvider>()
                            .addToCart(p.id, _qty);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? '${p.name} ditambahkan'
                                  : 'Gagal menambahkan',
                            ),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox(BuildContext context, {required IconData icon}) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Icon(
        icon,
        size: 48,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
      ),
    );
  }
}

class _QtyStep extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyStep({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: disabled
                ? onSurface.withValues(alpha: 0.3)
                : onSurface,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: disabled
              ? onSurface.withValues(alpha: 0.3)
              : onSurface,
        ),
      ),
    );
  }
}

// ── Bottom Navigation ────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(icon: Icons.home_outlined, label: 'Beranda'),
      _NavItem(icon: Icons.shopping_bag_outlined, label: 'Keranjang'),
      _NavItem(icon: Icons.favorite_border, label: 'Favorit'),
      _NavItem(icon: Icons.person_outline, label: 'Akun'),
    ];

    final onSurface = Theme.of(context).colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.5);
    final cartItemCount = context.watch<CartProvider>().itemCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SwissHairline(),
        SafeArea(
          top: false,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: List.generate(items.length, (i) {
                  final selected = selectedIndex == i;
                  final isCart = i == 1;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                items[i].icon,
                                size: 22,
                                color: selected ? onSurface : muted,
                              ),
                              if (isCart && cartItemCount > 0)
                                Positioned(
                                  right: -8,
                                  top: -6,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: onSurface,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      cartItemCount > 99
                                          ? '99+'
                                          : '$cartItemCount',
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items[i].label.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 9,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              letterSpacing: 1.5,
                              color: selected ? onSurface : muted,
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 16,
                              height: 1,
                              color: onSurface,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data classes ─────────────────────────────────────────────
class _CategoryItem {
  final String label;
  final IconData icon;
  const _CategoryItem({required this.label, required this.icon});
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ── Account Sheet ────────────────────────────────────────────
class _AccountSheet extends StatelessWidget {
  final AuthProvider auth;

  const _AccountSheet({required this.auth});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    final name = auth.firebaseUser?.displayName ?? 'User';
    final email = auth.firebaseUser?.email ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                SwissLabel('Akun · 04'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Container(
              width: 24,
              height: 1,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isDark ? 'MODE GELAP' : 'MODE TERANG',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                Switch(
                  value: isDark,
                  onChanged: (_) => context.read<ThemeProvider>().toggle(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SwissHairline(),
            const SizedBox(height: 16),
            _SheetLink(
              icon: Icons.receipt_long_outlined,
              label: 'Pesanan Saya',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.myOrders);
              },
            ),
            const SizedBox(height: 12),
            _SheetLink(
              icon: Icons.shopping_bag_outlined,
              label: 'Keranjang',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.cart);
              },
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await auth.logout();
                if (!context.mounted) return;
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(context, AppRouter.login);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'KELUAR',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SheetLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward, size: 16),
          ],
        ),
      ),
    );
  }
}