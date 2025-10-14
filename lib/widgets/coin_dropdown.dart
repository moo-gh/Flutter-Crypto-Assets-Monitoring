import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/coin.dart';
import '../cache_manager.dart';

class CoinDropdown extends StatelessWidget {
  final List<Coin> coins;
  final Coin? selectedCoin;
  final Function(Coin?) onCoinSelected;
  final bool isLoading;

  const CoinDropdown({
    super.key,
    required this.coins,
    this.selectedCoin,
    required this.onCoinSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty && !isLoading) {
      return const SizedBox.shrink();
    }

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
          onChanged: onCoinSelected,
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
}
