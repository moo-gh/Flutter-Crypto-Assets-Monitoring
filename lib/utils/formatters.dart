import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionFormatters {
  static String formatDate(String date) {
    // The date comes in format "1400-10-21 03:30:00" (Persian calendar)
    // We'll just display it as-is for now
    return date;
  }

  static String formatPrice(double price, String market) {
    final formatter = NumberFormat('#,##0.##', 'en_US');
    final formattedPrice = formatter.format(price);
    
    // Add currency symbol based on market
    if (market.toLowerCase() == 'usdt') {
      return '\$$formattedPrice';
    } else if (market.toLowerCase() == 'irt') {
      return '$formattedPrice IRT';
    }
    return formattedPrice;
  }

  static Color getPercentageColor(double percentage) {
    if (percentage > 0) {
      return Colors.green;
    } else if (percentage < 0) {
      return Colors.red;
    }
    return Colors.grey;
  }

  static Color getProfitLossColor(double profitLoss) {
    if (profitLoss > 0) {
      return Colors.green;
    } else if (profitLoss < 0) {
      return Colors.red;
    }
    return Colors.grey;
  }

  static IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return Icons.arrow_downward;
      case 'sell':
        return Icons.arrow_upward;
      default:
        return Icons.swap_horiz;
    }
  }

  static Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return Colors.green;
      case 'sell':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
