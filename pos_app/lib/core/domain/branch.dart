import 'package:flutter/foundation.dart';

/// Sucursal del negocio. El `code` es inmutable y es lo que viaja por la API.
@immutable
class Branch {
  const Branch({required this.code, required this.name, this.active = true});

  final String code;
  final String name;
  final bool active;

  @override
  bool operator ==(Object other) =>
      other is Branch && other.code == code && other.name == name && other.active == active;

  @override
  int get hashCode => Object.hash(code, name, active);
}
