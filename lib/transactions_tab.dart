import 'package:flutter/material.dart';
import 'dart:async';
import 'models/coin.dart';
import 'models/transaction.dart';
import 'services/transaction_service.dart';
import 'widgets/coin_dropdown.dart';
import 'widgets/date_filters.dart';
import 'widgets/filter_actions.dart';
import 'widgets/coin_stats_widget.dart';
import 'widgets/transaction_item.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  List<Transaction> transactions = [];
  bool isLoading = true;
  String? errorMessage;
  String? nextPageUrl;
  bool isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  
  // Coin filtering variables
  List<Coin> coins = [];
  Coin? selectedCoin;
  bool isLoadingCoins = false;
  
  // Date filtering variables
  DateTime? dateFrom;
  DateTime? dateTo;
  
  // Coin statistics
  CoinStats? coinStats;
  
  // Service instance
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    fetchCoins();
    fetchTransactions();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (nextPageUrl != null && !isLoadingMore) {
        loadMoreTransactions();
      }
    }
  }

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final transactionsResponse = await _transactionService.fetchTransactions(
        coinId: selectedCoin?.id,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      
      setState(() {
        transactions = transactionsResponse.results;
        nextPageUrl = transactionsResponse.next;
        coinStats = transactionsResponse.coinStats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> loadMoreTransactions() async {
    if (nextPageUrl == null || isLoadingMore) return;
    
    setState(() {
      isLoadingMore = true;
    });
    
    try {
      final transactionsResponse = await _transactionService.fetchMoreTransactions(nextPageUrl!);
      
      setState(() {
        transactions.addAll(transactionsResponse.results);
        nextPageUrl = transactionsResponse.next;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading more: ${e.toString()}';
        isLoadingMore = false;
      });
    }
  }

  Future<void> fetchCoins() async {
    setState(() {
      isLoadingCoins = true;
    });
    
    try {
      final allCoins = await _transactionService.fetchAllCoins();
      
      setState(() {
        coins = allCoins;
        isLoadingCoins = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCoins = false;
      });
      print('Error fetching coins: $e');
    }
  }


  void _onCoinSelected(Coin? coin) {
    setState(() {
      selectedCoin = coin;
      transactions.clear(); // Clear current transactions
      nextPageUrl = null; // Reset pagination
      coinStats = null; // Reset coin stats
    });
    fetchTransactions(); // Fetch transactions with new filter
  }

  void _onDateFromSelected(DateTime? date) {
    setState(() {
      dateFrom = date;
      if (dateTo != null && date != null && date.isAfter(dateTo!)) {
        dateTo = null; // Clear 'to' date if 'from' date is after it
      }
      transactions.clear();
      nextPageUrl = null;
      coinStats = null;
    });
    fetchTransactions();
  }

  void _onDateToSelected(DateTime? date) {
    setState(() {
      dateTo = date;
      transactions.clear();
      nextPageUrl = null;
      coinStats = null;
    });
    fetchTransactions();
  }

  void _clearAllFilters() {
    setState(() {
      selectedCoin = null;
      dateFrom = null;
      dateTo = null;
      transactions.clear();
      nextPageUrl = null;
      coinStats = null;
    });
    fetchTransactions();
  }

  void _clearDateFilters() {
    setState(() {
      dateFrom = null;
      dateTo = null;
      transactions.clear();
      nextPageUrl = null;
      coinStats = null;
    });
    fetchTransactions();
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Show coin dropdown if coins are loaded
        CoinDropdown(
          coins: coins,
          selectedCoin: selectedCoin,
          onCoinSelected: _onCoinSelected,
          isLoading: isLoadingCoins,
        ),
        
        // Display coin statistics if available
        if (coinStats != null && selectedCoin != null)
          CoinStatsWidget(
            coinStats: coinStats!,
            selectedCoin: selectedCoin!,
          ),
        
        // Show date filters
        DateFilters(
          dateFrom: dateFrom,
          dateTo: dateTo,
          onDateFromSelected: _onDateFromSelected,
          onDateToSelected: _onDateToSelected,
          onClearFilters: _clearDateFilters,
        ),
        
        // Show filter actions if there are active filters
        FilterActions(
          selectedCoin: selectedCoin,
          dateFrom: dateFrom,
          dateTo: dateTo,
          transactionCount: transactions.length,
          onClearAllFilters: _clearAllFilters,
        ),
        
        // Show loading indicator or transactions
        Expanded(
          child: isLoading 
            ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
            : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          fetchCoins();
                          fetchTransactions();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          selectedCoin != null 
                            ? 'No transactions found for ${selectedCoin!.title}'
                            : 'No transactions found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await fetchCoins();
                      await fetchTransactions();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: transactions.length + (nextPageUrl != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == transactions.length) {
                          // Show loading indicator at the bottom when loading more
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        }
                        
                        final transaction = transactions[index];
                        
                        return TransactionItem(transaction: transaction);
                      },
                    ),
                  ),
                ),
      ],
    );
  }
}
