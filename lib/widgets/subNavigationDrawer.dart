import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/theme/themeNotifier.dart';

class MySubDrawer extends StatelessWidget {

  final String id;

  const MySubDrawer({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeNotifier>();

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    const double minWidth = 200.0; // Minimum width for usability
    const double maxWidth = 400.0; // Maximum width to prevent over-expansion

    // Calculate responsive width
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final drawerWidth =
        isDesktop
            ? screenWidth * 0.3
            : isTablet
            ? screenWidth * 0.4
            : screenWidth * 0.5;
    final clampedWidth = drawerWidth.clamp(minWidth, maxWidth);

    return Drawer(
      backgroundColor: colorScheme.surface,
      width: clampedWidth,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.elliptical(24, 32),
          bottomRight: Radius.elliptical(24, 32),
        ),
      ),
      child: ListView(
        children: [
          DrawerHeader(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('SPLITEASE', style: textTheme.displayLarge),
          ),
          ListTile(
            title: Text('Dashboard', style: textTheme.displayMedium),
            leading: Icon(Icons.dashboard, color: colorScheme.onSurface),
            onTap: () => context.go('/dashboard'),
          ),
          ListTile(
            title: Text('Group Details', style: textTheme.displayMedium),
            leading: Icon(Icons.group, color: colorScheme.onSurface),
            onTap: () => context.go('/group/$id'),
          ),
          ListTile(
            title: Text('Members', style: textTheme.displayMedium),
            leading: Icon(Icons.groups, color: colorScheme.onSurface),
            onTap: () => context.go('/group/$id/members'),
          ),
          ListTile(
            title: Text('Expenses', style: textTheme.displayMedium),
            leading: Icon(Icons.paid, color: colorScheme.onSurface),
            onTap: () => context.go('/group/$id/expenses'),
          ),
          ListTile(
            title: Text('Transactions', style: textTheme.displayMedium),
            leading: Icon(Icons.payment, color: colorScheme.onSurface),
            onTap: () => context.go('/group/$id/transactions'),
          ),
          ListTile(
            title: Text('Settle Up', style: textTheme.displayMedium),
            leading: Icon(Icons.task_alt, color: colorScheme.onSurface),
            onTap: () => context.go('/group/$id/settle'),
          ),
        ],
      ),
    );
  }
}
