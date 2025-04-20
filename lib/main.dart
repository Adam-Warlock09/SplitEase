import 'package:flutter/material.dart';
import 'routes/appRouter.dart';

void main() {
  runApp(BillSplitApp());
}

class BillSplitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplitEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/login',
      routes: appRoutes,
    );
  }
}
