import 'package:flutter/material.dart';

import 'package:pos_app/core/constants/category_style.dart';
import 'package:pos_app/core/domain/category.dart';

/// Sticker de una categoría: el emoji que eligió el gerente o, si no eligió
/// ninguno, el ícono que la app le asigna.
class CategoryGlyph extends StatelessWidget {
  const CategoryGlyph({required this.category, this.size = 22, this.color, super.key});

  final ProductCategory category;
  final double size;

  /// Color del ícono automático; por defecto el de su estilo. Un emoji
  /// conserva siempre sus propios colores.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (category.hasSticker) {
      return Text(
        category.icon,
        // Sin altura de línea extra, para que el emoji quede centrado.
        style: TextStyle(fontSize: size * 0.9, height: 1.1),
        textAlign: TextAlign.center,
      );
    }
    final style = CategoryStyle.of(category);
    return Icon(style.icon, size: size, color: color ?? style.color);
  }
}

/// Círculo de color con el sticker de la categoría dentro.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({required this.category, this.size = 44, super.key});

  final ProductCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CategoryStyle.of(category).softColor,
        shape: BoxShape.circle,
      ),
      child: CategoryGlyph(category: category, size: size * 0.55),
    );
  }
}
