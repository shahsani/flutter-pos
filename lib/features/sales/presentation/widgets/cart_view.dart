import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/cart_controller.dart';

class CartView extends ConsumerWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Column(
      children: [
        Expanded(
          child: cartItems.isEmpty
              ? const Center(child: Text('Cart is empty'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return ListTile(
                      dense: true,
                      title: Text(item.product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\$${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .removeProduct(item.product.id);
                            },
                          )
                        ],
                      ),
                      onTap: () {
                        // TODO: Adjust quantity dialog
                      },
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: cartItems.isEmpty
                      ? null
                      : () => _showPaymentDialog(context, ref, total),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: const Text('CHARGE'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPaymentDialog(BuildContext context, WidgetRef ref, double total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Checkout \$${total.toStringAsFixed(2)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Cash'),
              onTap: () => _processPayment(context, ref, 'Cash'),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Card'),
              onTap: () => _processPayment(context, ref, 'Card'),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(
      BuildContext context, WidgetRef ref, String method) async {
    Navigator.pop(context); // Close dialog
    try {
      await ref.read(cartProvider.notifier).checkout(method);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale completed successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
