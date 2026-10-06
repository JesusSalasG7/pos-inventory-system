import 'package:pos_app/core/network/api_exception.dart';

/// Traduce el `code` de un error a un mensaje en español para el usuario.
///
/// Si el código no está en la tabla se usa el `detail` del backend (que ya
/// viene en español) y, en último caso, un mensaje genérico.
abstract final class ErrorMessages {
  static const String generic = 'Ocurrió un error inesperado. Intenta de nuevo.';

  static const Map<String, String> _byCode = {
    // Red.
    ApiException.timeoutCode: 'El servidor tardó demasiado en responder. Intenta de nuevo.',
    ApiException.noConnectionCode:
        'No hay conexión con el servidor. Revisa el Wi-Fi o el cable USB.',
    ApiException.serverCode: 'El servidor tuvo un problema. Intenta de nuevo en un momento.',
    ApiException.cancelledCode: 'La operación fue cancelada.',
    ApiException.unknownCode: generic,
    // Autenticación y permisos.
    'authentication_failed': 'Usuario o contraseña incorrectos, o la cuenta está inactiva.',
    'not_authenticated': 'Tu sesión terminó. Vuelve a ingresar.',
    'token_not_valid': 'Tu sesión venció. Vuelve a ingresar.',
    'permission_denied': 'Tu usuario no tiene permiso para hacer esto.',
    'validation_error': 'Revisa los datos ingresados.',
    'not_found': 'No se encontró lo que buscabas.',
    // Sucursales.
    'no_branches': 'Todavía no hay ninguna sucursal registrada.',
    'branch_required': 'Debes elegir una sucursal.',
    'invalid_branch': 'La sucursal no existe o está inactiva.',
    'branch_access_denied': 'No tienes acceso a esa sucursal.',
    'branch_not_found': 'La sucursal no existe.',
    'invalid_branch_code':
        'El código debe empezar por una letra y usar solo letras, números y guion bajo.',
    'invalid_branch_name': 'El nombre de la sucursal es obligatorio.',
    'branch_code_taken': 'Ya existe una sucursal con ese código.',
    'branch_has_open_sessions':
        'La sucursal tiene cajas abiertas. Ciérralas antes de desactivarla.',
    // Usuarios.
    'invalid_username': 'El nombre de usuario es obligatorio.',
    'invalid_full_name': 'El nombre completo es obligatorio.',
    'invalid_password': 'La contraseña no cumple los requisitos de seguridad.',
    'invalid_branch_assignment': 'Solo un gerente puede tener acceso a todas las sucursales.',
    'username_taken': 'Ese nombre de usuario ya está en uso.',
    'user_not_found': 'El usuario no existe.',
    'user_has_open_session':
        'El usuario tiene una caja abierta. Debe cerrarla antes de este cambio.',
    'cannot_modify_own_access': 'No puedes desactivarte ni quitarte el rol de gerente.',
    // Productos e inventario.
    'invalid_name': 'El nombre del producto es obligatorio.',
    'product_name_taken': 'Ya existe un producto con ese nombre.',
    'invalid_price': 'El precio no puede ser negativo.',
    'product_not_found': 'El producto no existe.',
    'inactive_product': 'El producto no existe o está inactivo.',
    'insufficient_stock': 'No hay stock suficiente para completar la operación.',
    'invalid_quantity': 'La cantidad no es válida.',
    'invalid_movement_type': 'Ese tipo de movimiento no se puede registrar a mano.',
    // Tasa de cambio.
    'exchange_rate_not_set': 'Todavía no se ha registrado la tasa de cambio.',
    'invalid_exchange_rate': 'La tasa de cambio debe ser mayor que cero.',
    'bcv_rate_unavailable': 'No se pudo consultar la tasa del BCV. Intenta más tarde.',
    // Cajas.
    'no_open_session': 'No tienes una caja abierta en esta sucursal.',
    'session_already_open': 'Ya tienes una caja abierta.',
    'session_already_closed': 'La caja ya está cerrada.',
    'cash_session_not_found': 'La caja no existe.',
    'not_session_owner': 'Solo el dueño de la caja o un gerente pueden operar sobre ella.',
    'invalid_amount': 'El monto no es válido.',
    'invalid_reason': 'El motivo del gasto es obligatorio.',
    // Ventas.
    'payment_mismatch': 'La suma de los pagos no cuadra con el total de la venta.',
    'invalid_payment': 'Uno de los pagos no es válido.',
    'empty_sale': 'La venta debe tener al menos un producto.',
    'sale_not_found': 'La venta no existe.',
  };

  /// Códigos con mensaje propio. Lo usan los tests para detectar olvidos.
  static Iterable<String> get knownCodes => _byCode.keys;

  static String forCode(String code, {String? detail}) {
    final message = _byCode[code];
    if (message != null) return message;
    if (detail != null && detail.trim().isNotEmpty) return detail;
    return generic;
  }

  static String forException(ApiException exception) =>
      forCode(exception.code, detail: exception.detail);
}
