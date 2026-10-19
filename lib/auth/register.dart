import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/pages/legal_page.dart';
import '../component/button.dart';
import '../component/crud.dart';
import '../component/logo.dart';
import '../component/textformfield.dart';
import '../core/functions/checkinternet.dart';
import '../core/middleware/internet_middleware.dart';
import 'email_verification_notification.dart';
import 'package:naseej/l10n/app_localizations.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmController = TextEditingController();

  Crud _crud = Crud();
  bool isLoading = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    nameController.dispose();
    phoneController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  signUp() async {
    // Check terms acceptance first
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            AppLocalizations.of(context)!.pleaseAcceptTerms,
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
      return;
    }

    // CHECK INTERNET FIRST
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      showNoInternetDialog(context);
      return;
    }

    // Validation
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passController.text.isEmpty ||
        confirmController.text.isEmpty) {
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

    if (passController.text.length < 6) {
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

    if (passController.text != confirmController.text) {
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

    var response = await _crud.postRequest(AppLink.signUp, {
      "name": nameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "password": passController.text,
      "confirm_password": confirmController.text,
    });

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.registrationSuccessful),
          backgroundColor: AppColor.successColor,
        ),
      );

      // Navigate to email verification notification
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => EmailVerificationNotification(
            email: emailController.text,
          ),
        ),
      );
    } else {
      String errorMessage = response["message"] ?? AppLocalizations.of(context)!.registrationFailed;
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
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(height: 50),
            Logo(),
            SizedBox(height: 30),
            Text(
              AppLocalizations.of(context)!.createAccount,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.enterInfoToGetStarted,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Text(
              AppLocalizations.of(context)!.fullName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            CustomTextForm(
              hintText: AppLocalizations.of(context)!.enterFullName,
              controller: nameController,
            ),
            SizedBox(height: 20),
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
              AppLocalizations.of(context)!.phoneNumber,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            CustomTextForm(
              hintText: AppLocalizations.of(context)!.enterYourPhoneNumber,
              controller: phoneController,
              keyboardType: TextInputType.phone,
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
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.confirmPassword,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            CustomTextForm(
              hintText: AppLocalizations.of(context)!.confirmYourPassword,
              controller: confirmController,
              obscureText: true,
              isPassword: true,
            ),
            SizedBox(height: 20),

            // Terms & Privacy checkbox
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : AppColor.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _termsAccepted
                      ? AppColor.primaryColor.withOpacity(0.3)
                      : AppColor.borderGray,
                ),
              ),
              child: CheckboxListTile(
                value: _termsAccepted,
                onChanged: (value) {
                  setState(() => _termsAccepted = value ?? false);
                },
                activeColor: AppColor.primaryColor,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                title: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : AppColor.grey2,
                    ),
                    children: [
                      TextSpan(
                        text: '${AppLocalizations.of(context)!.iHaveReadAndAccept} ',
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.termsOfService,
                        style: TextStyle(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => LegalPage.launchTermsOfServiceUrl(),
                      ),
                      TextSpan(text: ' & '),
                      TextSpan(
                        text: AppLocalizations.of(context)!.privacyPolicy,
                        style: TextStyle(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => LegalPage.launchPrivacyPolicyUrl(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            Button(
              title: AppLocalizations.of(context)!.register,
              isLoading: isLoading,
              onpressed: signUp,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.alreadyHaveAccount,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.login,
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