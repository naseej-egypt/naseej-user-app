import 'package:flutter/material.dart';
import 'package:naseej/main.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/utils/language_manager.dart';
import 'package:naseej/utils/theme_manager.dart';
import '../core/DeleteAccountController.dart';
import 'change_password_screen.dart';
import 'payment/payment_methods_page.dart';
import 'package:naseej/utils/helpsupport.dart';
import 'package:get/get.dart';

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
            "selectLanguage",
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
              child: Text("cancel", style: TextStyle(color: AppColor.grey)),
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
            "Them Mode",
            style: TextStyle(color: AppColor.primaryColor, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(ThemeMode.light, "Light", "Always Use Light", Icons.light_mode),
              _buildThemeOption(ThemeMode.dark, "Dark", "Always Use Dark", Icons.dark_mode),
              _buildThemeOption(ThemeMode.system, "System", "Follow System Theme", Icons.brightness_auto),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("cancel", style: TextStyle(color: AppColor.grey)),
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
        content: Text("Language Changed Successfully"),
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
        content: Text("Theme Changed Successfully"),
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
    switch (mode) {
      case ThemeMode.light:
        return "Light";
      case ThemeMode.dark:
        return "Dark";
      case ThemeMode.system:
        return "System";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // App Settings Section
          _buildSectionHeader("App Settings", Icons.tune),
          SizedBox(height: 12),

          _buildListTile(
            icon: Icons.language,
            title: "language",
            subtitle: _getLanguageName(currentLanguage),
            onTap: _showLanguageDialog,
            color: AppColor.primaryColor,
          ),

          _buildListTile(
            icon: Icons.palette_outlined,
            title: "Thems",
            subtitle: _getThemeName(currentThemeMode),
            onTap: _showThemeDialog,
            color: AppColor.goldAccent,
          ),

          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            subtitle: "Quick Toggle",
            value: darkModeEnabled,
            onChanged: (value) {
              ThemeMode newMode = value ? ThemeMode.dark : ThemeMode.light;
              _changeTheme(newMode);
            },
            color: AppColor.earthBrown,
          ),

          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: "Push Notifications",
            subtitle: "Receive Notifications",
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
              _saveSettings();
            },
            color: AppColor.secondColor,
          ),

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
          _buildSectionHeader("account", Icons.person_outline),
          SizedBox(height: 12),

          _buildListTile(
            icon: Icons.payment_outlined,
            title: "Payment Methods",
            subtitle: "Manage Your Payment Methods",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PaymentMethodsPage()),
              );
            },
            color: AppColor.earthBrown,
          ),

          _buildListTile(
            icon: Icons.lock_outline,
            title: "Change Password",
            subtitle: "Update Account Password",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
            color: AppColor.primaryColor,
          ),

          _buildListTile(
            icon: Icons.delete_outline,
            title: "Delete Account",
            subtitle: "Delete Account Permanently",
            textColor: AppColor.warningColor,
            onTap: () {
              _showDeleteAccountDialog();
            },
            color: AppColor.warningColor,
          ),

          SizedBox(height: 32),

          // Support Section
          _buildSectionHeader("Support", Icons.help_outline),
          SizedBox(height: 12),

          _buildListTile(
            icon: Icons.help_outline,
            title: "Help FAQ",
            subtitle: "Get Help Answers",
            onTap: () => HelpSupportUtils.openHelpFAQ(context),
            color: AppColor.goldAccent,
          ),

          _buildListTile(
            icon: Icons.bug_report_outlined,
            title: "Report Bug",
            subtitle: "Help Improve App",
            onTap: () => HelpSupportUtils.reportBug(context),
            color: AppColor.secondColor,
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
                  "${"version"} 1.0.0",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Handcrafted Egyptian Carpets',
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
          Icons.arrow_forward_ios,
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
    final DeleteAccountController _deleteController = Get.put(DeleteAccountController());

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => Obx(() => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColor.warningColor, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Delete Account Permanently?",
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
              "This action cannot be undone. All your data will be permanently deleted:",
              style: TextStyle(color: AppColor.grey, fontSize: 14),
            ),
            SizedBox(height: 12),
            _buildWarningItem("Personal information and profile"),
            _buildWarningItem("Order history"),
            _buildWarningItem("Saved addresses"),
            _buildWarningItem("Favorite products"),
            SizedBox(height: 12),
            if (_deleteController.errorMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _deleteController.errorMessage.value,
                  style: TextStyle(color: AppColor.warningColor, fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          if (!_deleteController.isLoading.value)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: AppColor.grey, fontSize: 16),
              ),
            ),
          ElevatedButton(
            onPressed: _deleteController.isLoading.value ? null : () async {
              final success = await _deleteController.deleteAccount();
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
            child: _deleteController.isLoading.value
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              "Delete Account",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      )),
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
              Text("Account Deleted", style: TextStyle(color: AppColor.successColor)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your account has been deleted successfully."),
              SizedBox(height: 8),
              Text(
                "All your data has been permanently removed from our system.",
                style: TextStyle(fontSize: 14, color: AppColor.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _logoutAndNavigate();
              },
              child: Text("OK", style: TextStyle(color: AppColor.primaryColor)),
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