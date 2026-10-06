import 'package:flutter/foundation.dart';
import 'package:pos_app/core/network/paginated.dart';

/// Lista que crece página a página ("Cargar más") en los historiales.
@immutable
class PagedList<T> {
  const PagedList({required this.items, required this.totalCount, required this.nextPage});

  factory PagedList.first(Paginated<T> page) =>
      PagedList(items: page.results, totalCount: page.count, nextPage: page.hasNext ? 2 : null);

  final List<T> items;

  /// Total de elementos en el backend, no solo los ya cargados.
  final int totalCount;

  /// Número de la siguiente página, o `null` si ya no hay más.
  final int? nextPage;

  bool get hasMore => nextPage != null;

  PagedList<T> append(Paginated<T> page) => PagedList(
    items: [...items, ...page.results],
    totalCount: page.count,
    nextPage: page.hasNext ? (nextPage ?? 1) + 1 : null,
  );
}
