import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilters extends StatefulWidget {
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

  @override
  State<DateFilters> createState() => _DateFiltersState();
}

class _DateFiltersState extends State<DateFilters> {

  Future<void> _selectDate(BuildContext context, {required bool isFromDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate 
          ? (widget.dateFrom ?? DateTime.now())
          : (widget.dateTo ?? widget.dateFrom ?? DateTime.now()),
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
        widget.onDateFromSelected(picked);
      } else {
        widget.onDateToSelected(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 0),
          childrenPadding: const EdgeInsets.only(top: 8, bottom: 16),
          title: Row(
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
              if (widget.dateFrom != null || widget.dateTo != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.dateFrom != null || widget.dateTo != null)
                TextButton(
                  onPressed: widget.onClearFilters,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more,
                color: Colors.grey.shade600,
              ),
            ],
          ),
          children: [
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
                            widget.dateFrom != null
                                ? DateFormat('yyyy-MM-dd').format(widget.dateFrom!)
                                : 'Select date',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: widget.dateFrom != null ? FontWeight.w500 : FontWeight.normal,
                              color: widget.dateFrom != null ? Colors.black87 : Colors.grey.shade500,
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
                            widget.dateTo != null
                                ? DateFormat('yyyy-MM-dd').format(widget.dateTo!)
                                : 'Select date',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: widget.dateTo != null ? FontWeight.w500 : FontWeight.normal,
                              color: widget.dateTo != null ? Colors.black87 : Colors.grey.shade500,
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
      ),
    );
  }
}
