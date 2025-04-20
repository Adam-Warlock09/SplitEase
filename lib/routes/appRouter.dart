import 'package:flutter/material.dart';
import '../screens/loginScreen.dart';
import '../screens/signupScreen.dart';
import '../screens/homeScreen.dart';

final appRoutes = {
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignupScreen(),
  '/home': (context) => HomeScreen(),
};
