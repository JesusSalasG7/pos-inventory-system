import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/rate_change_notice_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/widgets/rate_change_dialog.dart';

/// Armazón de la navegación principal: cinco pestañas en la barra inferior.
/// Cada pestaña conserva su estado al cambiar a otra.
///
/// También es quien muestra el aviso de cambio de tasa: está montado mientras
/// la sesión está lista, sea cual sea la pestaña.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _noticeVisible = false;

  @override
  void initState() {
    super.initState();
    // Un aviso pendiente desde antes de montar la pantalla también se muestra.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showNotice(ref.read(rateChangeNoticeControllerProvider));
    });
  }

  Future<void> _showNotice(RateChangeNotice? notice) async {
    if (notice == null || _noticeVisible) return;
    _noticeVisible = true;
    await showDialog<void>(
      context: context,
      builder: (_) => RateChangeDialog(notice: notice),
    );
    _noticeVisible = false;
    await ref.read(rateChangeNoticeControllerProvider.notifier).acknowledge();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(rateChangeNoticeControllerProvider, (_, notice) => _showNotice(notice));
    final navigationShell = widget.navigationShell;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        // Tocar la pestaña activa la devuelve a su pantalla inicial.
        onDestinationSelected: (index) =>
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: Strings.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale_rounded),
            label: Strings.navSell,
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: Strings.navInventory,
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: Strings.navCash,
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.menu_open_rounded),
            label: Strings.navMore,
          ),
        ],
      ),
    );
  }
}
