import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/core/widgets/search_field.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';
import 'package:pos_app/features/credits/presentation/providers/credits_providers.dart';
import 'package:pos_app/features/credits/presentation/widgets/customer_tile.dart';

/// Abre la hoja para elegir el cliente de una venta a crédito. Devuelve el
/// cliente elegido (o el recién creado), o `null` si se cerró sin elegir.
Future<Customer?> showCustomerPicker(BuildContext context) {
  return showModalBottomSheet<Customer>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => const FractionallySizedBox(heightFactor: 0.85, child: CustomerPicker()),
  );
}

/// Lista de clientes activos con búsqueda y alta rápida.
class CustomerPicker extends ConsumerStatefulWidget {
  const CustomerPicker({super.key});

  @override
  ConsumerState<CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends ConsumerState<CustomerPicker> {
  String _search = '';

  Future<void> _create() async {
    final navigator = Navigator.of(context);
    final created = await context.push<Customer>(RouteNames.customerForm);
    if (created != null && mounted) navigator.pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final provider = customersProvider(search: _search, onlyActive: true);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(Strings.pickCustomerTitle, style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          SearchField(
            hint: Strings.searchCustomers,
            onChanged: (value) => setState(() => _search = value.trim()),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: AsyncValueView<List<Customer>>(
              value: ref.watch(provider),
              onRetry: () => ref.invalidate(provider),
              isEmpty: (items) => items.isEmpty,
              empty: const EmptyState(
                icon: Icons.people_alt_rounded,
                title: Strings.emptyCustomersTitle,
                message: Strings.emptyCustomersMessage,
              ),
              data: (items) => ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => CustomerTile(
                  key: ValueKey(items[index].id),
                  customer: items[index],
                  onTap: () => Navigator.of(context).pop(items[index]),
                ),
              ),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: PrimaryButton(
              label: Strings.newCustomer,
              icon: Icons.person_add_alt_1_rounded,
              variant: ButtonVariant.outlined,
              onPressed: _create,
            ),
          ),
        ],
      ),
    );
  }
}
