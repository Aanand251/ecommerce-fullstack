class PageResponse<T> {
  const PageResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.last,
  });

  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number;
  final bool last;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final raw = (json['content'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(mapper)
        .toList();

    return PageResponse<T>(
      content: raw,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      number: (json['number'] as num?)?.toInt() ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }
}
