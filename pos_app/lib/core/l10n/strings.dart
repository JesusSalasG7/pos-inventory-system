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
  static String rateSource(RateSource source) => switch (source) {
    RateSource.bcv => 'BCV',
    RateSource.manual => 'Manual',
  };
  static String rateTag(RateSource source, String dayMonth) => switch (source) {
    RateSource.bcv => 'Tasa BCV $dayMonth',
    RateSource.manual => 'Tasa manual $dayMonth',
  };
  static String rateDayLine(RateSource source, String date) => switch (source) {
    RateSource.bcv => 'Tasa del BCV correspondiente al $date',
    RateSource.manual => 'Tasa manual registrada el $date',
  };
  static const String rateChangedTitle = 'La tasa cambió';
  static String previousRate(String rate) => 'Antes: Bs/\$ $rate';
  static const String rateChangedNote = 'Los precios en bolívares ya usan la tasa nueva.';
  static const String understood = 'Entendido';
  static const String syncBcv = 'Actualizar desde el BCV';
  static const String syncBcvChanged = 'Tasa actualizada con la del BCV';
  static const String syncBcvUnchanged = 'La tasa del BCV no ha cambiado';
  static const String autoRateNote =
      'La tasa se actualiza sola con la del BCV. Una tasa manual vale hasta que el BCV '
      'publique la siguiente.';
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

  // Resumen de ventas de la caja.
  static const String salesReportTitle = 'Resumen de ventas';
  static const String totalSales = 'Ventas totales';
  static const String paymentBreakdown = 'Cobrado por forma de pago';
  static const String investmentAndProfit = 'Inversión y ganancia';
  static const String investment = 'Inversión (costo)';
  static const String profit = 'Ganancia';
  static const String loss = 'Pérdida';
  static const String investmentNote =
      'La inversión es lo que costaron los productos vendidos, con el costo que tenían al '
      'venderse. Los bolívares usan la tasa de cada venta. Los gastos de caja no se descuentan.';
  static const String soldByProduct = 'Por producto';
  static String soldQuantity(String quantity) => 'Vendido: $quantity';
  static String soldAmount(String amount) => 'Venta $amount';
  static String costAmount(String amount) => 'Costo $amount';
  static const String noSalesInSession = 'No se registraron ventas en este turno.';
  static const String done = 'Listo';

  // Vender (POS).
  static const String needOpenCashSnack = 'Abre la caja para empezar a vender';
  static const String emptyCatalogTitle = 'Aún no hay productos';
  static const String emptyCatalogMessage =
      'Cuando un gerente registre productos aparecerán aquí para venderlos.';
  static const String noResultsTitle = 'Sin resultados';
  static const String noResultsMessage = 'Ningún producto coincide con la búsqueda.';
  static const String noRateToSellTitle = 'Falta la tasa de cambio';
  static const String noRateToSellMessage =
      'Sin tasa no se puede vender. Un gerente debe registrarla en Más → Tasa de cambio.';
  static const String changeBranchWithCartTitle = '¿Cambiar de tienda?';
  static const String changeBranchWithCartMessage =
      'El carrito se vaciará: el stock y la caja son de cada tienda.';

  // Cobro.
  static const String checkoutTitle = 'Cobrar';
  static const String cartItemsTitle = 'Productos';
  static const String emptyCartTitle = 'El carrito está vacío';
  static const String emptyCartMessage = 'Vuelve a Vender y agrega productos.';
  static const String backToSell = 'Volver a Vender';
  static const String removeItem = 'Quitar del carrito';
  static String availableOnly(String amount) => 'Solo quedan $amount';
  static const String total = 'Total';
  static String rateUsed(String rate) => 'Tasa: Bs/\$ $rate';
  static const String customerOptional = 'Cliente (opcional)';
  static const String customerTaxId = 'Cédula o RIF';
  static const String customerName = 'Nombre';
  static const String payments = 'Pagos';
  static const String addPaymentHint = 'Elige cómo paga el cliente. Puedes combinar varios.';
  static const String paymentAmount = 'Monto';
  static const String paymentReference = 'Referencia';
  static const String referenceRequired = 'Escribe la referencia';
  static const String removePayment = 'Quitar pago';
  static const String remaining = 'Restante';
  static const String change = 'Vuelto';
  static const String paidExact = 'Pago completo';
  static const String overpaidWithoutCash =
      'Sobra dinero y no hay pago en efectivo del que dar vuelto. Ajusta los montos.';
  static const String changeExceedsCash =
      'El vuelto es mayor que el último pago en efectivo. Quita o ajusta ese pago.';
  static const String incompletePayments = 'Completa el monto y la referencia de cada pago.';
  static const String stockIssues = 'Ajusta las cantidades marcadas: ya no hay tanto stock.';
  static const String confirmSale = 'Confirmar venta';
  static const String saleNeedsOpenCash = 'Tu caja no está abierta. Ábrela y vuelve a confirmar.';
  static String productsRemoved(int count) => count == 1
      ? 'Se quitó un producto que ya no está disponible.'
      : 'Se quitaron $count productos que ya no están disponibles.';

  // Comprobante.
  static const String receiptTitle = 'Venta registrada';
  static String saleNumber(int id) => 'Venta #$id';
  static const String newSale = 'Nueva venta';
  static const String share = 'Compartir';
  static const String customer = 'Cliente';
  static String quantityTimesPrice(String quantity, String unit, String price) =>
      '$quantity $unit × $price';
  static String referenceLabel(String reference) => 'Ref. $reference';

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

  // Inventario.
  static const String emptyInventoryMessage =
      'Cuando un gerente registre productos aparecerán aquí con su stock.';
  static const String onlyLowStock = 'Por reponer';
  static String onlyLowStockCount(int count) => 'Por reponer ($count)';
  static const String noLowStockTitle = 'Nada por reponer';
  static const String noFilterResultsMessage = 'Ningún producto coincide con estos filtros.';
  static const String viewMovements = 'Ver movimientos';
  static const String newProduct = 'Nuevo producto';
  static const String editProduct = 'Editar producto';
  static const String inactiveProduct = 'Inactivo';
  static const String productDetail = 'Producto';
  static const String productNotFoundTitle = 'Producto no encontrado';
  static const String productNotFoundMessage = 'Puede que ya no exista. Vuelve al inventario.';
  static const String salePrice = 'Precio de venta';
  static const String costPrice = 'Costo';
  static String perUnit(String unit) => 'por $unit';
  static String stockInBranch(String branch) => 'Stock en $branch';
  static const String minimumStock = 'Stock mínimo';
  static String minimumStockOf(String amount) => 'Mínimo: $amount';
  static const String changeMinimum = 'Cambiar mínimo';
  static const String minimumStockHint =
      'Cuando el stock llegue a esta cantidad, el producto se marca por reponer.';
  static const String minimumSaved = 'Stock mínimo actualizado';
  static const String registerEntry = 'Registrar entrada';
  static const String registerWaste = 'Registrar merma';
  static const String adjustStock = 'Ajustar stock';
  static const String entryQuantity = 'Cantidad que entra';
  static const String wasteQuantity = 'Cantidad perdida';
  static const String countedStock = 'Stock contado';
  static const String adjustmentHint =
      'Escribe lo que contaste en el estante. El sistema calcula la diferencia.';
  static const String movementNotes = 'Nota (opcional)';
  static const String movementNotesHint = 'Ej. Factura 123, envase roto';
  static String currentStockOf(String amount) => 'Stock actual: $amount';
  static String resultingStock(String amount) => 'Quedará en: $amount';
  static String stockChange(String before, String after) => '$before → $after';
  static const String quantityRequired = 'Escribe una cantidad';
  static const String movementSaved = 'Movimiento registrado';
  static const String adjustmentUnchanged = 'El stock ya coincidía: no se registró ningún ajuste';
  static const String inactiveEntryNote = 'El producto está inactivo: no admite entradas.';
  static const String otherBranchesStock = 'En otras tiendas';
  static const String movementsTitle = 'Movimientos';
  static const String emptyMovementsTitle = 'Sin movimientos';
  static const String emptyMovementsMessage =
      'Las entradas, ventas, mermas y ajustes aparecerán aquí.';
  static String productNumber(int id) => 'Producto #$id';
  static const String you = 'Tú';
  static const String deactivateProduct = 'Desactivar producto';
  static const String activateProduct = 'Activar producto';
  static const String deactivate = 'Desactivar';
  static const String deactivateProductTitle = '¿Desactivar el producto?';
  static const String deactivateProductMessage =
      'Dejará de aparecer en Vender. Su stock y su historial se conservan, y puedes volver '
      'a activarlo cuando quieras.';
  static const String productActivated = 'Producto activado';
  static const String productDeactivated = 'Producto desactivado';
  static const String productName = 'Nombre del producto';
  static const String productNameHint = 'Ej. Cloro, Desengrasante';
  static const String productNameRequired = 'Escribe el nombre del producto';
  static const String categoryLabel = 'Categoría';
  static const String categoryRequired = 'Elige una categoría';
  static const String unitLabel = 'Se vende por';
  static const String costPriceLabel = r'Costo ($)';
  static const String salePriceLabel = r'Precio de venta ($)';
  static const String priceRequired = 'Escribe un precio';
  static const String saleBelowCost = 'Ojo: el precio de venta es menor que el costo.';
  static const String catalogSharedNote =
      'El producto y sus precios son los mismos en todas las tiendas. El stock es de cada una.';
  static const String createProduct = 'Crear producto';
  static const String saveChanges = 'Guardar cambios';
  static const String productCreated = 'Producto creado';
  static const String productSaved = 'Producto guardado';

  // Ventas realizadas.
  static const String salesHistoryTitle = 'Ventas';
  static const String saleDetailTitle = 'Detalle de venta';
  static const String today = 'Hoy';
  static const String yesterday = 'Ayer';
  static const String previousDay = 'Día anterior';
  static const String nextDay = 'Día siguiente';
  static const String pickDay = 'Elegir día';
  static const String dayTotal = 'Total del día';
  static const String emptySalesTitle = 'Sin ventas este día';
  static const String emptySalesMessage = 'Las ventas que se registren aparecerán aquí.';
  static String saleLine(int id, String time) => 'Venta #$id · $time';

  // Administración.
  static const String administration = 'Administración';
  static const String usersTitle = 'Usuarios';
  static const String newUser = 'Nuevo usuario';
  static const String editUser = 'Editar usuario';
  static const String createUser = 'Crear usuario';
  static const String userCreated = 'Usuario creado';
  static const String userSaved = 'Usuario guardado';
  static const String inactiveUser = 'Inactivo';
  static const String fullName = 'Nombre completo';
  static const String fullNameRequired = 'Escribe el nombre completo';
  static const String usernameHelper = 'Con él entra a la app. No se puede cambiar después.';
  static const String roleLabel = 'Rol';
  static const String managerRoleHint = 'Administra productos, precios, tasa, usuarios y tiendas.';
  static const String supervisorRoleHint = 'Vende, maneja su caja y mueve inventario en su tienda.';
  static const String userBranch = 'Tienda';
  static const String userBranchRequired = 'Elige una tienda';
  static const String newPassword = 'Nueva contraseña';
  static const String newPasswordHelper = 'Déjala vacía para no cambiarla.';
  static String passwordTooShort(int length) => 'Mínimo $length caracteres';
  static const String activeUser = 'Usuario activo';
  static const String activeUserHint = 'Un usuario inactivo no puede entrar a la app.';
  static const String cannotDeactivateSelf = 'No puedes desactivar tu propio usuario.';
  static const String branchesTitle = 'Tiendas';
  static const String newBranch = 'Nueva tienda';
  static const String renameBranch = 'Cambiar nombre';
  static const String branchCreated = 'Tienda creada';
  static const String branchRenamed = 'Tienda actualizada';
  static const String branchActivated = 'Tienda activada';
  static const String branchDeactivated = 'Tienda desactivada';
  static const String branchInUse = 'Estás trabajando en esta tienda';
  static const String inactiveBranch = 'Inactiva';
  static const String branchesHint =
      'Cada tienda tiene su propio stock y sus cajas. Una tienda inactiva no admite ventas '
      'ni se puede asignar a usuarios.';

  // Lista de precios.
  static const String priceListTitle = 'Lista de precios';
  static const String sharePriceList = 'Compartir lista';
  static String priceListHeader(String branch) => 'Lista de precios — $branch';
  static String priceListLine(String name, String unit, String usd, String ves) =>
      '• $name ($unit): $usd / $ves';
  static const String emptyPriceListMessage = 'Cuando haya productos activos aparecerán aquí.';

  // Cómo se calculan los bolívares.
  static const String pricingSettingsTitle = 'Cómo se calculan los bolívares';
  static const String rateModeBcv = 'Tasa BCV';
  static const String rateModeManual = 'Mi tasa';
  static const String rateModeBcvHint =
      'Los precios en Bs siguen a la tasa del BCV, que se actualiza sola.';
  static const String rateModeManualHint =
      'Los precios en Bs usan la tasa que tú registres. El BCV no la cambia.';
  static const String rateModeBcvSaved = 'Ahora se vende con la tasa del BCV';
  static const String rateModeManualSaved = 'Ahora se vende con tu tasa. Regístrala si hace falta.';
  static const String ownRateNote = 'Tasa propia del negocio. El BCV no la reemplaza.';
  static const String roundVesUp = 'Redondear los Bs hacia arriba';
  static const String roundVesUpHint = r'Bs 180,37 pasa a Bs 181. Los precios en $ no cambian.';
  static const String roundVesUpOn = 'Los precios en Bs se redondean hacia arriba';
  static const String roundVesUpOff = 'Los precios en Bs ya no se redondean';

  // Categorías.
  static const String categoriesTitle = 'Categorías';
  static const String categoriesHint =
      'Agrupan los productos en Vender e Inventario. Una categoría inactiva conserva sus '
      'productos, pero no se le pueden asignar nuevos.';
  static const String newCategory = 'Nueva categoría';
  static const String editCategory = 'Editar categoría';
  static const String categorySticker = 'Sticker (opcional)';
  static const String categoryStickerHint =
      'Elige uno para reconocerla rápido. Si no eliges, la app le pone un ícono.';
  static const String automaticSticker = 'Automático';
  static const String categoryName = 'Nombre de la categoría';
  static const String categoryNameHint = 'Ej. Aromatizantes';
  static const String categoryNameRequired = 'Escribe el nombre de la categoría';
  static const String categoryCreated = 'Categoría creada';
  static const String categoryRenamed = 'Categoría actualizada';
  static const String categoryActivated = 'Categoría activada';
  static const String categoryDeactivated = 'Categoría desactivada';
  static const String inactiveCategory = 'Inactiva';
  static const String emptyCategoriesTitle = 'Aún no hay categorías';
  static const String emptyCategoriesMessage = 'Crea la primera para poder registrar productos.';
  static const String noCategoriesYet = 'Todavía no hay categorías. Crea una para continuar.';

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
