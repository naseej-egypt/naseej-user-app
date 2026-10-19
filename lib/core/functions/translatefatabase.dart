import 'package:naseej/main.dart';
import 'package:naseej/utils/language_manager.dart';

dynamic translateDatabase(dynamic columnar, dynamic columnen) {
  if (LanguageManager.isArabic() || sharedPref.getString("lang") == "ar") {
    return columnar;
  } else {
    return columnen;
  }
}
