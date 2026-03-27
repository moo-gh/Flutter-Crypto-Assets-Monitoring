import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CryptoIconCacheManager {
  static const key = 'cryptoIconCache';
  
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7), // Icons are cached
      maxNrOfCacheObjects: 200, // Maximum 200 cached
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
  
  // Clear cache method
  static Future<void> clearCache() async {
    await instance.emptyCache();
  }
} 