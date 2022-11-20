import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app_3/models/http_exeptions.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expireTime;
  String? _userId;
  Timer? _authTimer;

  bool get isAuthenticated {
    if (token != null) {
      return true;
    }
    return false;
  }

  String? get token {
    if (_token != null && _expireTime != null) {
      if (_expireTime!.isAfter(DateTime.now())) {
        return _token;
      }
    }
    return null;
  }

  String? get userId {
    if (_userId != null) {
      return _userId;
    }
    return null;
  }

  Future<void> _authenticate(
      String urlSegment, String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyA2MB5A-RLC3KKrWoEgUJ597NH2nsJKcPA');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      //print(responseData);
      if (responseData['error'] != null) {
        throw HttpExptions(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _expireTime = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _userId = responseData['localId'];
      autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "userId": userId,
        "_expireTime": _expireTime!.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate("signUp", email, password);

    // final url = Uri.parse(
    //     'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyA2MB5A-RLC3KKrWoEgUJ597NH2nsJKcPA');
    // final response = await http.post(url,
    //     body: json.encode({
    //       'email': email,
    //       'password': password,
    //       'returnSecureToken': true,
    //     }));
    // print(json.decode(response.body));
  }

  Future<void> login(String email, String password) async {
    return _authenticate("signInWithPassword", email, password);

    //   final url = Uri.parse(
    //       'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyA2MB5A-RLC3KKrWoEgUJ597NH2nsJKcPA');
    //   final response = await http.post(url,
    //       body: json.encode({
    //         'email': email,
    //         'password': password,
    //         'returnSecureToken': true,
    //       }));
    //   print(json.decode(response.body));
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final userData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

    final expireDate = DateTime.parse(userData['_expireTime'] as String);

    if (expireDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = userData['token'] as String;
    _userId = userData['userId'] as String;
    _expireTime = expireDate;

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _expireTime = null;
    _userId = null;

    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      prefs.remove('userData');
    }
    notifyListeners();
  }

  void autoLogout() {
    if (_expireTime != null) {
      if (_authTimer != null) {
        _authTimer!.cancel();
      }
      final expireDuration = _expireTime!.difference(DateTime.now()).inSeconds;
      _authTimer = Timer(Duration(seconds: expireDuration), logout);
    }
  }
}
