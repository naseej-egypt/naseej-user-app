import 'package:flutter/material.dart';
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
            "Please fill all fields",
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
            "Please enter a valid email",
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
      LanguageManager.setCurrentUser(userId);
      ThemeManager.setCurrentUser(userId);
      FavoritesManager.setCurrentUser(userId);

      // Update app with user's saved preferences
      MyApp.of(context)?.changeLanguage(LanguageManager.getCurrentLanguageCode());
      MyApp.of(context)?.changeTheme(ThemeManager.getThemeMode());

      // Navigate to main page
      Navigator.of(context).pushNamedAndRemoveUntil("/main", (route) => false);
    } else {
      String errorMessage = response["message"] ?? "Login failed";

      // Check for specific error messages
      if (errorMessage.contains("verify your email")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please verify your email before logging in",
              style: TextStyle(color: AppColor.warningColor),
            ),
            backgroundColor: AppColor.backgroundcolor2,
            action: SnackBarAction(
              label: "Resend",
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
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(height: 50),
            Logo(),
            SizedBox(height: 30),
            Text(
              "Welcome Back",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Login to continue",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Text(
              "Email",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            CustomTextForm(
              hintText: "Enter your email",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            Text(
              "Password",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            CustomTextForm(
              hintText: "Enter your password",
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
                  "Forgot Password?",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Button(
              title: "Login",
              isLoading: isLoading,
              onpressed: signIn,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed("/register");
                  },
                  child: Text(
                    "Register",
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