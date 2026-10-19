import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/component/button.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/auth/reset_password.dart';
import '../core/functions/checkinternet.dart';
import '../core/middleware/internet_middleware.dart';
import 'package:naseej/l10n/app_localizations.dart';

class ForgetPasswordOTPPage extends StatefulWidget {
  final String email;

  const ForgetPasswordOTPPage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _ForgetPasswordOTPPageState createState() => _ForgetPasswordOTPPageState();
}

class _ForgetPasswordOTPPageState extends State<ForgetPasswordOTPPage> {
  final TextEditingController _otpController = TextEditingController();
  final Crud _crud = Crud();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendCountdown--;
          if (_resendCountdown <= 0) {
            _canResend = true;
          } else {
            _startCountdown();
          }
        });
      }
    });
  }

  Future<void> _verifyOTP() async {
    // CHECK INTERNET
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      showNoInternetDialog(context);
      return;
    }

    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            AppLocalizations.of(context)!.pleaseEnterComplete6DigitCode,
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var response = await _crud.postRequest(AppLink.verifyResetOTP, {
      "email": widget.email,
      "otp": _otpController.text,
    });

    setState(() {
      _isLoading = false;
    });

    if (response["status"] == "success") {
      String resetToken = response["data"]["reset_token"];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.verificationSuccessful),
          backgroundColor: AppColor.successColor,
        ),
      );

      // Navigate to reset password page
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(
              email: widget.email,
              verificationCode: resetToken,
            ),
          ),
        );
      });
    } else {
      String errorMessage = response["message"] ?? AppLocalizations.of(context)!.verificationFailed;
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

  Future<void> _resendOTP() async {
    // CHECK INTERNET
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      showNoInternetDialog(context);
      return;
    }

    setState(() {
      _isResending = true;
    });

    var response = await _crud.postRequest(AppLink.resendOTP, {
      "email": widget.email,
      "type": "reset_password",
    });

    setState(() {
      _isResending = false;
    });

    if (response["status"] == "success") {
      // Reset countdown
      setState(() {
        _canResend = false;
        _resendCountdown = 60;
      });
      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.verificationCodeResent),
          backgroundColor: AppColor.successColor,
        ),
      );
    } else {
      String errorMessage = response["message"] ?? AppLocalizations.of(context)!.failedToResendCode;
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
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          padding: EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon
                Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phonelink_lock,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                SizedBox(height: 10),

                // Title
                Text(
                  AppLocalizations.of(context)!.enterVerificationCode,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                SizedBox(height: 8),

                // Description
                Text(
                  AppLocalizations.of(context)!.weSentCodeTo,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF666666),
                  ),
                ),

                SizedBox(height: 4),

                // Email
                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                SizedBox(height: 40),

                // OTP Input Field
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 60,
                    fieldWidth: 50,
                    activeFillColor: isDark ? const Color(0xFF2C2520) : Colors.white,
                    activeColor: Theme.of(context).colorScheme.primary,
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    selectedFillColor: isDark ? const Color(0xFF2C2520) : Colors.white,
                    inactiveColor: isDark ? const Color(0xFF4A4036) : const Color(0xFFE0E0E0),
                    inactiveFillColor: isDark ? const Color(0xFF2C2520) : Colors.white,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  keyboardType: TextInputType.number,
                  onCompleted: (v) {
                    _verifyOTP();
                  },
                  onChanged: (value) {},
                ),

                SizedBox(height: 30),

                // Verify Button
                Button(
                  title: AppLocalizations.of(context)!.verify,
                  isLoading: _isLoading,
                  onpressed: _verifyOTP,
                ),

                SizedBox(height: 40),

                // Resend Code Section
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.didntReceiveCode,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF666666),
                        ),
                      ),

                      SizedBox(height: 8),

                      if (_canResend)
                        TextButton(
                          onPressed: _isResending ? null : _resendOTP,
                          child: _isResending
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColor.primaryColor,
                              ),
                            ),
                          )
                              : Text(
                            AppLocalizations.of(context)!.resendCode,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      else
                        Text(
                          AppLocalizations.of(context)!.resendCodeIn(_resendCountdown),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}