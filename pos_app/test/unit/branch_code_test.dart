import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/features/branches/domain/branch_code.dart';

void main() {
  test('propone un código válido a partir del nombre', () {
    expect(BranchCode.suggest('Local principal'), 'LOCAL_PRINCIPAL');
    expect(BranchCode.suggest('  Sede Las Américas '), 'SEDE_LAS_AMERICAS');
    expect(BranchCode.suggest('Peña & Núñez #2'), 'PENA_NUNEZ_2');
    expect(BranchCode.suggest('24 de Julio'), 'S24_DE_JULIO');
    expect(BranchCode.suggest('---'), '');
  });

  test('recorta a 20 caracteres sin dejar un guion bajo al final', () {
    final code = BranchCode.suggest('Sucursal del Centro Comercial');
    expect(code, 'SUCURSAL_DEL_CENTRO');
    expect(code.length, lessThanOrEqualTo(BranchCode.maxLength));
  });

  test('toda propuesta no vacía cumple la regla del backend', () {
    for (final name in [
      'Centro',
      'El Paraíso 2',
      '1ra Avenida',
      'A',
      'Zona_Industrial Norte y Sur',
    ]) {
      expect(BranchCode.isValid(BranchCode.suggest(name)), isTrue, reason: name);
    }
  });

  test('valida igual que el backend', () {
    expect(BranchCode.isValid('PRINCIPAL'), isTrue);
    expect(BranchCode.isValid('SEDE_2'), isTrue);
    expect(BranchCode.isValid('principal'), isFalse);
    expect(BranchCode.isValid('1CENTRO'), isFalse);
    expect(BranchCode.isValid('SEDE CENTRO'), isFalse);
    expect(BranchCode.isValid(''), isFalse);
    expect(BranchCode.isValid('X' * 21), isFalse);
  });
}
