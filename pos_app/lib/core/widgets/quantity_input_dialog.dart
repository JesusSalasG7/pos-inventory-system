import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/decimal_input_field.dart';

/// Pide una cantidad con teclado decimal (productos por litro o kilogramo).
///
/// Devuelve la cantidad escrita, ya redondeada a 3 decimales, o `null` si se
/// cancela. No deja confirmar cero, negativos ni más que `max`.
Future<Decimal?> showQuantityInputDialog(
  BuildContext context, {
  required Decimal initial,
  required Decimal max,
  required UnitOfMeasure unit,
  String? productName,
}) {
  return showDialog<Decimal>(
    context: context,
    builder: (_) =>
        _QuantityInputDialog(initial: initial, max: max, unit: unit, productName: productName),
  );
}

class _QuantityInputDialog extends StatefulWidget {
  const _QuantityInputDialog({
    required this.initial,
    required this.max,
    required this.unit,
    this.productName,
  });

  final Decimal initial;
  final Decimal max;
  final UnitOfMeasure unit;
  final String? productName;

  @override
  State<_QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<_QuantityInputDialog> {
  late Decimal? _value = widget.initial > Decimal.zero ? widget.initial : null;

  String get _maxText =>
      Strings.stockOf(MoneyFormatter.quantity(widget.max), Strings.unitShort(widget.unit));

  String? _validate(Decimal? value) {
    if (value == null) return Strings.invalidNumber;
    if (value <= Decimal.zero) return Strings.mustBePositive;
    if (value > widget.max) return Strings.maxAvailable(_maxText);
    return null;
  }

  void _submit() {
    final value = _value;
    if (_validate(value) != null) return;
    Navigator.of(context).pop(quantizeQuantity(value!));
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _validate(_value) == null;
    return AlertDialog(
      title: const Text(Strings.quantityDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.productName != null) ...[
            Text(widget.productName!, style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.md),
          ],
          DecimalInputField(
            initialValue: _value,
            maxDecimals: widget.unit.allowsDecimals ? quantityScale : 0,
            label: Strings.quantity,
            suffixText: Strings.unitShort(widget.unit),
            autofocus: true,
            large: true,
            validator: _validate,
            textInputAction: TextInputAction.done,
            onChanged: (value) => setState(() => _value = value),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(Strings.maxAvailable(_maxText), style: AppTypography.bodySmall),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(Strings.cancel)),
        FilledButton(onPressed: isValid ? _submit : null, child: const Text(Strings.accept)),
      ],
    );
  }
}
