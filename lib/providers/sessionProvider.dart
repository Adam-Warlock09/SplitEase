import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:split_ease/services/api.dart';
import 'package:split_ease/services/sessionManager.dart';

class SessionProvider extends ChangeNotifier {
  String? _userID;
  String? _token;

  String? get userID => _userID;
  String? get token => _token;

  bool get isLoggedIn => _userID != null && _token != null;

  Future<void> LoadSession() async {
    try {
      final storedToken = await SessionManager.getToken();
      final storedUserId = await SessionManager.getUserId();

      if (storedUserId == null || storedToken == null) {
        _token = null;
        _userID = null;
        notifyListeners();
        return;
      }

      final api = ApiService();
      final success = await api.verify(storedToken);

      if (!success) {
        _token = null;
        _userID = null;
        notifyListeners();
        return;
      }

      _token = storedToken;
      _userID = storedUserId;
      notifyListeners();
    } catch (e) {
      log(e.toString());
      _token = null;
      _userID = null;
      notifyListeners();
    }
  }

  Future<void> SaveSession(String token, String userID) async {
    await SessionManager.saveSession(token, userID);
    _token = token;
    _userID = userID;
    notifyListeners();
  }

  Future<void> DeleteSession() async {
    await SessionManager.clearSession();
    _token = null;
    _userID = null;
    notifyListeners();
  }
}
