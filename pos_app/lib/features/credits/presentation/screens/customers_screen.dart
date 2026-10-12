import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/search_field.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';
import 'package:pos_app/features/credits/presentation/providers/credits_providers.dart';
import 'package:pos_app/features/credits/presentation/widgets/customer_tile.dart';

/// Clientes a crédito de la tienda activa: quién debe, cuánto y desde cuándo.
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({this.onlyDebtors = false, super.key});

  /// Abre la lista filtrada a los que deben (desde Inicio o un aviso).
  final bool onlyDebtors;

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _search = '';
  late bool _onlyDebtors = widget.onlyDebtors;

  Future<void> _create() async {
    final created = await context.push<Customer>(RouteNames.customerForm);
    if (created != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.customerCreated)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = customersProvider(search: _search, withDebt: _onlyDebtors);
    final customers = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.customersTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(Strings.newCustomer),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: SearchField(
              hint: Strings.searchCustomers,
              initialValue: _search,
              onChanged: (value) => setState(() => _search = value.trim()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                selected: _onlyDebtors,
                onSelected: (selected) => setState(() => _onlyDebtors = selected),
                avatar: _onlyDebtors
                    ? null
                    : const Icon(Icons.request_quote_rounded, size: 18, color: AppColors.warning),
                label: const Text(Strings.onlyDebtors),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(provider.future),
              child: AsyncValueView<List<Customer>>(
                value: customers,
                onRetry: () => ref.invalidate(provider),
                isEmpty: (items) => items.isEmpty,
                empty: _onlyDebtors
                    ? const EmptyState(
                        icon: Icons.verified_rounded,
                        title: Strings.noDebtorsTitle,
                        message: Strings.noDebtorsMessage,
                      )
                    : _search.isNotEmpty
                    ? const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: Strings.noResultsTitle,
                        message: Strings.noFilterResultsMessage,
                      )
                    : const EmptyState(
                        icon: Icons.people_alt_rounded,
                        title: Strings.emptyCustomersTitle,
                        message: Strings.emptyCustomersMessage,
                      ),
                data: (items) => ListView.separated(
                  // Deja sitio al botón flotante.
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    96,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final customer = items[index];
                    return CustomerTile(
                      key: ValueKey(customer.id),
                      customer: customer,
                      onTap: () => context.push(RouteNames.customerDetail(customer.id)),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
