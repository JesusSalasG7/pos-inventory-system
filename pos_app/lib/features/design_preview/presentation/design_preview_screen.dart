import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/network/api_exception.dart';
import 'package:pos_app/core/network/server_reachability_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/branch_header.dart';
import 'package:pos_app/core/widgets/cart_banner.dart';
import 'package:pos_app/core/widgets/category_filter_chips.dart';
import 'package:pos_app/core/widgets/confirm_dialog.dart';
import 'package:pos_app/core/widgets/decimal_input_field.dart';
import 'package:pos_app/core/widgets/dual_currency_text.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/offline_banner.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/core/widgets/product_card.dart';
import 'package:pos_app/core/widgets/search_field.dart';
import 'package:pos_app/core/widgets/stock_badge.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';

/// Catálogo de componentes con datos de ejemplo, para revisar el diseño en el
/// teléfono. Solo se puede abrir en compilaciones de depuración y no habla
/// con el backend.
class DesignPreviewScreen extends StatelessWidget {
  const DesignPreviewScreen({super.key});

  static final Decimal sampleRate = Decimal.parse('872.3927');

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeRateProvider.overrideWithBuild((ref, notifier) => sampleRate)],
      child: const _PreviewBody(),
    );
  }
}

@immutable
class _SampleProduct {
  const _SampleProduct(
    this.id,
    this.name,
    this.category,
    this.unit,
    this.price,
    this.stock,
    this.minimum,
  );

  final int id;
  final String name;
  final ProductCategory category;
  final UnitOfMeasure unit;
  final String price;
  final String stock;
  final String minimum;
}

const _liquids = ProductCategory(id: 1, name: 'Líquidos');
const _powders = ProductCategory(id: 2, name: 'Polvos');
const _accessories = ProductCategory(id: 3, name: 'Accesorios');

const List<_SampleProduct> _sampleProducts = [
  _SampleProduct(1, 'Cloro concentrado', _liquids, UnitOfMeasure.liter, '1.20', '48.500', '10'),
  _SampleProduct(
    2,
    'Detergente en polvo multiuso',
    _powders,
    UnitOfMeasure.kilogram,
    '2.75',
    '6.250',
    '8',
  ),
  _SampleProduct(3, 'Escoba de cerdas duras', _accessories, UnitOfMeasure.unit, '4.50', '3', '2'),
  _SampleProduct(4, 'Desinfectante lavanda', _liquids, UnitOfMeasure.liter, '1.85', '0', '5'),
  _SampleProduct(5, 'Suavizante de telas', _liquids, UnitOfMeasure.liter, '1.60', '0.750', '5'),
  _SampleProduct(6, 'Paño de microfibra', _accessories, UnitOfMeasure.unit, '0.90', '120', '20'),
];

enum _DemoState { loading, empty, error, data }

class _PreviewBody extends ConsumerStatefulWidget {
  const _PreviewBody();

  @override
  ConsumerState<_PreviewBody> createState() => _PreviewBodyState();
}

class _PreviewBodyState extends ConsumerState<_PreviewBody> {
  final Map<int, Decimal> _quantities = {1: Decimal.parse('2.5'), 3: Decimal.one};
  ProductCategory? _category;
  String _query = '';
  bool _sessionOpen = true;
  bool _isSubmitting = false;
  _DemoState _demoState = _DemoState.loading;
  Decimal? _sampleAmount = Decimal.parse('12.50');
  String? _dialogResult;

  List<_SampleProduct> get _visibleProducts => _sampleProducts.where((product) {
    final matchesCategory = _category == null || product.category == _category;
    final matchesQuery = product.name.toLowerCase().contains(_query.toLowerCase());
    return matchesCategory && matchesQuery;
  }).toList();

  int get _cartItems => _quantities.values.where((q) => q > Decimal.zero).length;

  Decimal get _cartTotal {
    var total = Decimal.zero;
    for (final product in _sampleProducts) {
      final quantity = _quantities[product.id] ?? Decimal.zero;
      total += (Decimal.parse(product.price) * quantity).round(scale: 2);
    }
    return total;
  }

