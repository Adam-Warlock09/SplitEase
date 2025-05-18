import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/appTheme.dart';
import 'routes/appRouter.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'theme/themeNotifier.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load theme from SharedPreferences
  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadTheme();

  setUrlStrategy(PathUrlStrategy());

  runApp(
    ChangeNotifierProvider.value(
      value: themeNotifier,
      child: const BillSplitApp(),
    ),
  );
}

class BillSplitApp extends StatefulWidget {
  const BillSplitApp({super.key});

  @override
  State<BillSplitApp> createState() => _BillSplitAppState();
}

class _BillSplitAppState extends State<BillSplitApp> {
  late GoRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = createRouter();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp.router(
      title: 'SplitEase',
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: themeNotifier.themeMode,
      routerConfig: _router,
    );
  }
}
