import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'constants.dart';
import 'cache_manager.dart';

class CryptoCoin {
  final String code;
  final String title;
  final String? icon;
  final double? price;
  final String? iconBackgroundColor;

  CryptoCoin({
    required this.code,
    required this.title,
    this.icon,
    this.price,
    this.iconBackgroundColor,
  });

  factory CryptoCoin.fromJson(Map<String, dynamic> json) {
    return CryptoCoin(
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      icon: json['icon'] ?? json['icon_url'],
      price: json['price']?.toDouble(),
      iconBackgroundColor: json['icon_background_color'],
    );
  }
}

class CryptoResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<CryptoCoin> results;

  CryptoResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory CryptoResponse.fromJson(Map<String, dynamic> json) {
    return CryptoResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>?)
          ?.map((item) => CryptoCoin.fromJson(item))
          .toList() ?? [],
    );
  }
}

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  List<CryptoCoin> cryptoCoins = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  String? nextPageUrl;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchCryptoPrices();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (nextPageUrl != null && !isLoadingMore) {
        _loadMoreCoins();
      }
    }
  }

  Future<void> fetchCryptoPrices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      cryptoCoins.clear();
    });
    
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse('https://crypto.m-gh.com/api/v1/exc/cached-prices/'));
      
      try {
        final streamedResponse = await client.send(request)
            .timeout(const Duration(seconds: 10), 
              onTimeout: () => throw TimeoutException('Connection timeout. Please check your internet connection.'));
              
        final response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 200) {
          final cryptoResponse = CryptoResponse.fromJson(json.decode(response.body));
          setState(() {
            cryptoCoins = cryptoResponse.results;
            nextPageUrl = cryptoResponse.next;
            isLoading = false;
          });
          return;
        }
      } catch (primaryError) {
        print('Primary API failed: $primaryError');
      }
      
      // Try fallback API (CoinGecko as example)
      try {
        final fallbackResponse = await http.get(
          Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,litecoin&vs_currencies=usd'),
        ).timeout(const Duration(seconds: 10));
        
        if (fallbackResponse.statusCode == 200) {
          final Map<String, dynamic> fallbackData = json.decode(fallbackResponse.body);
          // Convert CoinGecko response to match our app's format
          final List<CryptoCoin> adaptedCoins = [
            CryptoCoin(
              code: 'BTC',
              title: 'Bitcoin',
              price: fallbackData['bitcoin']?['usd']?.toDouble(),
            ),
            CryptoCoin(
              code: 'ETH',
              title: 'Ethereum',
              price: fallbackData['ethereum']?['usd']?.toDouble(),
            ),
            CryptoCoin(
              code: 'LTC',
              title: 'Litecoin',
              price: fallbackData['litecoin']?['usd']?.toDouble(),
            ),
          ];
          
          setState(() {
            cryptoCoins = adaptedCoins;
            nextPageUrl = null;
            isLoading = false;
          });
        } else {
          throw Exception('Fallback API failed with status: ${fallbackResponse.statusCode}');
        }
      } catch (fallbackError) {
        setState(() {
          errorMessage = 'All API attempts failed. Please check your internet connection.';
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

  Future<void> _loadMoreCoins() async {
    if (nextPageUrl == null || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await http.get(Uri.parse(nextPageUrl!))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final cryptoResponse = CryptoResponse.fromJson(json.decode(response.body));
        setState(() {
          cryptoCoins.addAll(cryptoResponse.results);
          nextPageUrl = cryptoResponse.next;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  // Format large numbers with commas
  String formatPrice(double? price) {
    if (price == null) return 'N/A';
    final formatter = NumberFormat('#,##0.##', 'en_US');
    return formatter.format(price);
  }

  // Get crypto icon based on symbol
  IconData getCryptoIcon(String symbol) {
    return Icons.monetization_on;
  }

  // Get color for coin logo background from API or default to white
  Color getCoinLogoBackground(CryptoCoin coin) {
    if (coin.iconBackgroundColor != null && coin.iconBackgroundColor!.isNotEmpty) {
      try {
        return _hexToColor(coin.iconBackgroundColor!);
      } catch (e) {
        // If parsing fails, return white as default
        return Colors.white;
      }
    }
    // Default to white background
    return Colors.white;
  }

  // Helper method to convert hex color string
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Widget _buildCoinIcon(CryptoCoin coin) {
    // Get background color for specific coins with dark logos
    final bgColor = getCoinLogoBackground(coin);
    
    if (coin.icon != null && coin.icon!.isNotEmpty) {
      // For PNG images with caching
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: CachedNetworkImage(
              imageUrl: coin.icon!,
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              placeholder: (context, url) => Icon(
                getCryptoIcon(coin.code),
                size: 20,
                color: _getContrastColor(bgColor),
              ),
              errorWidget: (context, url, error) => Icon(
                getCryptoIcon(coin.code),
                size: 20,
                color: _getContrastColor(bgColor),
              ),
              // Use custom cache manager for better performance
              cacheManager: CryptoIconCacheManager.instance,
              maxWidthDiskCache: 100,
              maxHeightDiskCache: 100,
              memCacheWidth: 100,
              memCacheHeight: 100,
            ),
          ),
        ),
      );
    } else {
      // For coins without icons, use a colored background with icon
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          getCryptoIcon(coin.code),
          size: 24,
          color: _getContrastColor(bgColor),
        ),
      );
    }
  }
  
  // Get a contrasting color for the icon based on background brightness
  Color _getContrastColor(Color backgroundColor) {
    // Calculate the luminance (brightness) of the background color
    final luminance = backgroundColor.computeLuminance();
    
    // Return black for light backgrounds, white for dark backgrounds
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading 
      ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
      : errorMessage != null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: fetchCryptoPrices,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: fetchCryptoPrices,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Featured crypto section
                  _buildFeaturedCryptoSection(),
                  const SizedBox(height: 16),
                  // All crypto section
                  Expanded(
                    child: _buildCryptoList(),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildFeaturedCryptoSection() {
    // Featured cryptocurrencies (Bitcoin, Ethereum, and BNB)
    final featuredCodes = ['BTC', 'ETH', 'BNB'];
    final featuredCoins = cryptoCoins.where((coin) => featuredCodes.contains(coin.code)).toList();
    
    if (featuredCoins.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Featured Cryptocurrencies',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: featuredCoins.map((coin) {
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: _buildFeaturedCryptoCard(coin),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCryptoCard(CryptoCoin coin) {
    final formattedPrice = formatPrice(coin.price);
    
    // Use different colors for different coins
    Color cardColor;
    Color iconColor;
    
    switch (coin.code.toLowerCase()) {
      case 'btc':
        cardColor = Theme.of(context).colorScheme.primaryContainer;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case 'eth':
        cardColor = Theme.of(context).colorScheme.secondaryContainer;
        iconColor = Theme.of(context).colorScheme.secondary;
        break;
      default:
        cardColor = Theme.of(context).colorScheme.tertiaryContainer ?? Theme.of(context).colorScheme.primaryContainer;
        iconColor = Theme.of(context).colorScheme.tertiary ?? Theme.of(context).colorScheme.primary;
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCoinIcon(coin),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    coin.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: iconColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              coin.code,
              style: TextStyle(
                fontSize: 12,
                color: iconColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedPrice,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: cryptoCoins.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == cryptoCoins.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final coin = cryptoCoins[index];
        final formattedPrice = formatPrice(coin.price);
        
        // Alternate between primary and secondary colors for list items
        final isEven = index % 2 == 0;
        final iconColor = isEven
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary;
            
        // Get background color for specific coins with dark logos
        final bgColor = getCoinLogoBackground(coin);
            
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: _buildCoinIcon(coin),
            title: Text(
              coin.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            subtitle: Text(coin.code.toUpperCase()),
            trailing: Text(
              formattedPrice,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: coin.price == null 
                    ? Colors.grey
                    : isEven 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        );
      },
    );
  }
} 