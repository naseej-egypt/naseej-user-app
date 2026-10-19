import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/l10n/app_localizations.dart';

/// A page that displays Privacy Policy or Terms of Service via WebView-style
/// content loaded from external URLs.
class LegalPage extends StatelessWidget {
  final String title;
  final String url;

  const LegalPage({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  static const String PRIVACY_URL = 'https://appforyou.store/Naseej/privacy.html';
  static const String TERMS_URL = 'https://appforyou.store/Naseej/terms.html';

  /// Navigate to Privacy Policy page
  static void openPrivacyPolicy(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LegalPage(
          title: l10n.privacyPolicy,
          url: PRIVACY_URL,
        ),
      ),
    );
  }

  /// Navigate to Terms of Service page
  static void openTermsOfService(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LegalPage(
          title: l10n.termsOfService,
          url: TERMS_URL,
        ),
      ),
    );
  }

  /// Launch Privacy Policy URL directly in external browser
  static Future<void> launchPrivacyPolicyUrl() async {
    final Uri uri = Uri.parse(PRIVACY_URL);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Launch Terms of Service URL directly in external browser
  static Future<void> launchTermsOfServiceUrl() async {
    final Uri uri = Uri.parse(TERMS_URL);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchInBrowser() async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: AppLocalizations.of(context)!.openInBrowser,
            onPressed: _launchInBrowser,
          ),
        ],
      ),
      body: _LegalWebContent(url: url),
    );
  }
}

class _LegalWebContent extends StatefulWidget {
  final String url;
  const _LegalWebContent({required this.url});

  @override
  State<_LegalWebContent> createState() => _LegalWebContentState();
}

class _LegalWebContentState extends State<_LegalWebContent> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a brief loading period then show the content via external browser
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _openUrl() async {
    final Uri uri = Uri.parse(widget.url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.couldNotOpenUrl}: $e'),
            backgroundColor: AppColor.warningColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColor.primaryColor,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.url.contains('privacy')
                    ? Icons.privacy_tip_outlined
                    : Icons.gavel_outlined,
                size: 64,
                color: AppColor.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.url.contains('privacy')
                  ? l10n.privacyPolicy
                  : l10n.termsOfService,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColor.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.tapToViewDocument,
              style: TextStyle(
                fontSize: 15,
                color: AppColor.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _openUrl,
              icon: const Icon(Icons.open_in_browser, color: Colors.white),
              label: Text(
                l10n.openInBrowser,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
