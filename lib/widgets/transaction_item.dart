import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: TransactionFormatters.getTypeColor(transaction.type).withOpacity(0.2),
                      child: Icon(
                        TransactionFormatters.getTypeIcon(transaction.type),
                        size: 16,
                        color: TransactionFormatters.getTypeColor(transaction.type),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      transaction.coin,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  TransactionFormatters.formatDate(transaction.date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchase Price',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      TransactionFormatters.formatPrice(transaction.price, transaction.market),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      transaction.quantity.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Value',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      TransactionFormatters.formatPrice(transaction.totalPrice, transaction.market),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Current Value',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      TransactionFormatters.formatPrice(transaction.currentValue, transaction.market),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TransactionFormatters.getPercentageColor(transaction.changePercentage),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Profit/Loss Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profit/Loss',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${transaction.profitLoss >= 0 ? '+' : ''}${TransactionFormatters.formatPrice(transaction.profitLoss.abs(), transaction.market)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TransactionFormatters.getProfitLossColor(transaction.profitLoss),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: TransactionFormatters.getPercentageColor(transaction.changePercentage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '${transaction.changePercentage > 0 ? '+' : ''}${transaction.changePercentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: TransactionFormatters.getPercentageColor(transaction.changePercentage),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
