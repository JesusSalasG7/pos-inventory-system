/// Rutas de la app. Los nombres y las rutas van en inglés.
abstract final class RouteNames {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String firstBranch = '/first-branch';
  static const String branchPicker = '/branch-picker';
  static const String branchUnavailable = '/branch-unavailable';

  // Pestañas de la navegación principal.
  static const String home = '/home';
  static const String sell = '/sell';
  static const String inventory = '/inventory';
  static const String cash = '/cash';
  static const String more = '/more';

  // Pantallas completas, por encima de la barra de navegación.
  static const String exchangeRate = '/exchange-rate';
  static const String cashHistory = '/cash-history';
  static const String cashSessionDetail = '/cash-history/detail';
  static const String cashClosePattern = '/cash-close/:sessionId';
  static String cashClose(int sessionId) => '/cash-close/$sessionId';

  static const String designPreview = '/design-preview';
}
