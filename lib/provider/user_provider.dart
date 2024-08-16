import 'package:flutter/cupertino.dart';
import '../pages/authentication/model/user_model.dart';
import '../service/auth_service.dart';

class UserProvider with ChangeNotifier {
  UserData? _user;
  final AuthService _auth = AuthService();

  UserData? get getUser => _user;

  Future<void> refreshUser() async {
    UserData? user = await _auth.getUserData();
    _user = user;
    notifyListeners();
  }
}
