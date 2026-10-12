import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/core/widgets/skeleton.dart';
import 'package:pos_app/features/credits/domain/entities/credit.dart';
import 'package:pos_app/features/credits/domain/entities/credit_payment.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';
import 'package:pos_app/features/credits/domain/repositories/credits_repository.dart';
import 'package:pos_app/features/credits/presentation/providers/credits_providers.dart';
import 'package:pos_app/features/credits/presentation/widgets/credit_payment_sheet.dart';
import 'package:pos_app/features/credits/presentation/widgets/customer_tile.dart';

/// Cuenta de un cliente: lo que debe (en USD y en Bs a la tasa del BCV de
/// hoy), sus compras pendientes y pagadas, y sus abonos.
class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({required this.customerId, super.key});

  final int customerId;

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(customerCreditsProvider(customerId, CreditStatus.pending))
      ..invalidate(customerCreditsProvider(customerId, CreditStatus.paid))
      ..invalidate(customerPaymentsProvider(customerId))
      ..invalidate(customerProvider(customerId));
    await ref.read(customerProvider(customerId).future);
  }

  Future<void> _pay(BuildContext context, Customer customer) async {
    final messenger = ScaffoldMessenger.of(context);
    final payment = await showCreditPaymentSheet(context, customer: customer);
    if (payment == null) return;
    final settled = payment.amountUsd >= customer.balanceUsd;
    messenger.showSnackBar(
      SnackBar(content: Text(settled ? Strings.debtSettled : Strings.paymentSaved)),
    );
  }

  Future<void> _edit(BuildContext context, Customer customer) async {
    final saved = await context.push<Customer>(RouteNames.customerForm, extra: customer);
    if (saved != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.customerSaved)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerProvider(customerId));
    final loaded = customer.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(loaded?.name ?? Strings.customer),
        actions: [
          if (loaded != null)
            IconButton(
              tooltip: Strings.editCustomer,
              onPressed: () => _edit(context, loaded),
              icon: const Icon(Icons.edit_rounded),
            ),
        ],
      ),
      bottomNavigationBar: loaded == null || !loaded.hasDebt
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: PrimaryButton(
                label: Strings.registerPayment,
                icon: Icons.payments_rounded,
                tone: ButtonTone.success,
                onPressed: () => _pay(context, loaded),
              ),
            ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: AsyncValueView<Customer>(
          value: customer,
          onRetry: () => ref.invalidate(customerProvider(customerId)),
          data: (data) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _HeaderCard(customer: data),
              const SizedBox(height: AppSpacing.md),
              _BalanceCard(customer: data),
              const SizedBox(height: AppSpacing.md),
              _CreditsSection(
                customerId: customerId,
                status: CreditStatus.pending,
                title: Strings.pendingPurchases,
              ),
              const SizedBox(height: AppSpacing.md),
              _PaymentsSection(customerId: customerId),
              const SizedBox(height: AppSpacing.md),
              _CreditsSection(
                customerId: customerId,
                status: CreditStatus.paid,
                title: Strings.paidPurchases,
                hideWhenEmpty: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final lines = [
      customer.taxId,
      customer.phone,
      Strings.creditTerm(customer.creditDays),
      if (!customer.active) Strings.inactiveCustomer,
    ].where((value) => value.isNotEmpty);

    return SectionCard(
      child: Row(
        children: [
          CustomerAvatar(customer: customer, size: 56),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: AppTypography.title),
                for (final line in lines) Text(line, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final color = customer.hasOverdue
        ? AppColors.error
        : customer.hasDebt
        ? AppColors.warning
        : AppColors.success;
    final background = customer.hasOverdue
        ? AppColors.errorSoft
        : customer.hasDebt
        ? AppColors.warningSoft
        : AppColors.successSoft;
    final rate = customer.paymentRate;
    final balanceVes = customer.balanceVes;
    final nextDue = customer.nextDueDate;

    return SectionCard(
      color: background,
      title: Strings.balanceTitle.toUpperCase(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MoneyFormatter.usd(customer.balanceUsd),
            style: AppTypography.amount(30, color: color),
          ),
          if (customer.hasDebt && balanceVes != null)
            Text(
              Strings.balanceInBs(MoneyFormatter.ves(balanceVes)),
              style: AppTypography.amountSecondary(16, color: AppColors.textPrimary),
            ),
          if (customer.hasDebt && rate != null)
            Text(Strings.bcvRateToday(MoneyFormatter.rate(rate)), style: AppTypography.bodySmall),
          if (customer.hasOverdue)
            Text(
              Strings.overdueAmount(MoneyFormatter.usd(customer.overdueUsd)),
              style: AppTypography.label.copyWith(fontSize: 14, color: AppColors.error),
            )
          else if (customer.hasDebt && nextDue != null)
            Text(Strings.nextDue(DateFormatter.calendarDate(nextDue)), style: AppTypography.body),
          if (customer.hasDebt) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(Strings.openCreditsCount(customer.openCredits), style: AppTypography.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Text(Strings.balanceBsNote, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _CreditsSection extends ConsumerWidget {
  const _CreditsSection({
    required this.customerId,
    required this.status,
    required this.title,
    this.hideWhenEmpty = false,
  });

  final int customerId;
  final CreditStatus status;
  final String title;
  final bool hideWhenEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = customerCreditsProvider(customerId, status);
    final credits = ref.watch(provider);
    if (hideWhenEmpty && (credits.value?.isEmpty ?? true)) return const SizedBox.shrink();

    return SectionCard(
      title: title.toUpperCase(),
      child: AsyncValueView<List<Credit>>(
        value: credits,
        onRetry: () => ref.invalidate(provider),
        loading: const SkeletonBox(height: 64),
        data: (items) => items.isEmpty
            ? Text(Strings.noDebt, style: AppTypography.bodySmall)
            : Column(
                children: [
                  for (final (index, credit) in items.indexed) ...[
                    if (index > 0) const Divider(height: AppSpacing.xl),
                    _CreditRow(credit: credit),
                  ],
                ],
              ),
      ),
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({required this.credit});

  final Credit credit;

  @override
  Widget build(BuildContext context) {
    final today = DateFormatter.caracasDay(DateTime.now());
    final due = DateTime(credit.dueDate.year, credit.dueDate.month, credit.dueDate.day);
    final dueText = DateFormatter.calendarDate(credit.dueDate);
    final (status, color) = credit.isPaid
        ? (Strings.debtSettled, AppColors.success)
        : credit.isOverdue
        ? (Strings.overdueSince(dueText), AppColors.error)
        : due == today
        ? (Strings.dueToday, AppColors.warning)
        : (Strings.dueOn(dueText), AppColors.textSecondary);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Strings.purchaseLine(credit.saleId, DateFormatter.date(credit.createdAt)),
                style: AppTypography.subtitle,
              ),
              Text(
                Strings.originalAmount(MoneyFormatter.usd(credit.amountUsd)),
                style: AppTypography.bodySmall,
              ),
              Text(status, style: AppTypography.label.copyWith(fontSize: 13, color: color)),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          MoneyFormatter.usd(credit.isPaid ? credit.amountUsd : credit.balanceUsd),
          style: AppTypography.amount(16, color: credit.isPaid ? AppColors.textMuted : color),
        ),
      ],
    );
  }
}

class _PaymentsSection extends ConsumerWidget {
  const _PaymentsSection({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = customerPaymentsProvider(customerId);
    return SectionCard(
      title: Strings.paymentsHistory.toUpperCase(),
      child: AsyncValueView<List<CreditPayment>>(
        value: ref.watch(provider),
        onRetry: () => ref.invalidate(provider),
        loading: const SkeletonBox(height: 64),
        data: (items) => items.isEmpty
            ? Text(Strings.noPaymentsYet, style: AppTypography.bodySmall)
            : Column(
                children: [
                  for (final (index, payment) in items.indexed) ...[
                    if (index > 0) const Divider(height: AppSpacing.xl),
                    _PaymentRow(payment: payment),
                  ],
                ],
              ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final CreditPayment payment;

  @override
  Widget build(BuildContext context) {
    final isVes = payment.currency == Currency.ves;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Strings.paymentMethod(payment.method), style: AppTypography.subtitle),
              Text(DateFormatter.dateTime(payment.createdAt), style: AppTypography.bodySmall),
              if (isVes && payment.usdToVesRate > Decimal.zero)
                Text(
                  Strings.paidWithRate(MoneyFormatter.rate(payment.usdToVesRate)),
                  style: AppTypography.bodySmall,
                ),
              if (payment.approvalReference.isNotEmpty)
                Text(
                  Strings.referenceLabel(payment.approvalReference),
                  style: AppTypography.bodySmall,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isVes ? MoneyFormatter.ves(payment.amount) : MoneyFormatter.usd(payment.amount),
              style: AppTypography.amount(16, color: AppColors.success),
            ),
            if (isVes)
              Text(
                Strings.appliedUsd(MoneyFormatter.usd(payment.amountUsd)),
                style: AppTypography.bodySmall,
              ),
          ],
        ),
      ],
    );
  }
}
