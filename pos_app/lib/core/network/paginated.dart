import 'package:flutter/foundation.dart';

/// Página de un listado de la API: `{count, next, previous, results}`.
@immutable
class Paginated<T> {
  const Paginated({required this.count, required this.results, this.next, this.previous});

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) fromItem,
  ) {
    return Paginated<T>(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: [
        for (final item in json['results'] as List<dynamic>) fromItem(item as Map<String, dynamic>),
      ],
    );
  }

  /// Tamaño de página por defecto del backend.
  static const int defaultPageSize = 25;

  /// Tamaño máximo que acepta el backend en `page_size`.
  static const int maxPageSize = 200;

  /// Total de elementos en todas las páginas.
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  bool get hasNext => next != null;

  Paginated<R> map<R>(R Function(T item) convert) => Paginated<R>(
    count: count,
    next: next,
    previous: previous,
    results: results.map(convert).toList(),
  );

  /// Recorre todas las páginas de un listado y devuelve sus elementos juntos.
  ///
  /// Pensado para catálogos pequeños (productos, sucursales) que la app filtra
  /// en memoria. `fetchPage` recibe el número de página, empezando en 1.
  static Future<List<T>> fetchAll<T>(Future<Paginated<T>> Function(int page) fetchPage) async {
    final items = <T>[];
    var page = 1;
    while (true) {
      final current = await fetchPage(page);
      items.addAll(current.results);
      if (!current.hasNext) return items;
      page++;
    }
  }
}
