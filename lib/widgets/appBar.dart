import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/theme/themeNotifier.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {

  final String currentPage;

  const MyAppBar({
    super.key,
    required this.currentPage,
  });

  Future<void> _logout(BuildContext context) async {

    final session = Provider.of<SessionProvider>(context, listen: false);
    await session.DeleteSession();
      if (context.mounted) {
        context.go('/home');
      }

  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {

    context.watch<ThemeNotifier>();

    return AppBar(
      flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primaryFixed, Theme.of(context).colorScheme.primary]))),
      centerTitle: true,
      title: Text(
        currentPage,
        semanticsLabel: 'Page Title',
        style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      ),
      actions: [
        IconButton(
          iconSize: 28.0,
          tooltip: 'Toggle theme',
          icon: Icon(
            context.read<ThemeNotifier>().themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: () => context.read<ThemeNotifier>().toggleTheme(),
        ),
        AppSpacing.horizontalLg,
        IconButton(
          iconSize: 28.0,
          icon: const Icon(Icons.person),
          tooltip: 'Profile',
          onPressed: () => context.go('/profile'),
        ),
        AppSpacing.horizontalLg,
        IconButton(
          iconSize: 28.0,
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () => _logout(context),
        ),
        AppSpacing.horizontalLg,
      ],
    );

  }
}