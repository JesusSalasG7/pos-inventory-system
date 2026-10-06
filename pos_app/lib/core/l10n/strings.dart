import 'package:pos_app/core/domain/enums.dart';

/// Textos visibles de la UI, centralizados. Los widgets no llevan textos sueltos.
abstract final class Strings {
  static const String appName = 'POS Sucursal';

  // Acciones generales.
  static const String retry = 'Reintentar';
  static const String cancel = 'Cancelar';
  static const String confirm = 'Confirmar';
  static const String accept = 'Aceptar';
  static const String save = 'Guardar';
  static const String close = 'Cerrar';
  static const String search = 'Buscar';
  static const String clearSearch = 'Borrar búsqueda';
  static const String all = 'Todos';
  static const String loading = 'Cargando…';
  static const String underConstruction = 'La app está en construcción.';

  // Estados.
  static const String emptyTitle = 'No hay nada que mostrar';
  static const String emptyMessage = 'Cuando haya datos aparecerán aquí.';
  static const String errorTitle = 'Algo salió mal';
  static const String offlineBanner = 'Sin conexión con el servidor';
  static const String offlineHint = 'Revisa el Wi-Fi o el cable USB y vuelve a intentar.';

  // Cabecera de sucursal.
  static const String branchLabel = 'Sucursal';
  static const String noBranch = 'Sin sucursal';
  static const String changeBranch = 'Cambiar de sucursal';
  static const String rateOfTheDay = 'Tasa del día';
  static const String rateUnit = r'Bs/$';
  static const String rateNotSet = 'Sin tasa';
  static const String sessionOpen = 'Caja abierta';
  static const String sessionClosed = 'Caja cerrada';
  static const String sessionOpenShort = 'Abierta';
  static const String sessionClosedShort = 'Cerrada';
  static const String goToCashSession = 'Ir a Caja';

  // Montos.
  static const String vesUnavailable = 'Bs —';

  // Productos y stock.
  static const String searchProducts = 'Buscar producto';
  static const String stockLabel = 'Stock';
  static const String outOfStock = 'Sin stock';
  static const String lowStock = 'Stock mínimo';
  static const String inStock = 'Disponible';
  static const String add = 'Agregar';
  static const String increase = 'Aumentar cantidad';
  static const String decrease = 'Disminuir cantidad';
  static const String editQuantity = 'Editar cantidad';
  static const String quantity = 'Cantidad';
  static const String quantityDialogTitle = 'Cantidad a vender';
  static const String invalidNumber = 'Escribe un número válido';
  static const String mustBePositive = 'Debe ser mayor que cero';
  static String maxAvailable(String amount) => 'Máximo disponible: $amount';
  static String stockOf(String amount, String unit) => '$amount $unit';

  // Carrito.
  static const String viewCart = 'Ver carrito';
  static String cartItems(int count) => count == 1 ? '1 producto' : '$count productos';

  // Vista previa de diseño (solo en debug).
  static const String designPreviewTitle = 'Vista previa de diseño';
  static const String previewColors = 'Colores';
  static const String previewTypography = 'Tipografía';
  static const String previewHeader = 'Cabecera de sucursal';
  static const String previewAmounts = 'Montos en dos monedas';
  static const String previewButtons = 'Botones';
  static const String previewFilters = 'Búsqueda y filtros';
  static const String previewProducts = 'Tarjetas de producto';
  static const String previewBadges = 'Estados de stock';
  static const String previewInputs = 'Campos numéricos';
  static const String previewStates = 'Carga, vacío y error';
  static const String previewDialogs = 'Diálogos y avisos';
  static const String previewShowDialog = 'Mostrar confirmación';
  static const String previewToggleOffline = 'Simular sin conexión';
  static const String previewToggleSession = 'Cambiar estado de caja';
  static const String previewFrozenRate = 'Con tasa congelada (150,00)';
  static const String previewActiveRate = 'Con la tasa activa';
  static const String previewPrimary = 'Confirmar venta';
  static const String previewSuccess = 'Abrir caja';
  static const String previewDanger = 'Cerrar caja';
  static const String previewDisabled = 'Deshabilitado';
  static const String previewLoading = 'Procesando';
  static const String previewOutlined = 'Registrar gasto';
  static const String previewDialogTitle = '¿Cerrar la caja?';
  static const String previewDialogMessage =
      'Se guardará el arqueo y no podrás registrar más ventas en este turno.';
  static const String previewSampleAmount = 'Monto de ejemplo';
  static const String previewStateLoading = 'Carga';
  static const String previewStateEmpty = 'Vacío';
  static const String previewStateError = 'Error';
  static const String previewStateData = 'Datos';
  static const String previewDataLoaded = 'Datos cargados correctamente.';
  static const String previewEmptyTitle = 'Sin productos';
  static const String previewEmptyMessage = 'No hay productos que coincidan con la búsqueda.';
  static String previewDialogResult({required bool confirmed}) =>
      confirmed ? 'Confirmado' : 'Cancelado';
  static String previewSearchResult(String query) =>
      query.isEmpty ? 'Escribe para buscar' : 'Buscando: $query';

  // Etiquetas de los enums del backend.
  static String role(UserRole role) => switch (role) {
    UserRole.manager => 'Gerente',
    UserRole.supervisor => 'Supervisor',
  };

  static String category(ProductCategory category) => switch (category) {
    ProductCategory.liquids => 'Líquidos',
    ProductCategory.powders => 'Polvos',
    ProductCategory.accessories => 'Accesorios',
    ProductCategory.other => 'Otros',
  };

  static String unit(UnitOfMeasure unit) => switch (unit) {
    UnitOfMeasure.liter => 'Litro',
    UnitOfMeasure.kilogram => 'Kilogramo',
    UnitOfMeasure.unit => 'Unidad',
  };

  /// Abreviatura para mostrar junto a una cantidad: `2,5 L`.
  static String unitShort(UnitOfMeasure unit) => switch (unit) {
    UnitOfMeasure.liter => 'L',
    UnitOfMeasure.kilogram => 'kg',
    UnitOfMeasure.unit => 'und',
  };

  static String movementType(MovementType type) => switch (type) {
    MovementType.entry => 'Entrada',
    MovementType.sale => 'Venta',
    MovementType.waste => 'Merma',
    MovementType.adjustment => 'Ajuste',
  };

  static String paymentMethod(PaymentMethod method) => switch (method) {
    PaymentMethod.cashUsd => r'$ Efectivo',
    PaymentMethod.cashVes => 'Bs Efectivo',
    PaymentMethod.mobilePayment => 'Pago Móvil',
    PaymentMethod.posCard => 'Punto de Venta',
  };

  static String currency(Currency currency) => switch (currency) {
    Currency.usd => 'Dólares',
    Currency.ves => 'Bolívares',
  };
}
