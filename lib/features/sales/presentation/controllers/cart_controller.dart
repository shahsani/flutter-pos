import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../../../inventory/domain/models/product.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/sale.dart';
import '../../domain/models/sale_item.dart';
import '../../domain/repositories/sales_repository.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier(ref);
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.subtotal);
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  final Ref _ref;

  CartNotifier(this._ref) : super([]);

  void addProduct(Product product) {
    if (state.any((item) => item.product.id == product.id)) {
      // Increment quantity
      state = [
        for (final item in state)
          if (item.product.id == product.id)
            item.copyWith(quantity: item.quantity + 1)
          else
            item,
      ];
    } else {
      // Add new item
      state = [...state, CartItem(product: product)];
    }
  }

  void removeProduct(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }

  void clearCart() {
    state = [];
  }

  Future<void> checkout(String paymentMethod) async {
    if (state.isEmpty) return;

    final repository = _ref.read(salesRepositoryProvider);
    final invoiceNumber = await repository.generateInvoiceNumber();
    final saleId = const Uuid().v4();
    final now = DateTime.now();

    double totalAmount = state.fold(0, (sum, item) => sum + item.subtotal);

    final sale = Sale(
      id: saleId,
      invoiceNumber: invoiceNumber,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      saleDate: now,
      createdAt: now,
    );

    final saleItems = state.map((cartItem) {
      return SaleItem(
        id: const Uuid().v4(),
        saleId: saleId,
        productId: cartItem.product.id,
        quantity: cartItem.quantity,
        unitPrice: cartItem.unitPrice,
        subtotal: cartItem.subtotal,
        discount: cartItem.discount,
      );
    }).toList();

    await repository.createSale(sale, saleItems);
    clearCart();
  }
}
