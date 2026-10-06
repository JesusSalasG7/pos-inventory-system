import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_pair_dto.freezed.dart';
part 'token_pair_dto.g.dart';

/// Respuesta de `auth/login/`.
@freezed
abstract class TokenPairDto with _$TokenPairDto {
  const factory TokenPairDto({required String access, required String refresh}) = _TokenPairDto;

  factory TokenPairDto.fromJson(Map<String, dynamic> json) => _$TokenPairDtoFromJson(json);
}
