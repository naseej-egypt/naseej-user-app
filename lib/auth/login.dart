import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/main.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/component/logo.dart';
import 'package:naseej/component/button.dart';
import 'package:naseej/component/textformfield.dart';
import 'package:naseej/utils/language_manager.dart';
import 'package:naseej/utils/theme_manager.dart';
import 'package:naseej/utils/favorites_manager.dart';
import 'package:naseej/core/functions/checkinternet.dart';
import 'package:naseej/core/middleware/internet_middleware.dart';
import 'forget_password_email.dart';
import 'package:naseej/l10n/app_localizations.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  bool isLoading = false;
  Crud crud = Crud();
  DateTime? _lastBackPress;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passController.dispose();
  }

  signIn() async {
    // CHECK INTERNET FIRST
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      showNoInternetDialog(context);
      return;
    }

    // Validation
    if (emailController.text.isEmpty || passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            AppLocalizations.of(context)!.pleaseFillAllFields,
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
      return;
    }

    if (!emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            AppLocalizations.of(context)!.pleaseEnterValidEmail,
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    var response = await crud.postRequest(AppLink.login, {
      "email": emailController.text,
      "password": passController.text,
    });

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      // Extract user data and token
      String userId = response['data']['user']['id'].toString();
      String token = response['data']['token'];

      // Save user data and token
      sharedPref.setString("user_id", userId);
      sharedPref.setString("user_email", response['data']['user']['email']);
      sharedPref.setString("user_name", response['data']['user']['name']);
      sharedPref.setString("user_phone", response['data']['user']['phone']);
      sharedPref.setString("token", token); // SAVE TOKEN
      sharedPref.setString("step", "2"); // Mark as logged in

      // Set user-specific preferences
      // Language is global — no per-user language setup needed
      ThemeManager.setCurrentUser(userId);
      FavoritesManager.setCurrentUser(userId);

      // Update app with user's saved preferences
      MyApp.of(context)?.changeLanguage(LanguageManager.getCurrentLanguageCode());
      MyApp.of(context)?.changeTheme(ThemeManager.getThemeMode());

      // Navigate to main page
      Navigator.of(context).pushNamedAndRemoveUntil("/main", (route) => false);
    } else {
      String errorMessage = response["message"] ?? AppLocalizations.of(context)!.loginFailed;

      // Check for specific error messages
      if (errorMessage.contains("verify your email")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.pleaseVerifyEmail,
              style: TextStyle(color: AppColor.warningColor),
            ),
            backgroundColor: AppColor.backgroundcolor2,
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.resend,
              textColor: AppColor.primaryColor,
              onPressed: () {
                // Navigate to email verification
                Navigator.of(context).pushNamed(
                  "/email-verification",
                  arguments: emailController.text,
                );
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: TextStyle(color: AppColor.warningColor),
            ),
            backgroundColor: AppColor.backgroundcolor2,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.login == 'Login'
                  ? 'Press back again to exit'
                  : 'اضغط مرة أخرى للخروج'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColor.primaryColor,
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: _buildLoginContent(context),
    );
  }

  Widget _buildLoginContent(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(height: 50),
            Logo(),
            SizedBox(height: 30),
            Text(
              AppLocalizations.of(context)!.welcomeBack,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.loginToContinue,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Text(
              AppLocalizations.of(context)!.email,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            CustomTextForm(
              hintText: AppLocalizations.of(context)!.enterYourEmail,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.password,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            CustomTextForm(
              hintText: AppLocalizations.of(context)!.enterYourPassword,
              controller: passController,
              obscureText: true,
              isPassword: true,
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ForgetPasswordEmailPage(),
                  ),
                );
              },
              child: Container(
                alignment: TextDirection.ltr == Directionality.of(context)
                    ? Alignment.topRight
                    : Alignment.topLeft,
                child: Text(
                  AppLocalizations.of(context)!.forgotPassword,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Button(
              title: AppLocalizations.of(context)!.login,
              isLoading: isLoading,
              onpressed: signIn,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.dontHaveAccount,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed("/register");
                  },
                  child: Text(
                    AppLocalizations.of(context)!.register,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}