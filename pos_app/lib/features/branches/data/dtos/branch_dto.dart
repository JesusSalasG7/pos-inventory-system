import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_app/core/domain/branch.dart';

part 'branch_dto.freezed.dart';
part 'branch_dto.g.dart';

/// Sucursal tal como la devuelve `branches/`.
@freezed
abstract class BranchDto with _$BranchDto {
  const factory BranchDto({required String code, required String name, required bool active}) =
      _BranchDto;

  const BranchDto._();

  factory BranchDto.fromJson(Map<String, dynamic> json) => _$BranchDtoFromJson(json);

  Branch toEntity() => Branch(code: code, name: name, active: active);
}
