import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/main.dart';
import 'package:naseej/l10n/app_localizations.dart';
import 'package:naseej/pages/legal_page.dart';

/// A consent page shown on first app launch (after onboarding).
/// The user must accept Privacy Policy & Terms of Service to proceed.
class TermsConsentPage extends StatefulWidget {
  const TermsConsentPage({Key? key}) : super(key: key);

  @override
  State<TermsConsentPage> createState() => _TermsConsentPageState();
}

class _TermsConsentPageState extends State<TermsConsentPage>
    with SingleTickerProviderStateMixin {
  bool _privacyAccepted = false;
  bool _termsAccepted = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _canProceed => _privacyAccepted && _termsAccepted;

  void _onAcceptAndContinue() async {
    if (!_canProceed) return;

    // Mark consent as accepted
    await sharedPref.setBool('terms_accepted', true);
    await sharedPref.setString('terms_accepted_date', DateTime.now().toIso8601String());

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1614) : AppColor.backgroundcolor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Header icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.primaryColor.withOpacity(0.15),
                          AppColor.goldAccent.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 56,
                      color: AppColor.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    l10n.termsAndPrivacy,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColor.primaryColor,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    l10n.pleaseReviewAndAccept,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColor.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  // Consent cards
                  Expanded(
                    child: ListView(
                      children: [
                        // Privacy Policy card
                        _buildConsentCard(
                          context: context,
                          icon: Icons.privacy_tip_outlined,
                          title: l10n.privacyPolicy,
                          description: l10n.privacyPolicyDescription,
                          isAccepted: _privacyAccepted,
                          onChanged: (value) {
                            setState(() => _privacyAccepted = value ?? false);
                          },
                          onReadMore: () => LegalPage.launchPrivacyPolicyUrl(),
                          isDark: isDark,
                          color: AppColor.primaryColor,
                        ),

                        const SizedBox(height: 16),

                        // Terms of Service card
                        _buildConsentCard(
                          context: context,
                          icon: Icons.gavel_outlined,
                          title: l10n.termsOfService,
                          description: l10n.termsOfServiceDescription,
                          isAccepted: _termsAccepted,
                          onChanged: (value) {
                            setState(() => _termsAccepted = value ?? false);
                          },
                          onReadMore: () => LegalPage.launchTermsOfServiceUrl(),
                          isDark: isDark,
                          color: AppColor.goldAccent,
                        ),

                        const SizedBox(height: 24),

                        // Info text
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : AppColor.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColor.primaryColor.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: AppColor.primaryColor.withOpacity(0.7),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.consentInfoText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white70 : AppColor.grey,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Accept & Continue button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _canProceed ? _onAcceptAndContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canProceed
                            ? AppColor.primaryColor
                            : AppColor.grey.withOpacity(0.3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: _canProceed ? 6 : 0,
                        shadowColor: AppColor.primaryColor.withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: _canProceed
                                ? Colors.white
                                : AppColor.grey.withOpacity(0.5),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.acceptAndContinue,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _canProceed
                                  ? Colors.white
                                  : AppColor.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsentCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required bool isAccepted,
    required ValueChanged<bool?> onChanged,
    required VoidCallback onReadMore,
    required bool isDark,
    required Color color,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? (isAccepted ? color.withOpacity(0.15) : const Color(0xFF2C2520))
            : (isAccepted ? color.withOpacity(0.08) : AppColor.cardBackground),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAccepted ? color : AppColor.borderGray,
          width: isAccepted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isAccepted
                ? color.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColor.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Read full document link
          InkWell(
            onTap: onReadMore,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    l10n.readFullDocument,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                      decoration: TextDecoration.underline,
                      decorationColor: color,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 4),

          // Checkbox row
          CheckboxListTile(
            value: isAccepted,
            onChanged: onChanged,
            activeColor: color,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              '${l10n.iHaveReadAndAccept} $title',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isAccepted ? FontWeight.w600 : FontWeight.normal,
                color: isDark ? Colors.white : AppColor.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
