import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final String id;
  final String saleId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final double discount;

  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.discount = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'discount': discount,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      quantity: (map['quantity'] as num).toInt(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        saleId,
        productId,
        quantity,
        unitPrice,
        subtotal,
        discount,
      ];
}
