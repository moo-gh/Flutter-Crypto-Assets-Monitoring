import 'package:flutter/material.dart';
import '../models/coin.dart';

class FilterActions extends StatelessWidget {
  final Coin? selectedCoin;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int transactionCount;
  final VoidCallback onClearAllFilters;

  const FilterActions({
    super.key,
    this.selectedCoin,
    this.dateFrom,
    this.dateTo,
    required this.transactionCount,
    required this.onClearAllFilters,
  });

  bool get hasActiveFilters => selectedCoin != null || dateFrom != null || dateTo != null;

  @override
  Widget build(BuildContext context) {
    if (!hasActiveFilters) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onClearAllFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear All Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.grey.shade700,
                elevation: 0,
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$transactionCount result${transactionCount != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
