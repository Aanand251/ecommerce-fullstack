import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_shimmer_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.desktopBreakpoint;
    final isMobile = width < AppConstants.mobileBreakpoint;

    return AppShell(
      title: 'Premium Store',
      padding: EdgeInsets.zero,
      child: RefreshIndicator(
        onRefresh: () => ref.read(productsProvider.notifier).refreshProducts(),
        child: CustomScrollView(
          slivers: [
            // Hero Section with Search
            SliverToBoxAdapter(
              child: _buildHeroSection(isDesktop, isMobile),
            ),

            // Categories
            SliverToBoxAdapter(
              child: _buildCategoriesSection(),
            ),

            // Products Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 32,
                  24,
                  isMobile ? 16 : 32,
                  16,
                ),
                child: const SectionHeader(
                  title: 'Featured Products',
                  subtitle: 'Discover our curated collection',
                ),
              ),
            ),

            // Products Grid
            productsState.when(
              data: (products) {
                if (products.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: Iconsax.box,
                      title: 'No products available',
                      description: 'Check back later for new arrivals',
                      actionLabel: 'Refresh',
                      onAction: () => ref.read(productsProvider.notifier).refreshProducts(),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                  ),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final gridWidth = constraints.crossAxisExtent;
                      final crossAxisCount = gridWidth >= 1280
                          ? 5
                          : gridWidth >= 1024
                              ? 4
                              : gridWidth >= 700
                                  ? 3
                                  : 2;

                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= products.length) return null;
                            return ProductCard(product: products[index]);
                          },
                          childCount: products.length,
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
                sliver: const SliverToBoxAdapter(
                  child: ProductShimmerGrid(),
                ),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                child: ErrorState(
                  title: 'Failed to load products',
                  description: error.toString(),
                  onRetry: () => ref.read(productsProvider.notifier).refreshProducts(),
                ),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop, bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 16 : 32,
        16,
        isMobile ? 16 : 32,
        8,
      ),
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF2D2D44),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'NEW ARRIVALS',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    Text(
                      'Discover Premium\nProducts',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: isMobile ? 28 : 38,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Explore our exclusive collection of handpicked items',
                      style: TextStyle(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                        fontSize: isMobile ? 14 : 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 40),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.shopping_bag5,
                    size: 80,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: isMobile ? 24 : 32),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(Iconsax.search_normal, color: AppColors.textTertiary, size: 22),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    ),
                    onSubmitted: (value) {
                      // TODO: Implement search
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(6),
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement search
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Iconsax.arrow_right_3, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = ['All', 'Electronics', 'Clothing', 'Home', 'Sports'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _selectedCategory == category;

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CategoryChip(
                label: category,
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedCategory = category);
                  // TODO: Filter by category
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
