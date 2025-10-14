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
