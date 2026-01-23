import 'package:equatable/equatable.dart';
import 'sale_item.dart';

class Sale extends Equatable {
  final String id;
  final String invoiceNumber;
  final String? customerId;
  final double totalAmount;
  final double discount;
  final double tax;
  final String paymentMethod;
  final DateTime saleDate;
  final DateTime createdAt;
  final List<SaleItem>? items; // Optional, loaded when needed

  const Sale({
    required this.id,
    required this.invoiceNumber,
    this.customerId,
    required this.totalAmount,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.paymentMethod,
    required this.saleDate,
    required this.createdAt,
    this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'total_amount': totalAmount,
      'discount': discount,
      'tax': tax,
      'payment_method': paymentMethod,
      'sale_date': saleDate.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      invoiceNumber: map['invoice_number'],
      customerId: map['customer_id'],
      totalAmount: (map['total_amount'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      paymentMethod: map['payment_method'],
      saleDate: DateTime.fromMillisecondsSinceEpoch(map['sale_date']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  Sale copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    double? totalAmount,
    double? discount,
    double? tax,
    String? paymentMethod,
    DateTime? saleDate,
    DateTime? createdAt,
    List<SaleItem>? items,
  }) {
    return Sale(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      saleDate: saleDate ?? this.saleDate,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        customerId,
        totalAmount,
        discount,
        tax,
        paymentMethod,
        saleDate,
        createdAt,
        items,
      ];
}
