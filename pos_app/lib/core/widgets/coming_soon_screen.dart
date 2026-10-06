import 'package:flutter/material.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/widgets/connected_branch_header.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/offline_banner.dart';

/// Pantalla provisional de una pestaña que todavía no está construida.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ConnectedBranchHeader(),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: EmptyState(
              icon: Icons.rocket_launch_rounded,
              title: '$title · ${Strings.comingSoonTitle}',
              message: Strings.comingSoonMessage,
              iconColor: AppColors.onAccent,
              iconBackground: AppColors.accentSoft,
            ),
          ),
        ],
      ),
    );
  }
}
