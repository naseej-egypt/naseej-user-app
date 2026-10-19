import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/component/button.dart';
import 'package:naseej/component/textformfield.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/auth/forget_password_otp.dart';
import '../core/functions/checkinternet.dart';
import '../core/middleware/internet_middleware.dart';
import 'package:naseej/l10n/app_localizations.dart';

class ForgetPasswordEmailPage extends StatefulWidget {
  const ForgetPasswordEmailPage({super.key});

  @override
  State<ForgetPasswordEmailPage> createState() => _ForgetPasswordEmailPageState();
}

class _ForgetPasswordEmailPageState extends State<ForgetPasswordEmailPage> {
  TextEditingController emailController = TextEditingController();
  final Crud _crud = Crud();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendResetOTP() async {
    // CHECK INTERNET
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      showNoInternetDialog(context);
      return;
    }

    // Validation
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            AppLocalizations.of(context)!.pleaseEnterYourEmail,
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
            AppLocalizations.of(context)!.pleaseEnterValidEmailAddress,
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    var response = await _crud.postRequest(AppLink.forgotPassword, {
      "email": emailController.text,
    });

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.resetCodeSent),
          backgroundColor: AppColor.successColor,
        ),
      );

      // Navigate to OTP page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ForgetPasswordOTPPage(
            email: emailController.text,
          ),
        ),
      );
    } else {
      String errorMessage = response["message"] ?? AppLocalizations.of(context)!.failedToSendResetCode;
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
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 50,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: 20),

                  Text(
                    AppLocalizations.of(context)!.forgotPasswordTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 10),

                  Text(
                    AppLocalizations.of(context)!.enterEmailForResetCode,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF666666),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40),

                  Text(
                    AppLocalizations.of(context)!.email,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: 10),

                  CustomTextForm(
                    hintText: AppLocalizations.of(context)!.enterYourEmail,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SizedBox(height: 30),

                  Button(
                    title: AppLocalizations.of(context)!.sendResetCode,
                    isLoading: isLoading,
                    onpressed: sendResetOTP,
                  ),

                  Spacer(),

                  // Back to login
                  Padding(
                    padding: EdgeInsets.only(bottom: 20, top: 20),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
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