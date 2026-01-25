class SalesReport {
  final double totalSales;
  final int totalTransactions;
  final double averageTransactionValue;
  final int totalItemsSold;
  final double totalCashSales;
  final double totalCardSales;

  const SalesReport({
    required this.totalSales,
    required this.totalTransactions,
    required this.averageTransactionValue,
    required this.totalItemsSold,
    required this.totalCashSales,
    required this.totalCardSales,
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
