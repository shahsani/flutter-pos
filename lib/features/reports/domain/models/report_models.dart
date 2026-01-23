class SalesReport {
  final double totalSales;
  final int totalTransactions;
  final double averageTransactionValue;
  final int totalItemsSold;

  const SalesReport({
    required this.totalSales,
    required this.totalTransactions,
    required this.averageTransactionValue,
    required this.totalItemsSold,
  });
}

class TopSellingItem {
  final String productId;
  final String productName;
  final int quantitySold;
  final double totalRevenue;

  const TopSellingItem({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
  });
}
