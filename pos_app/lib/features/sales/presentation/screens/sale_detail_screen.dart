import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:pos_app/features/pos/domain/sale_receipt.dart';
import 'package:pos_app/features/pos/presentation/screens/sale_receipt_screen.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';

/// Detalle de una venta pasada: el mismo comprobante, con su tasa congelada.
///
/// La venta solo trae el id de cada producto; el nombre sale del catálogo
/// (también de los productos ya desactivados).
class SaleDetailScreen extends ConsumerWidget {
  const SaleDetailScreen({required this.sale, super.key});

  final Sale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inventoryCatalogProvider).value ?? const <StockedProduct>[];
    final branch = ref.watch(activeBranchProvider);
    return SaleReceiptScreen(
      isHistory: true,
      receipt: SaleReceipt(
        sale: sale,
        branchName: branch?.code == sale.branchCode ? branch?.name : null,
        productNames: {for (final item in catalog) item.product.id: item.product.name},
      ),
    );
  }
}
