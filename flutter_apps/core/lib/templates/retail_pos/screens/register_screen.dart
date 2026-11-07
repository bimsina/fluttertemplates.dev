import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/pos_scope.dart';
import '../widgets/category_bar.dart';
import '../widgets/panel.dart';
import '../widgets/product_tile.dart';
import '../widgets/scan_field.dart';
import '../widgets/till_tape.dart';

/// Catalogue and tape side by side on tablets. On phones the tape collapses
/// into a bar above the navigation.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const _splitBreakpoint = 820.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _splitBreakpoint) {
          return Row(
            children: [
              const Expanded(child: _Catalog()),
              SizedBox(
                width: constraints.maxWidth >= 1100 ? 400 : 348,
                child: const SafeArea(
                  left: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 14, 14, 14),
                    child: TillTape(),
                  ),
                ),
              ),
            ],
          );
        }
        return const Column(
          children: [
            Expanded(child: _Catalog()),
            TapeBar(),
          ],
        );
      },
    );
  }
}

class _Catalog extends StatefulWidget {
  const _Catalog();

  @override
  State<_Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<_Catalog> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _categoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _visible(List<Product> products) {
    final query = _query.trim().toLowerCase();
    return products
        .where((product) {
          if (_categoryId != null && product.categoryId != _categoryId) {
            return false;
          }
          return query.isEmpty ||
              product.name.toLowerCase().contains(query) ||
              product.sku.contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final products = _visible(store.products);
    final textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final header = _CatalogHeader(
          sideBySide: constraints.maxWidth >= 520,
          searchController: _searchController,
          onSearch: (value) => setState(() => _query = value),
          categoryId: _categoryId,
          onCategory: (id) => setState(() => _categoryId = id),
        );

        return CustomScrollView(
          slivers: [
            // Keep the scan field in reach, unless the keyboard leaves so
            // little height that a pinned header would cover the grid.
            if (constraints.maxHeight >= 460)
              PinnedHeaderSliver(child: header)
            else
              SliverToBoxAdapter(child: header),
            if (products.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: EmptyMessage(
                    icon: Icons.search_off_rounded,
                    message: 'No products match this search.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 158,
                    mainAxisExtent: textScaler.scale(150),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductTile(
                      key: ValueKey(product.id),
                      product: product,
                      toneIndex: store.categoryIndex(product.categoryId),
                      inCart: store.cart.quantityOf(product.id),
                      onAdd: () => store.addToCart(product),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({
    required this.sideBySide,
    required this.searchController,
    required this.onSearch,
    required this.categoryId,
    required this.onCategory,
  });

  final bool sideBySide;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final String? categoryId;
  final ValueChanged<String?> onCategory;

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final search = TextField(
      controller: searchController,
      onChanged: onSearch,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Search products',
        prefixIcon: Icon(Icons.search_rounded, size: 20),
      ),
    );

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: sideBySide
                  ? Row(
                      children: [
                        const Expanded(child: ScanField()),
                        const SizedBox(width: 8),
                        Expanded(child: search),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ScanField(),
                        const SizedBox(height: 8),
                        search,
                      ],
                    ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 16, 8),
              child: ScanStatus(),
            ),
            CategoryBar(
              categories: store.categories,
              selectedId: categoryId,
              onSelected: onCategory,
            ),
          ],
        ),
      ),
    );
  }
}
