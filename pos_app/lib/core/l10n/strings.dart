import 'package:pos_app/core/domain/enums.dart';

/// Textos visibles de la UI, centralizados. Los widgets no llevan textos sueltos.
abstract final class Strings {
  static const String appName = 'POS Tienda';

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

  // Arranque e ingreso.
  static const String appTagline = 'Tu punto de venta, tienda por tienda';
  static const String startingUp = 'Preparando todo…';
  static const String startupErrorTitle = 'No pudimos conectar';
  static const String loginGreeting = '¡Hola!';
  static const String loginSubtitle = 'Ingresa con tu usuario para empezar a vender.';
  static const String username = 'Usuario';
  static const String password = 'Contraseña';
  static const String showPassword = 'Mostrar contraseña';
  static const String hidePassword = 'Ocultar contraseña';
  static const String signIn = 'Ingresar';
  static const String signOut = 'Cerrar sesión';
  static const String signOutTitle = '¿Cerrar sesión?';
  static const String signOutMessage = 'Tendrás que volver a ingresar con tu usuario y contraseña.';
  static const String usernameRequired = 'Escribe tu usuario';
  static const String passwordRequired = 'Escribe tu contraseña';
  static String serverAddress(String url) => 'Servidor: $url';

  // Sucursal de trabajo.
  static const String pickBranchTitle = '¿En qué tienda vas a trabajar?';
  static const String pickBranchSubtitle = 'Puedes cambiarla cuando quieras desde la cabecera.';
  static const String currentBranch = 'Actual';
  static const String firstBranchTitle = 'Crea tu primera tienda';
  static const String firstBranchSubtitle =
      'Todavía no hay ninguna tienda registrada. Crea la primera para empezar a cargar '
      'productos y vender. Si tienes un solo local, con una basta.';
  static const String branchName = 'Nombre de la tienda';
  static const String branchNameHint = 'Ej. Local principal';
  static const String branchNameRequired = 'Escribe el nombre de la tienda';
  static const String branchCode = 'Código';
  static const String branchCodeHelper = 'Identificador interno. No se puede cambiar después.';
  static const String branchCodeInvalid =
      'Empieza por una letra; solo letras, números y guion bajo (máx. 20).';
  static const String createBranch = 'Crear tienda';
  static const String branchUnavailableTitle = 'No puedes operar todavía';
  static const String branchUnavailableMessage =
      'Tu tienda está inactiva o aún no existe ninguna. Pide a un gerente que la registre '
      'o la active y vuelve a intentar.';

  // Navegación principal.
  static const String navHome = 'Inicio';
  static const String navSell = 'Vender';
  static const String navInventory = 'Inventario';
  static const String navCash = 'Caja';
  static const String navMore = 'Más';
  static const String comingSoonTitle = 'Muy pronto';
  static const String comingSoonMessage = 'Esta sección estará lista en la próxima entrega.';
  static String greeting(String name) => '¡Hola, $name!';
  static const String homeReadyTitle = 'Todo listo para empezar';
  static const String homeReadyMessage =
      'Ya entraste a tu tienda. Las ventas del día, la caja y los avisos de stock '
      'aparecerán aquí.';
  static const String allBranches = 'Todas las tiendas';
  static const String account = 'Tu cuenta';
  static const String designPreviewEntry = 'Vista previa de diseño';

  // Inicio (dashboard).
  static const String salesToday = 'Ventas de hoy';
  static String salesCount(int count) => count == 1 ? '1 venta' : '$count ventas';
  static const String cashCardOpen = 'Tu caja está abierta';
  static const String cashCardClosed = 'No tienes una caja abierta';
  static const String cashCardOtherBranch = 'Tienes una caja abierta en otra tienda';
  static const String cashCardClosedHint = 'Ábrela para empezar a vender.';
  static String openedAt(String dateTime) => 'Abierta el $dateTime';
  static const String openCash = 'Abrir caja';
  static const String closeCash = 'Cerrar caja';
  static const String viewCash = 'Ver caja';
  static const String registerExpense = 'Registrar gasto';
  static const String lowStockTitle = 'Stock mínimo';
  static String lowStockCount(int count) =>
      count == 1 ? '1 producto por reponer' : '$count productos por reponer';
  static const String lowStockNone = 'Todo el inventario está por encima del mínimo';
  static const String rateCardTitle = 'Tasa de cambio';
  static const String activeRate = 'Tasa activa';
  static const String bcvRate = 'BCV (referencia)';
  static const String bcvUnavailable = 'No disponible';
  static const String rateNotSetHint =
      'Sin tasa no se puede vender ni cerrar caja. Un gerente debe registrarla.';

