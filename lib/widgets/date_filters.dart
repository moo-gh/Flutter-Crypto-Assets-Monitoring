import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilters extends StatelessWidget {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final Function(DateTime?) onDateFromSelected;
  final Function(DateTime?) onDateToSelected;
  final VoidCallback onClearFilters;

  const DateFilters({
    super.key,
    this.dateFrom,
    this.dateTo,
    required this.onDateFromSelected,
    required this.onDateToSelected,
    required this.onClearFilters,
  });

  Future<void> _selectDate(BuildContext context, {required bool isFromDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate 
          ? (dateFrom ?? DateTime.now())
          : (dateTo ?? dateFrom ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isFromDate) {
        onDateFromSelected(picked);
      } else {
        onDateToSelected(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.date_range,
                size: 20,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Date Range',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              if (dateFrom != null || dateTo != null)
                TextButton(
                  onPressed: onClearFilters,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // From Date
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, isFromDate: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateFrom != null
                              ? DateFormat('yyyy-MM-dd').format(dateFrom!)
                              : 'Select date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: dateFrom != null ? FontWeight.w500 : FontWeight.normal,
                            color: dateFrom != null ? Colors.black87 : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // To Date
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, isFromDate: false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateTo != null
                              ? DateFormat('yyyy-MM-dd').format(dateTo!)
                              : 'Select date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: dateTo != null ? FontWeight.w500 : FontWeight.normal,
                            color: dateTo != null ? Colors.black87 : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
