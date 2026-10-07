import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/decimal_input_field.dart';
import 'package:pos_app/core/widgets/dual_currency_text.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/core/widgets/quantity_input_dialog.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/pricing_settings_provider.dart';
import 'package:pos_app/features/pos/domain/cart.dart';
import 'package:pos_app/features/pos/domain/checkout_math.dart';
import 'package:pos_app/features/pos/presentation/providers/cart_controller.dart';
import 'package:pos_app/features/pos/presentation/providers/checkout_controller.dart';

/// Cobro a pantalla completa: ítems editables, total, cliente opcional, pagos
/// mixtos y la calculadora de restante o vuelto.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late final TextEditingController _taxIdController;
  late final TextEditingController _nameController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final cart = ref.read(cartControllerProvider);
    _taxIdController = TextEditingController(text: cart.customerTaxId);
    _nameController = TextEditingController(text: cart.customerName);
  }

  @override
  void dispose() {
    _taxIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final receipt = await ref.read(checkoutControllerProvider.notifier).submit();
      if (mounted) context.pushReplacement(RouteNames.saleReceipt, extra: receipt);
    } on Failure catch (failure) {
      if (!mounted) return;
      switch (failure.code) {
        case 'no_open_session':
          // Se va a abrir la caja; el carrito se conserva y se vuelve a Vender.
          ref.read(returnToSellProvider.notifier).request();
          messenger.showSnackBar(const SnackBar(content: Text(Strings.saleNeedsOpenCash)));
          context.go(RouteNames.cash);
        case 'inactive_product':
          final ids = failure.meta['product_ids'];
          final count = ids is List ? ids.length : 1;
          messenger.showSnackBar(SnackBar(content: Text(Strings.productsRemoved(count))));
        default:
          // insufficient_stock ya marcó las líneas; payment_mismatch resalta el cuadre.
          setState(() => _errorMessage = failure.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final checkout = ref.watch(checkoutControllerProvider);
    final rate = ref.watch(activeRateProvider).value;
    final controller = ref.read(checkoutControllerProvider.notifier);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text(Strings.checkoutTitle)),
        body: EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: Strings.emptyCartTitle,
          message: Strings.emptyCartMessage,
          actionLabel: Strings.backToSell,
          onAction: () => context.pop(),
        ),
      );
    }

    final roundUp = ref.watch(roundVesUpProvider);
    final totalVes = rate == null ? null : cart.totalVes(rate, roundUp: roundUp);
    final summary = rate == null
        ? null
        : CheckoutMath.compute(
            totalUsd: cart.totalUsd,
            totalVes: totalVes,
            rate: rate,
            lines: checkout.lines,
          );
    final canConfirm =
        summary != null && summary.canConfirm && !cart.hasStockIssues && !checkout.isSubmitting;
    final errorMessage = _errorMessage;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.checkoutTitle)),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: PrimaryButton(
          label: Strings.confirmSale,
          icon: Icons.check_rounded,
          isLoading: checkout.isSubmitting,
          onPressed: canConfirm ? _confirm : null,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SectionCard(
            title: Strings.cartItemsTitle.toUpperCase(),
            child: Column(
              children: [
                for (final (index, item) in cart.items.indexed) ...[
                  if (index > 0) const Divider(height: AppSpacing.xl),
                  _CartItemRow(item: item, enabled: !checkout.isSubmitting),
                ],
              ],
            ),
          ),
          if (cart.hasStockIssues) ...[
            const SizedBox(height: AppSpacing.md),
            const FormErrorBanner(Strings.stockIssues),
          ],
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            color: AppColors.primarySoft,
            title: Strings.total.toUpperCase(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DualCurrencyText(
                  amountUsd: cart.totalUsd,
                  amountVes: totalVes,
                  size: DualCurrencySize.large,
                ),
                if (rate != null)
                  Text(Strings.rateUsed(MoneyFormatter.rate(rate)), style: AppTypography.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            padding: EdgeInsets.zero,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
                collapsedShape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
                initiallyExpanded: cart.customerTaxId.isNotEmpty || cart.customerName.isNotEmpty,
                leading: const Icon(Icons.person_outline_rounded),
                title: Text(Strings.customerOptional, style: AppTypography.subtitle),
                childrenPadding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                children: [
                  TextField(
                    controller: _taxIdController,
                    maxLength: 20,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: Strings.customerTaxId,
                      counterText: '',
                    ),
                    onChanged: (value) =>
                        ref.read(cartControllerProvider.notifier).setCustomer(taxId: value),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _nameController,
                    maxLength: 150,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: Strings.customerName,
                      counterText: '',
                    ),
                    onChanged: (value) =>
                        ref.read(cartControllerProvider.notifier).setCustomer(name: value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: Strings.payments.toUpperCase(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Strings.addPaymentHint, style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.md),
                _PaymentMethodButtons(
                  enabled: rate != null && !checkout.isSubmitting,
                  onSelected: controller.addLine,
                ),
                for (final line in checkout.lines) ...[
                  const SizedBox(height: AppSpacing.md),
                  _PaymentLineCard(
                    key: ValueKey(line.id),
                    line: line,
                    enabled: !checkout.isSubmitting,
                    onAmountChanged: (amount) => controller.updateAmount(line.id, amount),
                    onReferenceChanged: (text) => controller.updateReference(line.id, text),
                    onRemove: () => controller.removeLine(line.id),
                  ),
                ],
              ],
            ),
          ),
          if (summary != null) ...[
            const SizedBox(height: AppSpacing.md),
            _CalculatorCard(summary: summary, highlight: errorMessage != null),
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            FormErrorBanner(errorMessage),
          ],
        ],
      ),
    );
  }
}

