import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:split_ease/services/api.dart';
import 'package:split_ease/services/sessionManager.dart';

class SessionProvider extends ChangeNotifier {
  String? _userID;
  String? _token;
  String? _name;

  String? get userID => _userID;
  String? get token => _token;
  String? get name => _name;

  bool get isLoggedIn => _userID != null && _token != null && _name != null;

  Future<void> LoadSession() async {
    try {
      final storedToken = await SessionManager.getToken();
      final storedUserId = await SessionManager.getUserId();
      final storedName = await SessionManager.getName();

      if (storedUserId == null || storedToken == null || storedName == null) {
        _token = null;
        _userID = null;
        _name = null;
        notifyListeners();
        return;
      }

      final api = ApiService();
      final success = await api.verify(storedToken);

      if (!success) {
        _token = null;
        _userID = null;
        _name = null;
        notifyListeners();
        return;
      }

      _token = storedToken;
      _userID = storedUserId;
      _name = storedName;
      notifyListeners();
    } catch (e) {
      log(e.toString());
      _token = null;
      _userID = null;
      _name = null;
      notifyListeners();
    }
  }

  Future<void> SaveSession(String token, String userID, String name) async {
    await SessionManager.saveSession(token, userID, name);
    _token = token;
    _userID = userID;
    _name = name;
    notifyListeners();
  }

  Future<void> DeleteSession() async {
    await SessionManager.clearSession();
    _token = null;
    _userID = null;
    _name = null;
    notifyListeners();
  }
}
