class Transaction {
  final int id;
  final String type;
  final String market;
  final String coin;
  final double price;
  final double quantity;
  final double totalPrice;
  final double currentValue;
  final String date;
  final double changePercentage;
  final double profitLoss;

  Transaction({
    required this.id,
    required this.type,
    required this.market,
    required this.coin,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.currentValue,
    required this.date,
    required this.changePercentage,
    required this.profitLoss,
  });

  // Check if this transaction is profitable
  bool get isProfitable => profitLoss > 0;

  // Check if this transaction has a loss
  bool get hasLoss => profitLoss < 0;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'] ?? '',
      market: json['market'] ?? '',
      coin: json['coin'] ?? '',
      price: double.tryParse(json['price']?.toString().replaceAll(',', '') ?? '0') ?? 0,
      quantity: double.tryParse(json['quantity']?.toString().replaceAll(',', '') ?? '0') ?? 0,
      totalPrice: double.tryParse(json['total_price']?.toString().replaceAll(',', '') ?? '0') ?? 0,
      currentValue: double.tryParse(json['current_value']?.toString().replaceAll(',', '') ?? '0') ?? 0,
      date: json['date'] ?? '',
      changePercentage: double.tryParse(json['change_percentage']?.toString().replaceAll(',', '') ?? '0') ?? 0,
      profitLoss: double.tryParse(json['profit_loss']?.toString().replaceAll(',', '') ?? '0') ?? 0,
    );
  }
}

class CoinStats {
  final double totalProfitLoss;
  final double currentPrice;

  CoinStats({
    required this.totalProfitLoss,
    required this.currentPrice,
  });

  factory CoinStats.fromJson(Map<String, dynamic> json) {
    return CoinStats(
      totalProfitLoss: double.tryParse(json['total_profit_loss']?.toString().replaceAll(',', '') ?? '0') ?? 0,
      currentPrice: double.tryParse(json['current_price']?.toString().replaceAll(',', '') ?? '0') ?? 0,
    );
  }
}

class TransactionsResponse {
  final int count;
  final String? next;
  final String? previous;
  final CoinStats? coinStats;
  final List<Transaction> results;

  TransactionsResponse({
    required this.count,
    this.next,
    this.previous,
    this.coinStats,
    required this.results,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    return TransactionsResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      coinStats: json['coin_stats'] != null ? CoinStats.fromJson(json['coin_stats']) : null,
      results: (json['results'] as List<dynamic>?)
          ?.map((item) => Transaction.fromJson(item))
          .toList() ?? [],
    );
  }
}
