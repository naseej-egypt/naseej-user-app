import 'package:flutter/material.dart';
import 'package:naseej/main.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/utils/language_manager.dart';
import 'package:naseej/utils/theme_manager.dart';
import '../core/DeleteAccountController.dart';
import 'change_password_screen.dart';
import 'payment/payment_methods_page.dart';
import 'package:naseej/utils/helpsupport.dart';
import 'package:naseej/pages/legal_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naseej/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool autoSaveEnabled = true;
  String currentLanguage = LanguageManager.getCurrentLanguageCode();
  ThemeMode currentThemeMode = ThemeManager.getThemeMode();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() {
    setState(() {
      notificationsEnabled = sharedPref.getBool("notifications_enabled") ?? true;
      autoSaveEnabled = sharedPref.getBool("auto_save_enabled") ?? true;
      currentLanguage = LanguageManager.getCurrentLanguageCode();
      currentThemeMode = ThemeManager.getThemeMode();
      darkModeEnabled = currentThemeMode == ThemeMode.dark;
    });
  }

  _saveSettings() {
    sharedPref.setBool("notifications_enabled", notificationsEnabled);
    sharedPref.setBool("auto_save_enabled", autoSaveEnabled);
  }

  void _showLanguageDialog() {
    final languages = LanguageManager.getSupportedLanguages();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            AppLocalizations.of(context)!.selectLanguage,
            style: TextStyle(color: AppColor.primaryColor, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: currentLanguage == language['code']
                      ? AppColor.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentLanguage == language['code']
                        ? AppColor.primaryColor
                        : AppColor.borderGray,
                    width: 1.5,
                  ),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    language['nativeName']!,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(language['name']!),
                  value: language['code']!,
                  groupValue: currentLanguage,
                  activeColor: AppColor.primaryColor,
                  onChanged: (String? value) {
                    if (value != null) {
                      Navigator.of(context).pop();
                      _changeLanguage(value);
                    }
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: AppColor.grey)),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog() {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            AppLocalizations.of(context)!.themeMode,
            style: TextStyle(color: AppColor.primaryColor, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(ThemeMode.light, AppLocalizations.of(context)!.light, AppLocalizations.of(context)!.alwaysUseLight, Icons.light_mode),
              _buildThemeOption(ThemeMode.dark, AppLocalizations.of(context)!.dark, AppLocalizations.of(context)!.alwaysUseDark, Icons.dark_mode),
              _buildThemeOption(ThemeMode.system, AppLocalizations.of(context)!.system, AppLocalizations.of(context)!.followSystemTheme, Icons.brightness_auto),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: AppColor.grey)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String title, String subtitle, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: currentThemeMode == mode
            ? AppColor.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: currentThemeMode == mode
              ? AppColor.primaryColor
              : AppColor.borderGray,
          width: 1.5,
        ),
      ),
      child: RadioListTile<ThemeMode>(
        title: Row(
          children: [
            Icon(icon, size: 20, color: AppColor.primaryColor),
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        subtitle: Text(subtitle),
        value: mode,
        groupValue: currentThemeMode,
        activeColor: AppColor.primaryColor,
        onChanged: (ThemeMode? value) {
          if (value != null) {
            Navigator.of(context).pop();
            _changeTheme(value);
          }
        },
      ),
    );
  }

  void _changeLanguage(String languageCode) async {
    setState(() {
      currentLanguage = languageCode;
    });

    MyApp.of(context)?.changeLanguage(languageCode);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.languageChangedSuccessfully),
        backgroundColor: AppColor.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _changeTheme(ThemeMode themeMode) async {
    setState(() {
      currentThemeMode = themeMode;
      darkModeEnabled = themeMode == ThemeMode.dark;
    });

    MyApp.of(context)?.changeTheme(themeMode);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.themeChangedSuccessfully),
        backgroundColor: AppColor.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getLanguageName(String code) {
    final languages = LanguageManager.getSupportedLanguages();
    final language = languages.firstWhere(
          (lang) => lang['code'] == code,
      orElse: () => {'nativeName': 'English'},
    );
    return language['nativeName']!;
  }

  String _getThemeName(ThemeMode mode) {
    final l10n = AppLocalizations.of(context);
    switch (mode) {
      case ThemeMode.light:
        return l10n?.light ?? "Light";
      case ThemeMode.dark:
        return l10n?.dark ?? "Dark";
      case ThemeMode.system:
        return l10n?.system ?? "System";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // App Settings Section
          _buildSectionHeader(AppLocalizations.of(context)!.appSettings, Icons.tune),
          SizedBox(height: 12),

          _buildListTile(
            icon: Icons.language,
            title: AppLocalizations.of(context)!.language,
            subtitle: _getLanguageName(currentLanguage),
            onTap: _showLanguageDialog,
            color: AppColor.primaryColor,
          ),

          _buildListTile(
            icon: Icons.palette_outlined,
            title: AppLocalizations.of(context)!.theme,
            subtitle: _getThemeName(currentThemeMode),
            onTap: _showThemeDialog,
            color: AppColor.goldAccent,
          ),

          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: AppLocalizations.of(context)!.darkMode,
            subtitle: AppLocalizations.of(context)!.quickToggle,
            value: darkModeEnabled,
            onChanged: (value) {
              ThemeMode newMode = value ? ThemeMode.dark : ThemeMode.light;
              _changeTheme(newMode);
            },
            color: AppColor.earthBrown,
          ),
/*
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: AppLocalizations.of(context)!.pushNotifications,
            subtitle: AppLocalizations.of(context)!.receiveNotifications,
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
              _saveSettings();
            },
            color: AppColor.secondColor,
          ),
*/
          // _buildSwitchTile(
          //   icon: Icons.save_outlined,
          //   title: "autoSave",
          //   subtitle: "autoSaveDescription",
          //   value: autoSaveEnabled,
          //   onChanged: (value) {
          //     setState(() {
          //       autoSaveEnabled = value;
          //     });
          //     _saveSettings();
          //   },
          //   color: AppColor.goldAccent,
          // ),

          SizedBox(height: 32),

          // Account Settings Section
          _buildSectionHeader(AppLocalizations.of(context)!.account, Icons.person_outline),
          SizedBox(height: 12),

          _buildListTile(
            icon: Icons.payment_outlined,
            title: AppLocalizations.of(context)!.paymentMethods,
            subtitle: AppLocalizations.of(context)!.managePaymentMethods,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PaymentMethodsPage()),
              );
            },
            color: AppColor.earthBrown,
          ),

          _buildListTile(
            icon: Icons.lock_outline,
            title: AppLocalizations.of(context)!.changePassword,
            subtitle: AppLocalizations.of(context)!.updateAccountPassword,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
            color: AppColor.primaryColor,
          ),

          _buildListTile(
            icon: Icons.delete_outline,
            title: AppLocalizations.of(context)!.deleteAccount,
            subtitle: AppLocalizations.of(context)!.deleteAccountPermanently,
            textColor: AppColor.warningColor,
            onTap: () {
              _showDeleteAccountDialog();
            },
            color: AppColor.warningColor,
          ),

          SizedBox(height: 32),

          // Support Section
          _buildSectionHeader(AppLocalizations.of(context)!.support, Icons.help_outline),
          SizedBox(height: 12),

          _buildListTile(
            icon: Icons.help_outline,
            title: AppLocalizations.of(context)!.helpFaq,
            subtitle: AppLocalizations.of(context)!.getHelpAnswers,
            onTap: () => HelpSupportUtils.openHelpFAQ(context),
            color: AppColor.goldAccent,
          ),

          _buildListTile(
            icon: Icons.bug_report_outlined,
            title: AppLocalizations.of(context)!.reportBug,
            subtitle: AppLocalizations.of(context)!.helpImproveApp,
            onTap: () => HelpSupportUtils.reportBug(context),
            color: AppColor.secondColor,
          ),

          SizedBox(height: 32),

          // Legal Section
          _buildSectionHeader(AppLocalizations.of(context)!.legal, Icons.gavel_outlined),
          SizedBox(height: 12),

          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: AppLocalizations.of(context)!.privacyPolicy,
            subtitle: AppLocalizations.of(context)!.viewPrivacyPolicy,
            onTap: () => LegalPage.openPrivacyPolicy(context),
            color: AppColor.primaryColor,
          ),

          _buildListTile(
            icon: Icons.description_outlined,
            title: AppLocalizations.of(context)!.termsOfService,
            subtitle: AppLocalizations.of(context)!.viewTermsOfService,
            onTap: () => LegalPage.openTermsOfService(context),
            color: AppColor.earthBrown,
          ),

          SizedBox(height: 32),

          // App Information
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.primaryColor, AppColor.secondColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.shopping_bag, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  "Naseej",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "${AppLocalizations.of(context)!.version} 1.0.0",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.handcraftedEgyptianCarpets,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColor.primaryColor, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    Color? textColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Directionality.of(context) == TextDirection.rtl
              ? Icons.arrow_back_ios
              : Icons.arrow_forward_ios,
          size: 16,
          color: AppColor.grey.withOpacity(0.5),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final deleteController = ref.watch(deleteAccountProvider);
          return AlertDialog(
            backgroundColor: AppColor.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColor.warningColor, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.deleteAccountConfirmTitle,
                    style: TextStyle(
                      color: AppColor.warningColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.deleteAccountWarning,
                  style: TextStyle(color: AppColor.grey, fontSize: 14),
                ),
                SizedBox(height: 12),
                _buildWarningItem(AppLocalizations.of(context)!.personalInfoAndProfile),
                _buildWarningItem(AppLocalizations.of(context)!.orderHistory),
                _buildWarningItem(AppLocalizations.of(context)!.savedAddresses),
                _buildWarningItem(AppLocalizations.of(context)!.favoriteProducts),
                SizedBox(height: 12),
                if (deleteController.errorMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      deleteController.errorMessage,
                      style: TextStyle(color: AppColor.warningColor, fontSize: 12),
                    ),
                  ),
              ],
            ),
            actions: [
              if (!deleteController.isLoading)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(color: AppColor.grey, fontSize: 16),
                  ),
                ),
              ElevatedButton(
                onPressed: deleteController.isLoading ? null : () async {
                  final success = await deleteController.deleteAccount();
                  if (success) {
                    Navigator.pop(context);
                    _showSuccessDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.warningColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: deleteController.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.deleteAccount,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.remove, size: 16, color: AppColor.warningColor),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColor.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
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
              Text(AppLocalizations.of(context)!.accountDeleted, style: TextStyle(color: AppColor.successColor)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.accountDeletedSuccess),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.allDataRemoved,
                style: TextStyle(fontSize: 14, color: AppColor.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
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
    // Clear all user data
    sharedPref.remove("user_id");
    sharedPref.remove("user_email");
    sharedPref.remove("user_name");
    sharedPref.remove("user_phone");
    sharedPref.remove("token");
    sharedPref.setString("step", "1"); // Reset to login step

    // Navigate to login screen
    Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
  }
}