class _CartItemRow extends ConsumerWidget {
  const _CartItemRow({required this.item, required this.enabled});

  final CartItem item;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartControllerProvider.notifier);
    final product = item.product;
    final unit = Strings.unitShort(product.unit);
    final canIncrease = item.quantity + Decimal.one <= item.availableStock;
    final rate = ref.watch(activeRateProvider).value;
    final roundUp = ref.watch(roundVesUpProvider);

    Future<void> editQuantity() async {
      final result = await showQuantityInputDialog(
        context,
        initial: item.quantity,
        max: item.availableStock,
        unit: product.unit,
        productName: product.name,
      );
      if (result != null) cart.setItemQuantity(product.id, result);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle,
                  ),
                  Text(
                    Strings.quantityTimesPrice(
                      MoneyFormatter.quantity(item.quantity),
                      unit,
                      MoneyFormatter.usd(product.salePriceUsd),
                    ),
                    style: AppTypography.bodySmall,
                  ),
                  if (item.exceedsStock)
                    Text(
                      Strings.availableOnly(
                        Strings.stockOf(MoneyFormatter.quantity(item.availableStock), unit),
                      ),
                      style: AppTypography.label.copyWith(fontSize: 13, color: AppColors.error),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DualCurrencyText(
              amountUsd: item.subtotalUsd,
              amountVes: rate == null ? null : item.subtotalVes(rate, roundUp: roundUp),
              size: DualCurrencySize.small,
              crossAxisAlignment: CrossAxisAlignment.end,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            IconButton.outlined(
              tooltip: Strings.decrease,
              onPressed: enabled
                  ? () => cart.setItemQuantity(product.id, item.quantity - Decimal.one)
                  : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            SizedBox(
              width: 88,
              height: AppSpacing.minTouchTarget,
              child: InkWell(
                borderRadius: AppRadius.pillAll,
                onTap: enabled && product.unit.allowsDecimals ? editQuantity : null,
                child: Center(
                  child: Text(
                    '${MoneyFormatter.quantity(item.quantity)} $unit',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.amount(
                      16,
                      color: item.exceedsStock ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            IconButton.outlined(
              tooltip: Strings.increase,
              onPressed: enabled && canIncrease
                  ? () => cart.setItemQuantity(product.id, item.quantity + Decimal.one)
                  : null,
              icon: const Icon(Icons.add_rounded),
            ),
            const Spacer(),
            IconButton(
              tooltip: Strings.removeItem,
              onPressed: enabled ? () => cart.remove(product.id) : null,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaymentMethodButtons extends StatelessWidget {
  const _PaymentMethodButtons({required this.enabled, required this.onSelected});

  final bool enabled;
  final ValueChanged<PaymentMethod> onSelected;

  static const Map<PaymentMethod, IconData> _icons = {
    PaymentMethod.cashUsd: Icons.attach_money_rounded,
    PaymentMethod.cashVes: Icons.payments_outlined,
    PaymentMethod.mobilePayment: Icons.smartphone_rounded,
    PaymentMethod.posCard: Icons.credit_card_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final method in PaymentMethod.values)
              SizedBox(
                width: width,
                height: AppSpacing.primaryButtonHeight,
                child: FilledButton.tonalIcon(
                  onPressed: enabled ? () => onSelected(method) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentSoft,
                    foregroundColor: AppColors.onAccent,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    textStyle: AppTypography.button.copyWith(fontSize: 14),
                  ),
                  icon: Icon(_icons[method], size: 20),
                  // En pantallas estrechas el texto se encoge antes que recortarse.
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(Strings.paymentMethod(method), maxLines: 1),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PaymentLineCard extends StatelessWidget {
  const _PaymentLineCard({
    required this.line,
    required this.enabled,
    required this.onAmountChanged,
    required this.onReferenceChanged,
    required this.onRemove,
    super.key,
  });

  final PaymentLine line;
  final bool enabled;
  final ValueChanged<Decimal?> onAmountChanged;
  final ValueChanged<String> onReferenceChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isUsd = line.method.currency == Currency.usd;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(Strings.paymentMethod(line.method), style: AppTypography.subtitle),
              ),
              IconButton(
                tooltip: Strings.removePayment,
                onPressed: enabled ? onRemove : null,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Column(
              children: [
                DecimalInputField(
                  label: Strings.paymentAmount,
                  prefixText: isUsd ? r'$ ' : 'Bs ',
                  initialValue: line.amount,
                  enabled: enabled,
                  validator: (value) =>
                      (value ?? Decimal.zero) > Decimal.zero ? null : Strings.mustBePositive,
                  onChanged: onAmountChanged,
                ),
                if (line.method.requiresReference) ...[
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    initialValue: line.reference,
                    enabled: enabled,
                    maxLength: 50,
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(
                      labelText: Strings.paymentReference,
                      counterText: '',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? Strings.referenceRequired : null,
                    onChanged: onReferenceChanged,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Calculadora en vivo: cuánto falta, cuánto vuelto dar o qué hay que corregir.
class _CalculatorCard extends StatelessWidget {
  const _CalculatorCard({required this.summary, required this.highlight});

  final CheckoutSummary summary;

  /// Resalta la tarjeta cuando el backend rechazó el cuadre.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final (color, background, title, content) = switch (summary.status) {
      CheckoutStatus.noPayments || CheckoutStatus.remaining => (
        AppColors.warning,
        AppColors.warningSoft,
        Strings.remaining,
        DualCurrencyText(
              amountUsd: summary.remainingUsd ?? summary.totalUsd,
              amountVes: summary.remainingVes,
              usdColor: AppColors.warning,
              vesColor: AppColors.warning,
            )
            as Widget,
      ),
      CheckoutStatus.change => (
        AppColors.success,
        AppColors.successSoft,
        Strings.change,
        Text(
          summary.changeCurrency == Currency.usd
              ? MoneyFormatter.usd(summary.changeAmount!)
              : MoneyFormatter.ves(summary.changeAmount!),
          style: AppTypography.amount(26, color: AppColors.success),
        ),
      ),
      CheckoutStatus.exact => (
        AppColors.success,
        AppColors.successSoft,
        Strings.paidExact,
        Text(
          MoneyFormatter.usd(summary.paidUsd),
          style: AppTypography.amount(22, color: AppColors.success),
        ),
      ),
      CheckoutStatus.incomplete => (
        AppColors.warning,
        AppColors.warningSoft,
        Strings.payments,
        Text(
          Strings.incompletePayments,
          style: AppTypography.body.copyWith(color: AppColors.warning),
        ),
      ),
      CheckoutStatus.overpaidWithoutCash => (
        AppColors.error,
        AppColors.errorSoft,
        Strings.payments,
        Text(
          Strings.overpaidWithoutCash,
          style: AppTypography.body.copyWith(color: AppColors.error),
        ),
      ),
      CheckoutStatus.changeExceedsCash => (
        AppColors.error,
        AppColors.errorSoft,
        Strings.payments,
        Text(Strings.changeExceedsCash, style: AppTypography.body.copyWith(color: AppColors.error)),
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: highlight ? AppColors.error : Colors.transparent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.label.copyWith(fontSize: 13, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          content,
        ],
      ),
    );
  }
}
