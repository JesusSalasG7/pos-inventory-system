import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/decimal_input_field.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';

/// Resultado de registrar un movimiento manual.
enum MovementOutcome {
  saved,

  /// Ajuste igual al stock actual: el backend no registró nada.
  unchanged,
}

/// Abre la hoja para registrar una entrada, una merma o un ajuste de stock.
/// Devuelve `null` si se cierra sin guardar.
Future<MovementOutcome?> showMovementSheet(
  BuildContext context, {
  required StockedProduct item,
  required MovementType type,
}) {
  assert(type != MovementType.sale, 'Las ventas generan su movimiento solas');
  return showModalBottomSheet<MovementOutcome>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => _MovementSheet(item: item, type: type),
  );
}

class _MovementSheet extends ConsumerStatefulWidget {
  const _MovementSheet({required this.item, required this.type});

  final StockedProduct item;
  final MovementType type;

  @override
  ConsumerState<_MovementSheet> createState() => _MovementSheetState();
}

class _MovementSheetState extends ConsumerState<_MovementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  Decimal? _quantity;
  bool _isSubmitting = false;
  String? _errorMessage;

  StockedProduct get _item => widget.item;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _amount(Decimal value) =>
      Strings.stockOf(MoneyFormatter.quantity(value), Strings.unitShort(_item.product.unit));

  String? _validate(Decimal? value) {
    if (value == null) return Strings.quantityRequired;
    switch (widget.type) {
      case MovementType.adjustment:
        if (value < Decimal.zero) return Strings.amountNotNegative;
      case MovementType.waste:
        if (value <= Decimal.zero) return Strings.mustBePositive;
        if (value > _item.currentStock) {
          return Strings.maxAvailable(_amount(_item.currentStock));
        }
      case MovementType.entry || MovementType.sale:
        if (value <= Decimal.zero) return Strings.mustBePositive;
    }
    return null;
  }

  /// Stock con el que quedará el producto, o `null` si la cantidad no es válida.
  Decimal? get _resultingStock {
    final quantity = _quantity;
    if (_validate(quantity) != null) return null;
    return switch (widget.type) {
      MovementType.entry => _item.currentStock + quantity!,
      MovementType.waste || MovementType.sale => _item.currentStock - quantity!,
      MovementType.adjustment => quantity,
    };
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final movement = await ref
          .read(inventoryCatalogProvider.notifier)
          .registerMovement(
            productId: _item.product.id,
            type: widget.type,
            quantity: quantizeQuantity(_quantity!),
            notes: _notesController.text,
          );
      if (!mounted) return;
      Navigator.of(
        context,
      ).pop(movement == null ? MovementOutcome.unchanged : MovementOutcome.saved);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = failure.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final (title, label, tone) = switch (widget.type) {
      MovementType.entry => (Strings.registerEntry, Strings.entryQuantity, ButtonTone.success),
      MovementType.waste => (Strings.registerWaste, Strings.wasteQuantity, ButtonTone.danger),
      MovementType.adjustment ||
      MovementType.sale => (Strings.adjustStock, Strings.countedStock, ButtonTone.primary),
    };
    final resulting = _resultingStock;
    final errorMessage = _errorMessage;

    return Padding(
      // La hoja sube con el teclado.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.title),
              const SizedBox(height: AppSpacing.xs),
              Text(_item.product.name, style: AppTypography.subtitle),
              Text(
                Strings.currentStockOf(_amount(_item.currentStock)),
                style: AppTypography.bodySmall,
              ),
              if (widget.type == MovementType.adjustment) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(Strings.adjustmentHint, style: AppTypography.bodySmall),
              ],
              const SizedBox(height: AppSpacing.lg),
              DecimalInputField(
                label: label,
                suffixText: Strings.unitShort(_item.product.unit),
                maxDecimals: _item.product.unit.allowsDecimals ? quantityScale : 0,
                enabled: !_isSubmitting,
                autofocus: true,
                large: true,
                textInputAction: TextInputAction.next,
                validator: _validate,
                onChanged: (value) => setState(() => _quantity = value),
              ),
              if (resulting != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(Strings.resultingStock(_amount(resulting)), style: AppTypography.body),
              ],
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _notesController,
                enabled: !_isSubmitting,
                maxLength: 255,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: Strings.movementNotes,
                  hintText: Strings.movementNotesHint,
                  counterText: '',
                ),
                onFieldSubmitted: (_) => _submit(),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FormErrorBanner(errorMessage),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: title,
                icon: Icons.check_rounded,
                tone: tone,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
