import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/component/button.dart';
import 'package:naseej/component/textformfield.dart';
import 'package:naseej/component/crud.dart';
import '../core/functions/checkinternet.dart';
import '../core/middleware/internet_middleware.dart';
import 'package:naseej/l10n/app_localizations.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String verificationCode;

  const ResetPasswordPage({
    Key? key,
    required this.email,
    required this.verificationCode,
  }) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final Crud _crud = Crud();
  bool isLoading = false;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    // CHECK INTERNET
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      showNoInternetDialog(context);
      return;
    }

    // Validation
    if (newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
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

    if (newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            AppLocalizations.of(context)!.passwordMinLength,
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            AppLocalizations.of(context)!.passwordsDoNotMatch,
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    var response = await _crud.postRequest(AppLink.resetPassword, {
      "email": widget.email,
      "reset_token": widget.verificationCode,
      "new_password": newPasswordController.text,
      "confirm_password": confirmPasswordController.text,
    });

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.passwordResetSuccessfully),
          backgroundColor: AppColor.successColor,
        ),
      );

      // Navigate to login page
      Future.delayed(Duration(milliseconds: 1000), () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/login",
              (route) => false,
        );
      });
    } else {
      String errorMessage = response["message"] ?? AppLocalizations.of(context)!.passwordResetFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            errorMessage,
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Icon
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(bottom: 20, top: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xff6b8b3c).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_open,
                      size: 50,
                      color: const Color(0xff6b8b3c),
                    ),
                  ),

                  SizedBox(height: 20),

                  Text(
                    AppLocalizations.of(context)!.createNewPassword,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 10),

                  Text(
                    AppLocalizations.of(context)!.enterNewPasswordBelow,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF666666),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40),

                  Text(
                    AppLocalizations.of(context)!.newPassword,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: 10),

                  CustomTextForm(
                    hintText: AppLocalizations.of(context)!.enterNewPassword,
                    controller: newPasswordController,
                    obscureText: true,
                    isPassword: true,
                  ),

                  SizedBox(height: 20),

                  Text(
                    AppLocalizations.of(context)!.confirmPassword,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: 10),

                  CustomTextForm(
                    hintText: AppLocalizations.of(context)!.confirmNewPassword,
                    controller: confirmPasswordController,
                    obscureText: true,
                    isPassword: true,
                  ),

                  SizedBox(height: 30),

                  Button(
                    title: AppLocalizations.of(context)!.resetPassword,
                    isLoading: isLoading,
                    onpressed: resetPassword,
                  ),

                  Spacer(),

                  // Back to login
                  Padding(
                    padding: EdgeInsets.only(bottom: 20, top: 20),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "/login",
                              (route) => false,
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.backToLogin,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}