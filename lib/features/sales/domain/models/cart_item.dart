import '../../../inventory/domain/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final double discount; // Per unit discount

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0.0,
  });

  double get unitPrice => product.sellingPrice;
  
  double get subtotal => (unitPrice * quantity) - (discount * quantity);

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? discount,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }
}
