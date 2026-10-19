import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naseej/core/constant/routes.dart';

class MyMiddleWare {
  static RouteSettings? redirect(SharedPreferences prefs) {
    String? step = prefs.getString("step");

    // If step is "2", user is logged in -> go to homepage
    if (step == "2") {
      return const RouteSettings(name: AppRoute.homepage);
    }

    // If step is "1", onboarding completed -> go to login
    if (step == "1") {
      return const RouteSettings(name: AppRoute.login);
    }

    // If step is null/empty, show onboarding
    return null;
  }
}
