import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/users/presentation/providers/users_provider.dart';

/// Administración de usuarios (solo MANAGER): quién entra a la app, con qué
/// rol y en qué tienda.
class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  Future<void> _open(BuildContext context, {AppUser? user}) async {
    final saved = await context.push<bool>(RouteNames.userForm, extra: user);
    if ((saved ?? false) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(user == null ? Strings.userCreated : Strings.userSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final currentId = ref.watch(currentUserProvider)?.id;
    final branchNames = {
      for (final branch in ref.watch(
        sessionControllerProvider.select((session) => session.branches),
      ))
        branch.code: branch.name,
    };

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.usersTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(Strings.newUser),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(usersProvider.future),
        child: AsyncValueView<List<AppUser>>(
          value: users,
          onRetry: () => ref.invalidate(usersProvider),
          data: (items) => ListView.separated(
            // Deja sitio al botón flotante.
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final user = items[index];
              final assigned = user.assignedBranch;
              final branchLabel = assigned == null
                  ? Strings.allBranches
                  : branchNames[assigned] ?? assigned;
              return SectionCard(
                key: ValueKey(user.id),
                onTap: () => _open(context, user: user),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Opacity(
                  opacity: user.isActive ? 1 : 0.6,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: user.isManager ? AppColors.accentSoft : AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          user.isManager ? Icons.badge_rounded : Icons.person_rounded,
                          color: user.isManager ? AppColors.onAccent : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.id == currentId
                                  ? '${user.fullName} (${Strings.you})'
                                  : user.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.subtitle,
                            ),
                            Text(
                              '${Strings.role(user.role)} · ${user.username}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall,
                            ),
                            Text(
                              user.isActive
                                  ? branchLabel
                                  : '$branchLabel · ${Strings.inactiveUser}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
