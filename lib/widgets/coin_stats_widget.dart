import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

class CoinStatsWidget extends StatelessWidget {
  final CoinStats coinStats;
  final Coin selectedCoin;

  const CoinStatsWidget({
    super.key,
    required this.coinStats,
    required this.selectedCoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: coinStats.totalProfitLoss >= 0
              ? [Colors.green.shade50, Colors.green.shade100]
              : [Colors.red.shade50, Colors.red.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: coinStats.totalProfitLoss >= 0
              ? Colors.green.shade300
              : Colors.red.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header with coin name and icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedCoin.title} (${selectedCoin.code})',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: coinStats.totalProfitLoss >= 0
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  coinStats.totalProfitLoss >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: coinStats.totalProfitLoss >= 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Current Price and Total P&L
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TransactionFormatters.formatPrice(coinStats.currentPrice, 'irt'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Total Profit/Loss
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total P&L',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${coinStats.totalProfitLoss >= 0 ? '+' : ''}${TransactionFormatters.formatPrice(coinStats.totalProfitLoss.abs(), 'irt')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: coinStats.totalProfitLoss >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
