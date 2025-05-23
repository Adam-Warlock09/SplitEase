import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/theme/themeNotifier.dart';

class MyDrawer extends StatelessWidget {

  const MyDrawer({super.key});

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
            ? screenWidth *
                0.3
            : isTablet
            ? screenWidth *
                0.4
            : screenWidth * 0.5;
    final clampedWidth = drawerWidth.clamp(minWidth, maxWidth);

    return Drawer(
      backgroundColor: colorScheme.surface,
      width: clampedWidth,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight:Radius.elliptical(24, 32), bottomRight: Radius.elliptical(24, 32)),
      ),
      child: ListView(
        children: [
          DrawerHeader(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'SPLITEASE',
              style: textTheme.displayLarge,
            ),
          ),
          ListTile(
            title: Text(
              'Dashboard',
              style: textTheme.displayMedium,
            ),
            leading: Icon(Icons.dashboard, color: colorScheme.onSurface,),
            onTap: () => context.go('/dashboard'),
          ),
          ListTile(
            title: Text(
              'Groups',
              style: textTheme.displayMedium,
            ),
            leading: Icon(Icons.group, color: colorScheme.onSurface,),
            onTap: () => context.go('/groups'),
          ),
          ListTile(
            title: Text(
              'Transactions',
              style: textTheme.displayMedium,
            ),
            leading: Icon(Icons.payments, color: colorScheme.onSurface,),
            onTap: () => context.go('/transactions'),
          ),
          ListTile(
            title: Text(
              'Profile',
              style: textTheme.displayMedium,
            ),
            leading: Icon(Icons.person, color: colorScheme.onSurface,),
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );

  }

}