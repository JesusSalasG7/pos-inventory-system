import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/domain/enums.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// Usuario tal como lo devuelven `auth/me/` y `users/`.
@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required int id,
    required String username,
    required String fullName,
    required String role,
    required bool isActive,
    String? assignedBranch,
  }) = _UserDto;

  const UserDto._();

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  AppUser toEntity() => AppUser(
    id: id,
    username: username,
    fullName: fullName,
    role: UserRole.fromApi(role),
    assignedBranch: assignedBranch,
    isActive: isActive,
  );
}
