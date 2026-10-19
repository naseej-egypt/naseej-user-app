import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/component/custom_button.dart';
import 'package:naseej/component/custom_text_field.dart';
import 'package:naseej/utils/validators.dart';
import 'package:naseej/main.dart';

import '../core/ChangePasswordController.dart';
import 'package:naseej/l10n/app_localizations.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(changePasswordProvider);
      final success = await controller.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorSnackbar(controller.errorMessage);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppColor.successColor),
              SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.success, style: TextStyle(color: AppColor.successColor)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.passwordChangedSuccessfully),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.logoutAfterPasswordChange,
                style: TextStyle(fontSize: 14, color: AppColor.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logoutAndNavigate();
              },
              child: Text(AppLocalizations.of(context)!.ok, style: TextStyle(color: AppColor.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _logoutAndNavigate() {
    // Clear user data and token
    sharedPref.remove("user_id");
    sharedPref.remove("user_email");
    sharedPref.remove("user_name");
    sharedPref.remove("user_phone");
    sharedPref.remove("token");
    sharedPref.setString("step", "1"); // Reset to login step

    // Navigate to login screen
    Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.warningColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.changePassword),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security Icon with Info
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security_outlined,
                        size: 40,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.securityLogoutNotice,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.secondColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Current Password
              CustomTextField(
                controller: currentPasswordController,
                label: AppLocalizations.of(context)!.currentPassword,
                hint: AppLocalizations.of(context)!.enterCurrentPassword,
                prefixIcon: Icon(Icons.lock, color: AppColor.primaryColor),
                obscureText: !showCurrentPassword,
                validator: (value) => Validators.validateRequired(value, 'Current password'),
                suffixIcon: IconButton(
                  icon: Icon(
                    showCurrentPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColor.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      showCurrentPassword = !showCurrentPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // New Password
              CustomTextField(
                controller: newPasswordController,
                label: AppLocalizations.of(context)!.newPassword,
                hint: AppLocalizations.of(context)!.enterNewPassword,
                prefixIcon: Icon(Icons.lock_outline, color: AppColor.primaryColor),
                obscureText: !showNewPassword,
                validator: Validators.validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    showNewPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColor.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      showNewPassword = !showNewPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              CustomTextField(
                controller: confirmPasswordController,
                label: AppLocalizations.of(context)!.confirmNewPassword,
                hint: AppLocalizations.of(context)!.confirmYourNewPassword,
                prefixIcon: Icon(Icons.lock_outline, color: AppColor.primaryColor),
                obscureText: !showConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseConfirmPassword;
                  }
                  if (value != newPasswordController.text) {
                    return AppLocalizations.of(context)!.passwordsDoNotMatchValidator;
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColor.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.warningColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColor.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.autoLogoutNotice,
                        style: TextStyle(
                          color: AppColor.warningColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Password Requirements
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.backgroundcolor2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.passwordRequirements,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context)!.passwordReq1, style: TextStyle(fontSize: 14)),
                    Text(AppLocalizations.of(context)!.passwordReq2, style: TextStyle(fontSize: 14)),
                    Text(AppLocalizations.of(context)!.passwordReq3, style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Update Button
              CustomButton(
                text: AppLocalizations.of(context)!.updatePasswordAndLogout,
                onPressed: ref.watch(changePasswordProvider).isLoading ? null : _changePassword,
                isLoading: ref.watch(changePasswordProvider).isLoading,
                backgroundColor: AppColor.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}