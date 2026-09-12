class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasNextPage => currentPage < lastPage;

  factory PaginatedResponse.fromJson(
    Object? json, {
    required T Function(Object? json) itemFromJson,
  }) {
    final map = json as Map<String, dynamic>;
    final rawItems = map['data'] as List<dynamic>? ?? const [];
    return PaginatedResponse(
      items: rawItems.map(itemFromJson).toList(growable: false),
      currentPage: map['current_page'] as int? ?? 1,
      lastPage: map['last_page'] as int? ?? 1,
      total: map['total'] as int? ?? rawItems.length,
    );
  }
}
