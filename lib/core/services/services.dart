import 'package:shared_preferences/shared_preferences.dart';

class MyServices {
  late SharedPreferences sharedPreferences;

  Future<MyServices> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }
}
