import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../inventory/domain/models/product.dart';
import '../../inventory/domain/repositories/product_repository.dart';
import 'controllers/cart_controller.dart';
import 'widgets/cart_view.dart';
import '../../../../core/widgets/app_drawer.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Sales Register'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => GoRouter.of(context).push('/sales/history'),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Side: Product Grid
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      // TODO: Implement local filtering
                    },
                  ),
                ),
                Expanded(
                  child: productsAsync.when(
                    data: (products) => ProductGrid(products: products),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right Side: Cart
          const Expanded(flex: 2, child: CartView()),
        ],
      ),
    );
  }
}

class ProductGrid extends ConsumerWidget {
  final List<Product> products;

  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const Center(child: Text('No products available'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          onTap: () {
            ref.read(cartProvider.notifier).addProduct(product);
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.inventory_2,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.sellingPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
