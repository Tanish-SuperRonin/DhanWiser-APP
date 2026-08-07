/// Generic wrapper for paginated API responses.
///
/// Example API response shape:
/// ```json
/// {
///   "expenses": [...],
///   "pagination": {
///     "page": 1,
///     "limit": 20,
///     "total": 87,
///     "totalPages": 5,
///     "hasMore": true
///   }
/// }
/// ```
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  /// Parse a paginated response from the API JSON.
  ///
  /// [json] is the full `data` object from the API response.
  /// [itemsKey] is the key for the list of items (e.g., 'expenses', 'notifications').
  /// [fromJson] converts each JSON object into a model instance.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json, {
    required String itemsKey,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    final items = (json[itemsKey] as List<dynamic>? ?? [])
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();

    final pagination = json['pagination'] as Map<String, dynamic>?;

    if (pagination != null) {
      return PaginatedResponse(
        items: items,
        page: pagination['page'] as int? ?? 1,
        limit: pagination['limit'] as int? ?? items.length,
        total: pagination['total'] as int? ?? items.length,
        totalPages: pagination['totalPages'] as int? ?? 1,
        hasMore: pagination['hasMore'] as bool? ?? false,
      );
    }

    // Fallback for non-paginated legacy responses
    return PaginatedResponse(
      items: items,
      page: 1,
      limit: items.length,
      total: items.length,
      totalPages: 1,
      hasMore: false,
    );
  }
}
