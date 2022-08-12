import 'package:invoice_sharing_app/constant/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences _sharedPrefs;

  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }

  String get userType => _sharedPrefs.getString(keyUserType) ?? null;

  set userType(String value) {
    _sharedPrefs.setString(keyUserType, value);
  }
}

final sharedPrefs = SharedPrefs();
