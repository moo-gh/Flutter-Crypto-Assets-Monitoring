import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coin.dart';
import '../models/transaction.dart';

class TransactionService {
  static const String _baseUrl = 'https://crypto.m-gh.com/api/v1/exc';

  String _formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _buildTransactionsUrl({
    int? coinId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    String apiUrl = '$_baseUrl/transactions/';
    List<String> params = [];
    
    if (coinId != null) {
      params.add('coin=$coinId');
    }
    
    if (dateFrom != null) {
      params.add('date_from=${_formatDateForApi(dateFrom)}');
    }
    
    if (dateTo != null) {
      params.add('date_to=${_formatDateForApi(dateTo)}');
    }
    
    if (params.isNotEmpty) {
      apiUrl += '?${params.join('&')}';
    }
    
    return apiUrl;
  }

  Future<TransactionsResponse> fetchTransactions({
    int? coinId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final apiUrl = _buildTransactionsUrl(
      coinId: coinId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    final response = await http.get(
      Uri.parse(apiUrl),
    ).timeout(const Duration(seconds: 15));
    
    if (response.statusCode == 200) {
      return TransactionsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load transactions. Status: ${response.statusCode}');
    }
  }

  Future<TransactionsResponse> fetchMoreTransactions(String nextPageUrl) async {
    final response = await http.get(
      Uri.parse(nextPageUrl),
    ).timeout(const Duration(seconds: 15));
    
    if (response.statusCode == 200) {
      return TransactionsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load more transactions. Status: ${response.statusCode}');
    }
  }

  Future<List<Coin>> fetchAllCoins() async {
    List<Coin> allCoins = [];
    String? nextUrl = '$_baseUrl/coins/?page=1';
    
    // Fetch all pages
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
    
    return allCoins;
  }
}
