import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/theme/app_typography.dart';

/// Solo deja escribir dígitos y un separador decimal, con un máximo de decimales.
/// El punto del teclado se convierte en coma, que es el separador de la app.
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.maxDecimals})
    : _pattern = RegExp(maxDecimals > 0 ? '^\\d{0,10}(,\\d{0,$maxDecimals})?\$' : r'^\d{0,10}$');

  final int maxDecimals;
  final RegExp _pattern;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('.', ',');
    if (!_pattern.hasMatch(text)) return oldValue;
    return newValue.copyWith(text: text);
  }
}

/// Campo para montos, cantidades y tasas. Entrega siempre un `Decimal`, nunca
/// un `double`, y avisa con `null` cuando el texto está vacío o incompleto.
class DecimalInputField extends StatefulWidget {
  const DecimalInputField({
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.prefixText,
    this.suffixText,
    this.errorText,
    this.maxDecimals = moneyScale,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autofocus = false,
    this.enabled = true,
    this.large = false,
    this.textInputAction,
    super.key,
  });

  final TextEditingController? controller;
  final Decimal? initialValue;
  final String? label;
  final String? hint;
  final String? prefixText;
  final String? suffixText;
  final String? errorText;
  final int maxDecimals;
  final ValueChanged<Decimal?>? onChanged;
  final ValueChanged<Decimal?>? onSubmitted;
  final String? Function(Decimal? value)? validator;
  final bool autofocus;
  final bool enabled;

  /// Texto grande y en negrita, para el campo protagonista de un formulario.
  final bool large;
  final TextInputAction? textInputAction;

  /// Texto editable de un valor: coma decimal y sin separador de miles.
  static String textOf(Decimal value) => value.toString().replaceAll('.', ',');

  @override
  State<DecimalInputField> createState() => _DecimalInputFieldState();
}

class _DecimalInputFieldState extends State<DecimalInputField> {
  TextEditingController? _ownController;

  TextEditingController get _controller => widget.controller ?? _ownController!;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    final initialText = initial == null ? '' : DecimalInputField.textOf(initial);
    if (widget.controller == null) {
      _ownController = TextEditingController(text: initialText);
    } else if (initial != null && widget.controller!.text.isEmpty) {
      widget.controller!.text = initialText;
    }
  }

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validator = widget.validator;
    return TextFormField(
      controller: _controller,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      keyboardType: TextInputType.numberWithOptions(decimal: widget.maxDecimals > 0),
      inputFormatters: [DecimalTextInputFormatter(maxDecimals: widget.maxDecimals)],
      textInputAction: widget.textInputAction,
      style: widget.large
          ? AppTypography.amount(28)
          : AppTypography.body.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFeatures: AppTypography.tabular,
            ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        errorText: widget.errorText,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator == null ? null : (text) => validator(tryParseUserDecimal(text)),
      onChanged: (text) => widget.onChanged?.call(tryParseUserDecimal(text)),
      onFieldSubmitted: (text) => widget.onSubmitted?.call(tryParseUserDecimal(text)),
    );
  }
}
