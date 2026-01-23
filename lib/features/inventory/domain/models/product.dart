import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String? sku;
  final String? barcode;
  final String? categoryId;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final int minStockLevel;
  final String? description;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    this.categoryId,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    this.minStockLevel = 0,
    this.description,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? barcode,
    String? categoryId,
    double? costPrice,
    double? sellingPrice,
    int? stockQuantity,
    int? minStockLevel,
    String? description,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'category_id': categoryId,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'min_stock_level': minStockLevel,
      'description': description,
      'image_path': imagePath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      sku: map['sku'],
      barcode: map['barcode'],
      categoryId: map['category_id'],
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: (map['stock_quantity'] as num?)?.toInt() ?? 0,
      minStockLevel: (map['min_stock_level'] as num?)?.toInt() ?? 0,
      description: map['description'],
      imagePath: map['image_path'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sku,
        barcode,
        categoryId,
        costPrice,
        sellingPrice,
        stockQuantity,
        minStockLevel,
        description,
        imagePath,
        createdAt,
        updatedAt,
      ];
}
