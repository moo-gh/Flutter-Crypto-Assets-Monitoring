import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'constants.dart';
import 'cache_manager.dart';

class Coin {
  final int id;
  final String title;
  final String code;
  final String? iconUrl;
  final String? iconBackgroundColor;

  Coin({
    required this.id,
    required this.title,
    required this.code,
    this.iconUrl,
    this.iconBackgroundColor,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'],
      title: json['title'] ?? '',
      code: json['code'] ?? '',
      iconUrl: json['icon_url'],
      iconBackgroundColor: json['icon_background_color'],
    );
  }
}

class CoinsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Coin> results;

  CoinsResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory CoinsResponse.fromJson(Map<String, dynamic> json) {
    return CoinsResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>?)
          ?.map((item) => Coin.fromJson(item))
          .toList() ?? [],
    );
  }
}

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
  });

  // Calculate profit/loss amount
  double get profitLoss {
    if (type.toLowerCase() == 'buy') {
      return currentValue - totalPrice;
    } else {
      // For sell transactions, profit is the sale amount minus what we would have now
      return totalPrice - currentValue;
    }
  }

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
      price: (json['price'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      currentValue: (json['current_value'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      changePercentage: (json['change_percentage'] ?? 0).toDouble(),
    );
  }
}

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
      String apiUrl = 'https://crypto.m-gh.com/api/v1/exc/transactions/';
      if (selectedCoin != null) {
        apiUrl += '?coin=${selectedCoin!.id}';
      }
      
      final response = await http.get(
        Uri.parse(apiUrl),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactions = (data['results'] as List)
              .map((item) => Transaction.fromJson(item))
              .toList();
          nextPageUrl = data['next'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load transactions. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
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
      final response = await http.get(
        Uri.parse(nextPageUrl!),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactions.addAll((data['results'] as List)
              .map((item) => Transaction.fromJson(item))
              .toList());
          nextPageUrl = data['next'];
          isLoadingMore = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load more transactions.';
          isLoadingMore = false;
        });
      }
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
      List<Coin> allCoins = [];
      String? nextUrl = 'https://crypto.m-gh.com/api/v1/exc/coins/?page=1';
      
      // Fetch all pages of coins
      while (nextUrl != null) {
        final response = await http.get(Uri.parse(nextUrl))
            .timeout(const Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          final coinsResponse = CoinsResponse.fromJson(json.decode(response.body));
          allCoins.addAll(coinsResponse.results);
          nextUrl = coinsResponse.next;
        } else {
          break;
        }
      }
      
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

  String formatDate(String date) {
    // The date comes in format "1400-10-21 03:30:00" (Persian calendar)
    // We'll just display it as-is for now
    return date;
  }

  String formatPrice(double price, String market) {
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

  Color getPercentageColor(double percentage) {
    if (percentage > 0) {
      return Colors.green;
    } else if (percentage < 0) {
      return Colors.red;
    }
    return Colors.grey;
  }

  Color getProfitLossColor(double profitLoss) {
    if (profitLoss > 0) {
      return Colors.green;
    } else if (profitLoss < 0) {
      return Colors.red;
    }
    return Colors.grey;
  }

  IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return Icons.arrow_downward;
      case 'sell':
        return Icons.arrow_upward;
      default:
        return Icons.swap_horiz;
    }
  }

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return Colors.green;
      case 'sell':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _onCoinSelected(Coin? coin) {
    setState(() {
      selectedCoin = coin;
      transactions.clear(); // Clear current transactions
      nextPageUrl = null; // Reset pagination
    });
    fetchTransactions(); // Fetch transactions with new filter
  }

  Widget _buildCoinDropdown() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Coin?>(
          value: selectedCoin,
          hint: const Text('Filter by Coin'),
          isExpanded: true,
          icon: const Icon(Icons.filter_list),
          onChanged: _onCoinSelected,
          items: [
            const DropdownMenuItem<Coin?>(
              value: null,
              child: Text('All Coins'),
            ),
            ...coins.map<DropdownMenuItem<Coin?>>((Coin coin) {
              return DropdownMenuItem<Coin?>(
                value: coin,
                child: Row(
                  children: [
                    if (coin.iconUrl != null)
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: coin.iconUrl!,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Icon(
                              Icons.monetization_on,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.monetization_on,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            // Use custom cache manager for better performance
                            cacheManager: CryptoIconCacheManager.instance,
                            maxWidthDiskCache: 50,
                            maxHeightDiskCache: 50,
                            memCacheWidth: 50,
                            memCacheHeight: 50,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        '${coin.title} (${coin.code})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Show coin dropdown if coins are loaded
        if (coins.isNotEmpty) _buildCoinDropdown(),
        
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
                                          backgroundColor: getTypeColor(transaction.type).withOpacity(0.2),
                                          child: Icon(
                                            getTypeIcon(transaction.type),
                                            size: 16,
                                            color: getTypeColor(transaction.type),
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
                                      formatDate(transaction.date),
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
                                          formatPrice(transaction.price, transaction.market),
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
                                          formatPrice(transaction.totalPrice, transaction.market),
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
                                          formatPrice(transaction.currentValue, transaction.market),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: getPercentageColor(transaction.changePercentage),
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
                                          '${transaction.profitLoss >= 0 ? '+' : ''}${formatPrice(transaction.profitLoss.abs(), transaction.market)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: getProfitLossColor(transaction.profitLoss),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: getPercentageColor(transaction.changePercentage).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Text(
                                        '${transaction.changePercentage > 0 ? '+' : ''}${transaction.changePercentage.toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          color: getPercentageColor(transaction.changePercentage),
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
                      },
                    ),
                  ),
                ),
      ],
    );
  }
} 