  // Tasa de cambio.
  static const String exchangeRateTitle = 'Tasa de cambio';
  static const String rateHistory = 'Histórico';
  static const String registerRate = 'Registrar nueva tasa';
  static const String newRateTitle = 'Nueva tasa';
  static const String newRateLabel = r'Bolívares por 1 $';
  static const String useBcvRate = 'Usar la del BCV';
  static const String rateMustBePositive = 'La tasa debe ser mayor que cero';
  static const String rateSaved = 'Tasa registrada';
  static String bcvUpdatedAt(String date) => 'Publicada el $date';
  static const String bcvReferenceNote =
      'La tasa del BCV es solo una referencia. Se factura con la tasa activa.';
  static String rateDifference(String amount) => 'Diferencia con el BCV: $amount';
  static const String emptyRatesTitle = 'Aún no hay tasas';
  static const String emptyRatesMessage = 'Cuando se registre la primera, aparecerá aquí.';
  static const String loadMore = 'Cargar más';

  // Caja.
  static const String cashTitle = 'Caja';
  static const String openCashTitle = 'Abre tu caja';
  static const String openCashMessage =
      'Indica con cuánto efectivo en dólares empiezas el turno. Si empiezas sin fondo, deja cero.';
  static const String openingFloat = r'Fondo inicial ($)';
  static const String openingFloatShort = 'Fondo inicial';
  static const String amountRequired = 'Escribe un monto';
  static const String amountNotNegative = 'No puede ser negativo';
  static const String cashOpenedSnack = 'Caja abierta';
  static const String cashHistory = 'Historial de cajas';
  static const String currentCash = 'Caja actual';
  static String otherBranchSession(String branch) =>
      'Esta caja pertenece a otra tienda ($branch). Ciérrala allí o desde aquí.';
  static const String expectedCash = 'Efectivo esperado';
  static const String cashSales = 'Ventas en efectivo';
  static const String electronicSales = 'Punto y pago móvil';
  static const String electronicNote = 'Informativo: no es efectivo en gaveta.';
  static const String expenses = 'Gastos';
  static const String noExpenses = 'Sin gastos registrados en este turno.';
  static const String expenseReason = 'Motivo';
  static const String expenseReasonHint = 'Ej. Bolsas, transporte, hielo';
  static const String expenseReasonRequired = 'Escribe el motivo del gasto';
  static const String expenseAmount = 'Monto';
  static const String expenseCurrency = 'Moneda';
  static const String expenseSaved = 'Gasto registrado';
  static const String dollars = 'Dólares';
  static const String bolivars = 'Bolívares';
  static const String cashCountTitle = 'Arqueo y cierre';
  static const String cashCountMessage = 'Cuenta el efectivo de la gaveta y escribe lo que hay.';
  static const String countedUsd = r'Contado en dólares ($)';
  static const String countedVes = 'Contado en bolívares (Bs)';
  static const String expected = 'Esperado';
  static const String counted = 'Contado';
  static const String estimatedDifference = 'Diferencia estimada';
  static const String finalDifference = 'Diferencia del arqueo';
  static const String surplus = 'Sobrante';
  static const String shortage = 'Faltante';
  static const String balanced = 'Cuadra';
  static const String noRateForCount =
      'No hay tasa activa: no se puede estimar la diferencia ni cerrar la caja.';
  static const String closeCashConfirmTitle = '¿Cerrar la caja?';
  static const String closeCashConfirmMessage =
      'Se guardará el arqueo y no podrás registrar más ventas ni gastos en este turno.';
  static const String cashClosedTitle = 'Caja cerrada';
  static const String cashClosedMessage = 'El arqueo quedó guardado.';
  static const String closedSession = 'Cerrada';
  static const String openSession = 'Abierta';
  static String sessionNumber(int id) => 'Caja #$id';
  static String sessionOpenedOn(String dateTime) => 'Apertura: $dateTime';
  static String sessionClosedOn(String dateTime) => 'Cierre: $dateTime';
  static String sessionUser(int id) => 'Usuario #$id';
  static const String mySession = 'Tu turno';
  static const String emptyCashHistoryTitle = 'Aún no hay cajas';
  static const String emptyCashHistoryMessage = 'Las cajas que abras aparecerán aquí.';
  static const String sessionDetail = 'Detalle de caja';

  // Estados.
  static const String emptyTitle = 'No hay nada que mostrar';
  static const String emptyMessage = 'Cuando haya datos aparecerán aquí.';
  static const String errorTitle = 'Algo salió mal';
  static const String offlineBanner = 'Sin conexión con el servidor';
  static const String offlineHint = 'Revisa el Wi-Fi o el cable USB y vuelve a intentar.';

  // Cabecera de sucursal.
  static const String branchLabel = 'Tienda';
  static const String noBranch = 'Sin tienda';
  static const String changeBranch = 'Cambiar de tienda';
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
  static const String previewHeader = 'Cabecera de tienda';
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