  Future<void> _simulateSubmit() async {
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isSubmitting = false);
  }

  Future<void> _showDialog() async {
    final confirmed = await showConfirmDialog(
      context,
      title: Strings.previewDialogTitle,
      message: Strings.previewDialogMessage,
      confirmLabel: Strings.previewDanger,
      isDestructive: true,
      content: DualCurrencyText(amountUsd: Decimal.parse('-1.25')),
    );
    if (mounted) setState(() => _dialogResult = Strings.previewDialogResult(confirmed: confirmed));
  }

  AsyncValue<String> get _demoValue => switch (_demoState) {
    _DemoState.loading => const AsyncLoading(),
    _DemoState.empty => const AsyncData(''),
    _DemoState.error => const AsyncError(
      Failure(
        code: ApiException.noConnectionCode,
        message: Strings.offlineHint,
        type: ApiErrorType.noConnection,
      ),
      StackTrace.empty,
    ),
    _DemoState.data => const AsyncData(Strings.previewDataLoaded),
  };

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(serverOfflineProvider);
    final width = MediaQuery.sizeOf(context).width;
    final columns = ProductCard.columnsFor(width);
    final products = _visibleProducts;

    return Scaffold(
      appBar: BranchHeader(
        branchName: 'Villa Libertad',
        rate: DesignPreviewScreen.sampleRate,
        isSessionOpen: _sessionOpen,
        canChangeBranch: true,
        onBranchTap: () {},
        onSessionTap: () => setState(() => _sessionOpen = !_sessionOpen),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: CartBanner(itemCount: _cartItems, totalUsd: _cartTotal, onTap: () {}),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, AppSpacing.lg, 0, 120),
              children: [
                const _Section(Strings.designPreviewTitle, isTitle: true),
                const _Section(Strings.previewColors),
                const _Padded(child: _ColorSwatches()),
                const _Section(Strings.previewTypography),
                const _Padded(child: _TypographySamples()),
                const _Section(Strings.previewAmounts),
                _Padded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DualCurrencyText(
                        amountUsd: Decimal.parse('12.50'),
                        size: DualCurrencySize.large,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(Strings.previewActiveRate, style: AppTypography.bodySmall),
                      DualCurrencyText(amountUsd: Decimal.parse('12.50')),
                      const SizedBox(height: AppSpacing.md),
                      Text(Strings.previewFrozenRate, style: AppTypography.bodySmall),
                      DualCurrencyText(
                        amountUsd: Decimal.parse('12.50'),
                        rate: Decimal.parse('150'),
                        layout: DualCurrencyLayout.row,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DualCurrencyText(
                        amountUsd: Decimal.parse('1234.5'),
                        size: DualCurrencySize.small,
                        layout: DualCurrencyLayout.row,
                      ),
                    ],
                  ),
                ),
                const _Section(Strings.previewButtons),
                _Padded(
                  child: Column(
                    children: [
                      PrimaryButton(
                        label: _isSubmitting ? Strings.previewLoading : Strings.previewPrimary,
                        icon: Icons.check_rounded,
                        isLoading: _isSubmitting,
                        onPressed: _simulateSubmit,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        label: Strings.previewSuccess,
                        icon: Icons.lock_open_rounded,
                        tone: ButtonTone.success,
                        onPressed: () {},
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        label: Strings.previewDanger,
                        icon: Icons.lock_rounded,
                        tone: ButtonTone.danger,
                        onPressed: () {},
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        label: Strings.previewOutlined,
                        icon: Icons.payments_outlined,
                        variant: ButtonVariant.outlined,
                        onPressed: () {},
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const PrimaryButton(label: Strings.previewDisabled, onPressed: null),
                    ],
                  ),
                ),
                const _Section(Strings.previewBadges),
                _Padded(
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      StockBadge(
                        stock: Decimal.parse('48.5'),
                        minimumStock: Decimal.parse('10'),
                        unit: UnitOfMeasure.liter,
                      ),
                      StockBadge(
                        stock: Decimal.parse('6.25'),
                        minimumStock: Decimal.parse('8'),
                        unit: UnitOfMeasure.kilogram,
                      ),
                      StockBadge(
                        stock: Decimal.zero,
                        minimumStock: Decimal.parse('5'),
                        unit: UnitOfMeasure.unit,
                      ),
                    ],
                  ),
                ),
                const _Section(Strings.previewInputs),
                _Padded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DecimalInputField(
                        label: Strings.previewSampleAmount,
                        prefixText: r'$ ',
                        initialValue: _sampleAmount,
                        onChanged: (value) => setState(() => _sampleAmount = value),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DualCurrencyText(amountUsd: _sampleAmount ?? Decimal.zero),
                    ],
                  ),
                ),
                const _Section(Strings.previewFilters),
                _Padded(
                  child: SearchField(
                    hint: Strings.searchProducts,
                    onChanged: (query) => setState(() => _query = query),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                CategoryFilterChips(
                  categories: const [_accessories, _liquids, _powders],
                  selected: _category,
                  onSelected: (category) => setState(() => _category = category),
                ),
                _Padded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      Strings.previewSearchResult(_query),
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ),
                const _Section(Strings.previewProducts),
                if (products.isEmpty)
                  const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: Strings.previewEmptyTitle,
                    message: Strings.previewEmptyMessage,
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisExtent: ProductCard.gridExtent,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        name: product.name,
                        category: product.category,
                        unit: product.unit,
                        priceUsd: Decimal.parse(product.price),
                        stock: Decimal.parse(product.stock),
                        minimumStock: Decimal.parse(product.minimum),
                        quantity: _quantities[product.id] ?? Decimal.zero,
                        onQuantityChanged: (quantity) =>
                            setState(() => _quantities[product.id] = quantity),
                      );
                    },
                  ),
                const _Section(Strings.previewStates),
                _Padded(
                  child: SegmentedButton<_DemoState>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: _DemoState.loading,
                        label: Text(Strings.previewStateLoading),
                      ),
                      ButtonSegment(
                        value: _DemoState.empty,
                        label: Text(Strings.previewStateEmpty),
                      ),
                      ButtonSegment(
                        value: _DemoState.error,
                        label: Text(Strings.previewStateError),
                      ),
                      ButtonSegment(value: _DemoState.data, label: Text(Strings.previewStateData)),
                    ],
                    selected: {_demoState},
                    onSelectionChanged: (selection) => setState(() => _demoState = selection.first),
                  ),
                ),
                AsyncValueView<String>(
                  value: _demoValue,
                  isEmpty: (text) => text.isEmpty,
                  onRetry: () => setState(() => _demoState = _DemoState.loading),
                  loading: const SkeletonPreview(),
                  data: (text) => _Padded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Text(text, style: AppTypography.body),
                    ),
                  ),
                ),
                const _Section(Strings.previewDialogs),
                _Padded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryButton(
                        label: Strings.previewShowDialog,
                        variant: ButtonVariant.outlined,
                        onPressed: _showDialog,
                      ),
                      if (_dialogResult != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(_dialogResult!, style: AppTypography.bodySmall),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(Strings.previewToggleOffline),
                        value: isOffline,
                        onChanged: (value) =>
                            ref.read(serverOfflineProvider.notifier).set(offline: value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(Strings.previewToggleSession),
                        value: _sessionOpen,
                        onChanged: (value) => setState(() => _sessionOpen = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Esqueleto de ejemplo, acotado para vivir dentro de la lista de la vista previa.
class SkeletonPreview extends StatelessWidget {
  const SkeletonPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Padded(
      child: Column(
        children: [
          SizedBox(height: AppSpacing.md),
          _SkeletonRow(),
          SizedBox(height: AppSpacing.md),
          _SkeletonRow(),
        ],
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(color: AppColors.surfaceMuted, borderRadius: AppRadius.mdAll),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, {this.isTitle = false});

  final String title;
  final bool isTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        isTitle ? 0 : AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Text(title, style: isTitle ? AppTypography.headline : AppTypography.title),
    );
  }
}

class _Padded extends StatelessWidget {
  const _Padded({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: child,
    );
  }
}

class _ColorSwatches extends StatelessWidget {
  const _ColorSwatches();

  static const List<(String, Color, Color)> _swatches = [
    ('Marca', AppColors.primary, AppColors.onPrimary),
    ('Acento', AppColors.accent, AppColors.onAccent),
    ('Tinta', AppColors.ink, AppColors.white),
    ('Éxito / USD', AppColors.success, AppColors.white),
    ('Alerta', AppColors.warning, AppColors.white),
    ('Error', AppColors.error, AppColors.white),
    ('Marca suave', AppColors.primarySoft, AppColors.primaryDark),
    ('Acento suave', AppColors.accentSoft, AppColors.onAccent),
    ('Alerta suave', AppColors.warningSoft, AppColors.warning),
    ('Error suave', AppColors.errorSoft, AppColors.error),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (name, background, foreground) in _swatches)
          Container(
            width: 156,
            height: AppSpacing.minTouchTarget,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: background, borderRadius: AppRadius.smAll),
            child: Text(name, style: AppTypography.label.copyWith(fontSize: 13, color: foreground)),
          ),
      ],
    );
  }
}

class _TypographySamples extends StatelessWidget {
  const _TypographySamples();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Titular 24', style: AppTypography.headline),
        Text('Título 18', style: AppTypography.title),
        Text('Subtítulo 16', style: AppTypography.subtitle),
        Text('Cuerpo 15 para textos de lectura', style: AppTypography.body),
        Text('Cuerpo pequeño 13 para datos secundarios', style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        Text(r'$ 1.111,11', style: AppTypography.amount(28)),
        Text(r'$ 8.888,88', style: AppTypography.amount(28)),
      ],
    );
  }
}
