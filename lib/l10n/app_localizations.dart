import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Naseej'**
  String get appName;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Weave Your Story'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Naseej, where every handmade Egyptian carpet embodies timeless design and heritage.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Artistry, Handcrafted with Care'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'We honor the tradition and skill of our weavers, bringing you authentic, quality pieces.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Global Style, Ancient Roots'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Discover our exquisite collection of handmade carpets, blending heritage with modern aesthetics.'**
  String get onboardingBody3;

  /// No description provided for @welcomeAboard.
  ///
  /// In en, this message translates to:
  /// **'Welcome Aboard!'**
  String get welcomeAboard;

  /// No description provided for @settingUpExperience.
  ///
  /// In en, this message translates to:
  /// **'Setting up your experience...'**
  String get settingUpExperience;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get loginToContinue;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @enterInfoToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Enter your information to get started'**
  String get enterInfoToGetStarted;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please verify your email.'**
  String get registrationSuccessful;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @pleaseVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before logging in'**
  String get pleaseVerifyEmail;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @enterEmailForResetCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset code'**
  String get enterEmailForResetCode;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get sendResetCode;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmailAddress;

  /// No description provided for @resetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Reset code sent successfully!'**
  String get resetCodeSent;

  /// No description provided for @failedToSendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset code'**
  String get failedToSendResetCode;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @weSentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to'**
  String get weSentCodeTo;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds} seconds'**
  String resendCodeIn(int seconds);

  /// No description provided for @pleaseEnterComplete6DigitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete 6-digit code'**
  String get pleaseEnterComplete6DigitCode;

  /// No description provided for @verificationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Verification successful!'**
  String get verificationSuccessful;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// No description provided for @verificationCodeResent.
  ///
  /// In en, this message translates to:
  /// **'Verification code resent!'**
  String get verificationCodeResent;

  /// No description provided for @verificationCodeResentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Verification code resent successfully!'**
  String get verificationCodeResentSuccessfully;

  /// No description provided for @failedToResendCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend code'**
  String get failedToResendCode;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// No description provided for @enterNewPasswordBelow.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below'**
  String get enterNewPasswordBelow;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @confirmYourNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get confirmYourNewPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @passwordResetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully!'**
  String get passwordResetSuccessfully;

  /// No description provided for @passwordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Password reset failed'**
  String get passwordResetFailed;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification Email Sent'**
  String get verificationEmailSent;

  /// No description provided for @verificationEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification code to your email address. Please check your inbox and enter the code to verify your account.'**
  String get verificationEmailDescription;

  /// No description provided for @checkInboxInstruction.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox for the verification code'**
  String get checkInboxInstruction;

  /// No description provided for @codeExpiresIn30Min.
  ///
  /// In en, this message translates to:
  /// **'Code expires in 30 minutes'**
  String get codeExpiresIn30Min;

  /// No description provided for @checkSpamFolder.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to check your spam folder'**
  String get checkSpamFolder;

  /// No description provided for @didntReceiveCodeResend.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? Resend'**
  String get didntReceiveCodeResend;

  /// No description provided for @emailVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerifiedSuccessfully;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @ourStores.
  ///
  /// In en, this message translates to:
  /// **'Our Stores'**
  String get ourStores;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @updateProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Update Profile Image'**
  String get updateProfileImage;

  /// No description provided for @uploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading Image'**
  String get uploadingImage;

  /// No description provided for @profileImageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile image updated successfully'**
  String get profileImageUpdated;

  /// No description provided for @failedToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get failedToUploadImage;

  /// No description provided for @errorSelectingImage.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get errorSelectingImage;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @handcraftedEgyptianCarpets.
  ///
  /// In en, this message translates to:
  /// **'Handcrafted Egyptian Carpets'**
  String get handcraftedEgyptianCarpets;

  /// No description provided for @discoverTimelessElegance.
  ///
  /// In en, this message translates to:
  /// **'Discover timeless elegance woven with tradition'**
  String get discoverTimelessElegance;

  /// No description provided for @specialOffer.
  ///
  /// In en, this message translates to:
  /// **'Special Offer'**
  String get specialOffer;

  /// No description provided for @upTo30Off.
  ///
  /// In en, this message translates to:
  /// **'Up to 30% OFF'**
  String get upTo30Off;

  /// No description provided for @onTraditionalCarpets.
  ///
  /// In en, this message translates to:
  /// **'On Traditional Handwoven Carpets'**
  String get onTraditionalCarpets;

  /// No description provided for @newArrival.
  ///
  /// In en, this message translates to:
  /// **'New Arrival'**
  String get newArrival;

  /// No description provided for @premiumCollection.
  ///
  /// In en, this message translates to:
  /// **'Premium Collection'**
  String get premiumCollection;

  /// No description provided for @discoverLatestDesigns.
  ///
  /// In en, this message translates to:
  /// **'Discover Our Latest Designs'**
  String get discoverLatestDesigns;

  /// No description provided for @freeShipping.
  ///
  /// In en, this message translates to:
  /// **'Free Shipping'**
  String get freeShipping;

  /// No description provided for @ordersOver300.
  ///
  /// In en, this message translates to:
  /// **'Orders Over \$300'**
  String get ordersOver300;

  /// No description provided for @limitedTimeOffer.
  ///
  /// In en, this message translates to:
  /// **'Limited Time Offer'**
  String get limitedTimeOffer;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendedForYou;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get shopNow;

  /// No description provided for @loadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Loading products...'**
  String get loadingProducts;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshing;

  /// No description provided for @errorLoadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Error loading products'**
  String get errorLoadingProducts;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get noProductsAvailable;

  /// No description provided for @noProductsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No products found in this category'**
  String get noProductsInCategory;

  /// No description provided for @viewAllProducts.
  ///
  /// In en, this message translates to:
  /// **'View All Products'**
  String get viewAllProducts;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProducts;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @alwaysUseLight.
  ///
  /// In en, this message translates to:
  /// **'Always Use Light'**
  String get alwaysUseLight;

  /// No description provided for @alwaysUseDark.
  ///
  /// In en, this message translates to:
  /// **'Always Use Dark'**
  String get alwaysUseDark;

  /// No description provided for @followSystemTheme.
  ///
  /// In en, this message translates to:
  /// **'Follow System Theme'**
  String get followSystemTheme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @quickToggle.
  ///
  /// In en, this message translates to:
  /// **'Quick Toggle'**
  String get quickToggle;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @receiveNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive Notifications'**
  String get receiveNotifications;

  /// No description provided for @languageChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Language Changed Successfully'**
  String get languageChangedSuccessfully;

  /// No description provided for @themeChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Theme Changed Successfully'**
  String get themeChangedSuccessfully;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @managePaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Payment Methods'**
  String get managePaymentMethods;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updateAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Update Account Password'**
  String get updateAccountPassword;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountPermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Account Permanently'**
  String get deleteAccountPermanently;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpFaq.
  ///
  /// In en, this message translates to:
  /// **'Help FAQ'**
  String get helpFaq;

  /// No description provided for @getHelpAnswers.
  ///
  /// In en, this message translates to:
  /// **'Get Help Answers'**
  String get getHelpAnswers;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report Bug'**
  String get reportBug;

  /// No description provided for @helpImproveApp.
  ///
  /// In en, this message translates to:
  /// **'Help Improve App'**
  String get helpImproveApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account Permanently?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted:'**
  String get deleteAccountWarning;

  /// No description provided for @personalInfoAndProfile.
  ///
  /// In en, this message translates to:
  /// **'Personal information and profile'**
  String get personalInfoAndProfile;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get orderHistory;

  /// No description provided for @savedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses'**
  String get savedAddresses;

  /// No description provided for @favoriteProducts.
  ///
  /// In en, this message translates to:
  /// **'Favorite products'**
  String get favoriteProducts;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account Deleted'**
  String get accountDeleted;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted successfully.'**
  String get accountDeletedSuccess;

  /// No description provided for @allDataRemoved.
  ///
  /// In en, this message translates to:
  /// **'All your data has been permanently removed from our system.'**
  String get allDataRemoved;

  /// No description provided for @editYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Your Profile'**
  String get editYourProfile;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No Email'**
  String get noEmail;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @failedToUpdateProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile image'**
  String get failedToUpdateProfileImage;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get errorPickingImage;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @securityLogoutNotice.
  ///
  /// In en, this message translates to:
  /// **'For security reasons, you will be logged out\nafter changing your password.'**
  String get securityLogoutNotice;

  /// No description provided for @autoLogoutNotice.
  ///
  /// In en, this message translates to:
  /// **'You will be automatically logged out after password change for security purposes.'**
  String get autoLogoutNotice;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password Requirements:'**
  String get passwordRequirements;

  /// No description provided for @passwordReq1.
  ///
  /// In en, this message translates to:
  /// **'• At least 6 characters long'**
  String get passwordReq1;

  /// No description provided for @passwordReq2.
  ///
  /// In en, this message translates to:
  /// **'• Include uppercase and lowercase letters'**
  String get passwordReq2;

  /// No description provided for @passwordReq3.
  ///
  /// In en, this message translates to:
  /// **'• Include numbers and special characters'**
  String get passwordReq3;

  /// No description provided for @updatePasswordAndLogout.
  ///
  /// In en, this message translates to:
  /// **'Update Password & Logout'**
  String get updatePasswordAndLogout;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChangedSuccessfully;

  /// No description provided for @logoutAfterPasswordChange.
  ///
  /// In en, this message translates to:
  /// **'For security reasons, you will be logged out and need to login again with your new password.'**
  String get logoutAfterPasswordChange;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnection;

  /// No description provided for @checkInternetAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again'**
  String get checkInternetAndRetry;

  /// No description provided for @noInternetConnectionSmall.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnectionSmall;

  /// No description provided for @connectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Connection restored - refreshing content...'**
  String get connectionRestored;

  /// No description provided for @connectedToInternet.
  ///
  /// In en, this message translates to:
  /// **'Connected to internet'**
  String get connectedToInternet;

  /// No description provided for @visitFAQPage.
  ///
  /// In en, this message translates to:
  /// **'Visit FAQ Page'**
  String get visitFAQPage;

  /// No description provided for @browseFAQ.
  ///
  /// In en, this message translates to:
  /// **'Browse our comprehensive FAQ'**
  String get browseFAQ;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @getHelpViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Get help via email'**
  String get getHelpViaEmail;

  /// No description provided for @whatsappSupport.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get whatsappSupport;

  /// No description provided for @chatWithSupport.
  ///
  /// In en, this message translates to:
  /// **'Chat with our support team'**
  String get chatWithSupport;

  /// No description provided for @emailBugReport.
  ///
  /// In en, this message translates to:
  /// **'Email Bug Report'**
  String get emailBugReport;

  /// No description provided for @sendDetailedBugReport.
  ///
  /// In en, this message translates to:
  /// **'Send detailed bug report via email'**
  String get sendDetailedBugReport;

  /// No description provided for @submitBugReportForm.
  ///
  /// In en, this message translates to:
  /// **'Submit Bug Report Form'**
  String get submitBugReportForm;

  /// No description provided for @fillOutOnlineForm.
  ///
  /// In en, this message translates to:
  /// **'Fill out our online form'**
  String get fillOutOnlineForm;

  /// No description provided for @reportViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Report via WhatsApp'**
  String get reportViaWhatsApp;

  /// No description provided for @quickReportWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Quick report through WhatsApp'**
  String get quickReportWhatsApp;

  /// No description provided for @couldNotOpenPage.
  ///
  /// In en, this message translates to:
  /// **'Could not open the page. Please try again.'**
  String get couldNotOpenPage;

  /// No description provided for @couldNotOpenWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp. Please ensure it\'s installed.'**
  String get couldNotOpenWhatsapp;

  /// No description provided for @aboutOurFamilyBusiness.
  ///
  /// In en, this message translates to:
  /// **'About Our Family Business'**
  String get aboutOurFamilyBusiness;

  /// No description provided for @naseejHandmadeCarpets.
  ///
  /// In en, this message translates to:
  /// **'Naseej Handmade Carpets'**
  String get naseejHandmadeCarpets;

  /// No description provided for @egyptianHeritageSince1990.
  ///
  /// In en, this message translates to:
  /// **'Egyptian Heritage Since 1990'**
  String get egyptianHeritageSince1990;

  /// No description provided for @meetOurTeam.
  ///
  /// In en, this message translates to:
  /// **'Meet Our Team'**
  String get meetOurTeam;

  /// No description provided for @threeGenerationsExpertise.
  ///
  /// In en, this message translates to:
  /// **'Three generations of expertise in Egyptian handmade carpets'**
  String get threeGenerationsExpertise;

  /// No description provided for @ownerAndManager.
  ///
  /// In en, this message translates to:
  /// **'Owner & Manager'**
  String get ownerAndManager;

  /// No description provided for @thirtyPlusYearsExperience.
  ///
  /// In en, this message translates to:
  /// **'30+ Years Experience'**
  String get thirtyPlusYearsExperience;

  /// No description provided for @ashrafDescription.
  ///
  /// In en, this message translates to:
  /// **'Master craftsman with over three decades of experience in authentic Egyptian handmade carpets. Known for exceptional craftsmanship and business excellence.'**
  String get ashrafDescription;

  /// No description provided for @coFounderSeniorDesigner.
  ///
  /// In en, this message translates to:
  /// **'Co-Founder & Senior Designer'**
  String get coFounderSeniorDesigner;

  /// No description provided for @graphicUiUxDesigner.
  ///
  /// In en, this message translates to:
  /// **'Graphic & UI/UX Designer'**
  String get graphicUiUxDesigner;

  /// No description provided for @amrDescription.
  ///
  /// In en, this message translates to:
  /// **'Creative director and senior designer specializing in visual identity, brand design, and user experience design for modern businesses.'**
  String get amrDescription;

  /// No description provided for @mobileAppDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Mobile App Developer'**
  String get mobileAppDeveloper;

  /// No description provided for @flutterDartExpert.
  ///
  /// In en, this message translates to:
  /// **'Flutter & Dart Expert'**
  String get flutterDartExpert;

  /// No description provided for @yasserDescription.
  ///
  /// In en, this message translates to:
  /// **'Specialized in building production-ready mobile applications with modern technology stacks. Bringing traditional craftsmanship to digital platforms.'**
  String get yasserDescription;

  /// No description provided for @contactViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Contact via WhatsApp'**
  String get contactViaWhatsApp;

  /// No description provided for @callDirectly.
  ///
  /// In en, this message translates to:
  /// **'Call directly'**
  String get callDirectly;

  /// No description provided for @viewPortfolio.
  ///
  /// In en, this message translates to:
  /// **'View Portfolio'**
  String get viewPortfolio;

  /// No description provided for @viewLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'View LinkedIn profile'**
  String get viewLinkedIn;

  /// No description provided for @familyPrideAndLegacy.
  ///
  /// In en, this message translates to:
  /// **'Family Pride & Legacy'**
  String get familyPrideAndLegacy;

  /// No description provided for @threeGenerationsCraftsmanship.
  ///
  /// In en, this message translates to:
  /// **'Three Generations of Craftsmanship'**
  String get threeGenerationsCraftsmanship;

  /// No description provided for @traditionalEgyptianWeaving.
  ///
  /// In en, this message translates to:
  /// **'Traditional Egyptian Weaving'**
  String get traditionalEgyptianWeaving;

  /// No description provided for @naturalMaterials.
  ///
  /// In en, this message translates to:
  /// **'100% Natural Materials'**
  String get naturalMaterials;

  /// No description provided for @customDesignsAndSizes.
  ///
  /// In en, this message translates to:
  /// **'Custom Designs & Sizes'**
  String get customDesignsAndSizes;

  /// No description provided for @qualityGuaranteed.
  ///
  /// In en, this message translates to:
  /// **'Quality Guaranteed'**
  String get qualityGuaranteed;

  /// No description provided for @traditionWithTechnology.
  ///
  /// In en, this message translates to:
  /// **'Tradition with Technology'**
  String get traditionWithTechnology;

  /// No description provided for @aFamilyLegacy.
  ///
  /// In en, this message translates to:
  /// **'A Family Legacy'**
  String get aFamilyLegacy;

  /// No description provided for @familyLegacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Proudly continuing our family tradition of excellence in Egyptian handmade carpets, now enhanced with modern technology to serve customers worldwide. Our commitment to quality and authenticity remains unchanged through generations.'**
  String get familyLegacyDescription;

  /// No description provided for @theGaberFamily.
  ///
  /// In en, this message translates to:
  /// **'The Gaber Family'**
  String get theGaberFamily;

  /// No description provided for @shoppingCart.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get shoppingCart;

  /// No description provided for @loadingYourCart.
  ///
  /// In en, this message translates to:
  /// **'Loading your cart...'**
  String get loadingYourCart;

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your Cart is Empty'**
  String get yourCartIsEmpty;

  /// No description provided for @addBeautifulCarpets.
  ///
  /// In en, this message translates to:
  /// **'Add beautiful carpets to get started'**
  String get addBeautifulCarpets;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart?'**
  String get clearCart;

  /// No description provided for @removeAllItems.
  ///
  /// In en, this message translates to:
  /// **'Remove all items from your cart?'**
  String get removeAllItems;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @continueToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Continue to Checkout'**
  String get continueToCheckout;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @itemRemovedFromCart.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get itemRemovedFromCart;

  /// No description provided for @cartClearedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cart cleared successfully'**
  String get cartClearedSuccessfully;

  /// No description provided for @failedToLoadCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cart'**
  String get failedToLoadCart;

  /// No description provided for @failedToUpdateQuantity.
  ///
  /// In en, this message translates to:
  /// **'Failed to update quantity'**
  String get failedToUpdateQuantity;

  /// No description provided for @failedToRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove item'**
  String get failedToRemoveItem;

  /// No description provided for @failedToClearCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cart'**
  String get failedToClearCart;

  /// No description provided for @yourCartIsEmptyCheckout.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get yourCartIsEmptyCheckout;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @addMoreForFreeShipping.
  ///
  /// In en, this message translates to:
  /// **'Add \${amount} more for free shipping!'**
  String addMoreForFreeShipping(String amount);

  /// No description provided for @youGotFreeShipping.
  ///
  /// In en, this message translates to:
  /// **'You got free shipping!'**
  String get youGotFreeShipping;

  /// No description provided for @carpets.
  ///
  /// In en, this message translates to:
  /// **'Carpets'**
  String get carpets;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @searchCarpets.
  ///
  /// In en, this message translates to:
  /// **'Search carpets...'**
  String get searchCarpets;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @searchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Search Results for \"{query}\"'**
  String searchResultsFor(String query);

  /// No description provided for @noProductsFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No products found for \"{query}\"'**
  String noProductsFoundFor(String query);

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get noFavoritesYet;

  /// No description provided for @startMarkingFavorites.
  ///
  /// In en, this message translates to:
  /// **'Start marking your favorite products to see them here'**
  String get startMarkingFavorites;

  /// No description provided for @tapHeartIcon.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any product to add it to your favorites'**
  String get tapHeartIcon;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @pleaseLoginToViewFavorites.
  ///
  /// In en, this message translates to:
  /// **'Please login to view favorites'**
  String get pleaseLoginToViewFavorites;

  /// No description provided for @errorLoadingFavorites.
  ///
  /// In en, this message translates to:
  /// **'Error loading favorites'**
  String get errorLoadingFavorites;

  /// No description provided for @addingToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Adding to favorites...'**
  String get addingToFavorites;

  /// No description provided for @removingFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removing from favorites...'**
  String get removingFromFavorites;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @failedToUpdateFavorite.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite'**
  String get failedToUpdateFavorite;

  /// No description provided for @ourStoresTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Stores'**
  String get ourStoresTitle;

  /// No description provided for @searchStores.
  ///
  /// In en, this message translates to:
  /// **'Search stores by name, address, or city...'**
  String get searchStores;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @loadingStores.
  ///
  /// In en, this message translates to:
  /// **'Loading stores...'**
  String get loadingStores;

  /// No description provided for @failedToLoadStores.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stores'**
  String get failedToLoadStores;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noStoresFound.
  ///
  /// In en, this message translates to:
  /// **'No stores found'**
  String get noStoresFound;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFilters;

  /// No description provided for @storesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} stores found'**
  String storesFound(int count);

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @callStore.
  ///
  /// In en, this message translates to:
  /// **'Call Store'**
  String get callStore;

  /// No description provided for @openOnMap.
  ///
  /// In en, this message translates to:
  /// **'Open on Map'**
  String get openOnMap;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get openNow;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @storeDetails.
  ///
  /// In en, this message translates to:
  /// **'Store Details'**
  String get storeDetails;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @phoneNumber2.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber2;

  /// No description provided for @specialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get specialOffers;

  /// No description provided for @discounts.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get discounts;

  /// No description provided for @amazingDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Amazing Discounts!'**
  String get amazingDiscounts;

  /// No description provided for @otherProducts.
  ///
  /// In en, this message translates to:
  /// **'Other Products'**
  String get otherProducts;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get newArrivals;

  /// No description provided for @premiumCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Collection'**
  String get premiumCollectionTitle;

  /// No description provided for @freeShippingProducts.
  ///
  /// In en, this message translates to:
  /// **'Free Shipping Products'**
  String get freeShippingProducts;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @selectSize.
  ///
  /// In en, this message translates to:
  /// **'Select Size'**
  String get selectSize;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart successfully!'**
  String get addedToCart;

  /// No description provided for @failedToAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cart'**
  String get failedToAddToCart;

  /// No description provided for @pleaseSelectSize.
  ///
  /// In en, this message translates to:
  /// **'Please select a size'**
  String get pleaseSelectSize;

  /// No description provided for @pleaseSelectColor.
  ///
  /// In en, this message translates to:
  /// **'Please select a color'**
  String get pleaseSelectColor;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'available'**
  String get available;

  /// No description provided for @freeShippingTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Shipping'**
  String get freeShippingTitle;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @relatedProducts.
  ///
  /// In en, this message translates to:
  /// **'Related Products'**
  String get relatedProducts;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get material;

  /// No description provided for @dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get dimensions;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @similarProducts.
  ///
  /// In en, this message translates to:
  /// **'Similar Products'**
  String get similarProducts;

  /// No description provided for @viewProduct.
  ///
  /// In en, this message translates to:
  /// **'View Product'**
  String get viewProduct;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @selectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Address'**
  String get selectAddress;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @orderPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get orderPlacedSuccessfully;

  /// No description provided for @failedToPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to place order'**
  String get failedToPlaceOrder;

  /// No description provided for @promoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get promoCode;

  /// No description provided for @applyPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyPromoCode;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @estimatedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery'**
  String get estimatedDelivery;

  /// No description provided for @businessDays.
  ///
  /// In en, this message translates to:
  /// **'business days'**
  String get businessDays;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @noAddressAdded.
  ///
  /// In en, this message translates to:
  /// **'No address added'**
  String get noAddressAdded;

  /// No description provided for @pleaseAddAddress.
  ///
  /// In en, this message translates to:
  /// **'Please add a shipping address'**
  String get pleaseAddAddress;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No Orders Yet'**
  String get noOrdersYet;

  /// No description provided for @startShoppingToSeeOrders.
  ///
  /// In en, this message translates to:
  /// **'Start shopping to see your orders here'**
  String get startShoppingToSeeOrders;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get startShopping;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeOrders;

  /// No description provided for @completedOrders.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedOrders;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @shippingDetails.
  ///
  /// In en, this message translates to:
  /// **'Shipping Details'**
  String get shippingDetails;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order? This action cannot be undone.'**
  String get cancelOrderConfirm;

  /// No description provided for @keepOrder.
  ///
  /// In en, this message translates to:
  /// **'Keep Order'**
  String get keepOrder;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address Line 1'**
  String get addressLine1;

  /// No description provided for @addressLine2.
  ///
  /// In en, this message translates to:
  /// **'Address Line 2 (Optional)'**
  String get addressLine2;

  /// No description provided for @cityField.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityField;

  /// No description provided for @stateProvince.
  ///
  /// In en, this message translates to:
  /// **'State/Province'**
  String get stateProvince;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCode;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get saveAddress;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddress;

  /// No description provided for @defaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default Address'**
  String get defaultAddress;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @noAddressesYet.
  ///
  /// In en, this message translates to:
  /// **'No addresses yet'**
  String get noAddressesYet;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method'**
  String get addPaymentMethod;

  /// No description provided for @editPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Method'**
  String get editPaymentMethod;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @cardHolderName.
  ///
  /// In en, this message translates to:
  /// **'Card Holder Name'**
  String get cardHolderName;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @deletePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Delete Payment Method'**
  String get deletePaymentMethod;

  /// No description provided for @noPaymentMethodsYet.
  ///
  /// In en, this message translates to:
  /// **'No payment methods yet'**
  String get noPaymentMethodsYet;

  /// No description provided for @noPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'No payment methods'**
  String get noPaymentMethods;

  /// No description provided for @deletePayment.
  ///
  /// In en, this message translates to:
  /// **'Delete Payment'**
  String get deletePayment;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderName;

  /// No description provided for @expiryMonth.
  ///
  /// In en, this message translates to:
  /// **'Expiry Month'**
  String get expiryMonth;

  /// No description provided for @expiryYear.
  ///
  /// In en, this message translates to:
  /// **'Expiry Year'**
  String get expiryYear;

  /// No description provided for @savePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Save Payment Method'**
  String get savePaymentMethod;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @tapToEdit.
  ///
  /// In en, this message translates to:
  /// **'Tap to Edit'**
  String get tapToEdit;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get myAddresses;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @phoneNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Optional)'**
  String get phoneNumberOptional;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get termsAndPrivacy;

  /// No description provided for @pleaseReviewAndAccept.
  ///
  /// In en, this message translates to:
  /// **'Please review and accept our Privacy Policy and Terms of Service to continue using the app.'**
  String get pleaseReviewAndAccept;

  /// No description provided for @privacyPolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn how we collect, use, and protect your personal data. Your privacy is important to us.'**
  String get privacyPolicyDescription;

  /// No description provided for @termsOfServiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Review the rules, guidelines, and agreements governing your use of the Naseej app.'**
  String get termsOfServiceDescription;

  /// No description provided for @readFullDocument.
  ///
  /// In en, this message translates to:
  /// **'Read full document'**
  String get readFullDocument;

  /// No description provided for @iHaveReadAndAccept.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the'**
  String get iHaveReadAndAccept;

  /// No description provided for @acceptAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Accept & Continue'**
  String get acceptAndContinue;

  /// No description provided for @consentInfoText.
  ///
  /// In en, this message translates to:
  /// **'You can review these documents anytime from the Settings page. By continuing, you agree to our data practices and usage terms.'**
  String get consentInfoText;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get openInBrowser;

  /// No description provided for @tapToViewDocument.
  ///
  /// In en, this message translates to:
  /// **'Tap below to view the full document in your browser.'**
  String get tapToViewDocument;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @viewPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'View Privacy Policy'**
  String get viewPrivacyPolicy;

  /// No description provided for @viewTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'View Terms of Service'**
  String get viewTermsOfService;

  /// No description provided for @iAgreeToTermsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get iAgreeToTermsAndPrivacy;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms of Service and Privacy Policy to register'**
  String get pleaseAcceptTerms;

  /// No description provided for @helpFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Help FAQ'**
  String get helpFaqTitle;

  /// No description provided for @reportBugTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Bug'**
  String get reportBugTitle;

  /// No description provided for @errorOpeningPage.
  ///
  /// In en, this message translates to:
  /// **'Error opening page'**
  String get errorOpeningPage;

  /// No description provided for @couldNotOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not open email. Please contact: '**
  String get couldNotOpenEmail;

  /// No description provided for @couldNotOpenWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp. Please ensure it is installed.'**
  String get couldNotOpenWhatsApp;

  /// No description provided for @errorOpeningWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Error opening WhatsApp'**
  String get errorOpeningWhatsApp;

  /// No description provided for @couldNotOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open URL'**
  String get couldNotOpenUrl;

  /// No description provided for @profileImageUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile image updated successfully'**
  String get profileImageUpdatedSuccessfully;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorGeneric;

  /// No description provided for @passwordsDoNotMatchValidator.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatchValidator;

  /// No description provided for @failedToLoadCheckoutData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load some checkout data. Please try again.'**
  String get failedToLoadCheckoutData;

  /// No description provided for @errorLoadingCheckoutData.
  ///
  /// In en, this message translates to:
  /// **'Error loading checkout data'**
  String get errorLoadingCheckoutData;

  /// No description provided for @failedToLoadPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payment methods'**
  String get failedToLoadPaymentMethods;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @paymentMethodDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payment method deleted successfully'**
  String get paymentMethodDeletedSuccessfully;

  /// No description provided for @failedToDeletePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete payment method'**
  String get failedToDeletePaymentMethod;

  /// No description provided for @defaultPaymentMethodUpdated.
  ///
  /// In en, this message translates to:
  /// **'Default payment method updated'**
  String get defaultPaymentMethodUpdated;

  /// No description provided for @failedToSetDefaultPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Failed to set default payment method'**
  String get failedToSetDefaultPaymentMethod;

  /// No description provided for @helloNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Hello, I need help with Naseej app'**
  String get helloNeedHelp;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @changeAction.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeAction;

  /// No description provided for @changeStore.
  ///
  /// In en, this message translates to:
  /// **'Change Store'**
  String get changeStore;

  /// No description provided for @changeCard.
  ///
  /// In en, this message translates to:
  /// **'Change Card'**
  String get changeCard;

  /// No description provided for @deliveryMethod.
  ///
  /// In en, this message translates to:
  /// **'Delivery Method'**
  String get deliveryMethod;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @selectDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Address'**
  String get selectDeliveryAddress;

  /// No description provided for @addDeliveryAddressToContinue.
  ///
  /// In en, this message translates to:
  /// **'Add a delivery address to continue with your order'**
  String get addDeliveryAddressToContinue;

  /// No description provided for @addYourDeliveryAddressesToMakeCheckoutFaster.
  ///
  /// In en, this message translates to:
  /// **'Add your delivery addresses to make checkout faster'**
  String get addYourDeliveryAddressesToMakeCheckoutFaster;

  /// No description provided for @pleaseSelectDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery address'**
  String get pleaseSelectDeliveryAddress;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removedFromFavoritesText.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavoritesText;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @pleaseLoginToAddItemsToCart.
  ///
  /// In en, this message translates to:
  /// **'Please login to add items to cart'**
  String get pleaseLoginToAddItemsToCart;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @pleaseSelectStoreForPickup.
  ///
  /// In en, this message translates to:
  /// **'Please select a store for pickup'**
  String get pleaseSelectStoreForPickup;

  /// No description provided for @pleaseSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment method'**
  String get pleaseSelectPaymentMethod;

  /// No description provided for @errorPlacingOrder.
  ///
  /// In en, this message translates to:
  /// **'Error placing order'**
  String get errorPlacingOrder;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @selectStoreForPickup.
  ///
  /// In en, this message translates to:
  /// **'Select Store for Pickup'**
  String get selectStoreForPickup;

  /// No description provided for @noStoresAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stores available'**
  String get noStoresAvailable;

  /// No description provided for @pleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get pleaseTryAgainLater;

  /// No description provided for @addPaymentCardToUseOnlinePayment.
  ///
  /// In en, this message translates to:
  /// **'Add a payment card to use online payment'**
  String get addPaymentCardToUseOnlinePayment;

  /// No description provided for @addNewCard.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addNewCard;

  /// No description provided for @hoursNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Hours not available'**
  String get hoursNotAvailable;

  /// No description provided for @loadingCheckoutData.
  ///
  /// In en, this message translates to:
  /// **'Loading checkout data...'**
  String get loadingCheckoutData;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @cartUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cart updated successfully'**
  String get cartUpdatedSuccessfully;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
