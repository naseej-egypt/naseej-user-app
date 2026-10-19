import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.aboutOurFamilyBusiness),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 20),

            // Business Logo/Title
            Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.primaryColor, AppColor.secondColor],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.workspace_premium, size: 60, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.naseejHandmadeCarpets,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.egyptianHeritageSince1990,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Meet Our Team Section
            Text(
              AppLocalizations.of(context)!.meetOurTeam,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.threeGenerationsExpertise,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppColor.grey),
            ),
            SizedBox(height: 32),

            // Team Members - NON-SCROLLABLE, AUTO-HEIGHT
            _buildTeamMemberCard(
              context: context,
              imagePath: "assets/images/father2.png",
              name: "Ashraf Gaber",
              role: AppLocalizations.of(context)!.ownerAndManager,
              experience: AppLocalizations.of(context)!.thirtyPlusYearsExperience,
              description: AppLocalizations.of(context)!.ashrafDescription,
              isDark: isDark,
              contacts: [
                _TeamContact(
                  type: ContactType.whatsapp,
                  url: 'https://wa.me/201016508371',
                  tooltip: AppLocalizations.of(context)!.contactViaWhatsApp,
                ),
                _TeamContact(
                  type: ContactType.phone,
                  url: 'tel:+201016508371',
                  tooltip: AppLocalizations.of(context)!.callDirectly,
                ),
              ],
            ),
            SizedBox(height: 24),

            _buildTeamMemberCard(
              context: context,
              imagePath: "assets/images/amr.jpg",
              name: "Amr Gaber",
              role: AppLocalizations.of(context)!.coFounderSeniorDesigner,
              experience: AppLocalizations.of(context)!.graphicUiUxDesigner,
              description: AppLocalizations.of(context)!.amrDescription,
              isDark: isDark,
              contacts: [
                _TeamContact(
                  type: ContactType.whatsapp,
                  url: 'https://wa.me/+966540075427',
                  tooltip: AppLocalizations.of(context)!.contactViaWhatsApp,
                ),
                _TeamContact(
                  type: ContactType.portfolio,
                  url: 'https://www.linkedin.com/in/amr-gaber-921b4592/',
                  tooltip: AppLocalizations.of(context)!.viewPortfolio,
                ),
              ],
            ),
            SizedBox(height: 24),

            _buildTeamMemberCard(
              context: context,
              imagePath: "assets/images/profile.jpg",
              name: "Eng. Yasser Ashraf",
              role: AppLocalizations.of(context)!.mobileAppDeveloper,
              experience: AppLocalizations.of(context)!.flutterDartExpert,
              description: AppLocalizations.of(context)!.yasserDescription,
              isDark: isDark,
              contacts: [
                _TeamContact(
                  type: ContactType.whatsapp,
                  url: 'https://wa.me/201003640081',
                  tooltip: AppLocalizations.of(context)!.contactViaWhatsApp,
                ),
                _TeamContact(
                  type: ContactType.website,
                  url:
                      'https://yasser-ashraf-production-ready-mobile-apps.vercel.app/',
                  tooltip: AppLocalizations.of(context)!.viewPortfolio,
                ),
              ],
            ),

            SizedBox(height: 40),

            // Family Pride Section
            Container(
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF2C2520) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.family_restroom,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.familyPrideAndLegacy,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildCraftItem(
                    AppLocalizations.of(context)!.threeGenerationsCraftsmanship,
                    Icons.history_edu,
                  ),
                  _buildCraftItem(AppLocalizations.of(context)!.traditionalEgyptianWeaving, Icons.flag),
                  _buildCraftItem(AppLocalizations.of(context)!.naturalMaterials, Icons.eco),
                  _buildCraftItem(
                    AppLocalizations.of(context)!.customDesignsAndSizes,
                    Icons.design_services,
                  ),
                  _buildCraftItem(AppLocalizations.of(context)!.qualityGuaranteed, Icons.verified_user),
                  _buildCraftItem(
                    AppLocalizations.of(context)!.traditionWithTechnology,
                    Icons.phone_iphone,
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Legacy Section
            Container(
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.earthBrown, AppColor.goldAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Icon(Icons.auto_awesome, size: 50, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.aFamilyLegacy,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.familyLegacyDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.theGaberFamily,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard({
    required BuildContext context,
    required String imagePath,
    required String name,
    required String role,
    required String experience,
    required String description,
    required bool isDark,
    required List<_TeamContact> contacts,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.15),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark
              ? AppColor.earthBrown.withOpacity(0.3)
              : AppColor.borderGray,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Profile Image
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor.withOpacity(0.2),
                      AppColor.goldAccent.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.goldAccent, width: 3),
                ),
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColor.backgroundcolor2,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppColor.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),

          // Role
          Text(
            role,
            style: TextStyle(
              fontSize: 14,
              color: AppColor.goldAccent,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          SizedBox(height: 12),

          // Experience Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColor.successColor.withOpacity(0.3)),
            ),
            child: Text(
              experience,
              style: TextStyle(
                fontSize: 12,
                color: AppColor.successColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColor.grey, height: 1.4),
          ),
          SizedBox(height: 20),

          // Contact Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: contacts.map((contact) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: _buildSmallContactButton(contact),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallContactButton(_TeamContact contact) {
    final iconData = _getContactIcon(contact.type);
    final color = _getContactColor(contact.type);

    return Tooltip(
      message: contact.tooltip,
      child: InkWell(
        onTap: () => _launchURL(contact.url),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Icon(iconData, size: 22, color: color),
        ),
      ),
    );
  }

  Widget _buildCraftItem(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColor.primaryColor),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, height: 1.4, color: AppColor.grey),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getContactIcon(ContactType type) {
    switch (type) {
      case ContactType.whatsapp:
        return FontAwesomeIcons.whatsapp;
      case ContactType.phone:
        return Icons.phone;
      case ContactType.email:
        return Icons.email;
      case ContactType.linkedin:
        return FontAwesomeIcons.linkedin;
      case ContactType.portfolio:
        return Icons.palette;
      case ContactType.website:
        return Icons.public;
    }
  }

  Color _getContactColor(ContactType type) {
    switch (type) {
      case ContactType.whatsapp:
        return Color(0xFF25D366);
      case ContactType.phone:
        return AppColor.primaryColor;
      case ContactType.email:
        return Color(0xFFEA4335);
      case ContactType.linkedin:
        return Color(0xFF0077B5);
      case ContactType.portfolio:
        return AppColor.goldAccent;
      case ContactType.website:
        return AppColor.secondColor;
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }
}

// Enums and Data Classes
enum ContactType { whatsapp, phone, email, linkedin, portfolio, website }

class _TeamContact {
  final ContactType type;
  final String url;
  final String tooltip;

  _TeamContact({required this.type, required this.url, required this.tooltip});
}




// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:naseej/core/constant/color.dart';
// import '../l10n/generated/app_localizations.dart';
//
// class AboutPage extends StatelessWidget {
//   const AboutPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
//       appBar: AppBar(
//         title: Text('About Our Family Business'),
//         backgroundColor: AppColor.primaryColor,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(24),
//         child: Column(
//           children: [
//             SizedBox(height: 20),
//
//             // Business Logo/Title
//             Container(
//               padding: EdgeInsets.all(25),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [AppColor.primaryColor, AppColor.secondColor],
//                 ),
//                 borderRadius: BorderRadius.circular(25),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColor.primaryColor.withOpacity(0.4),
//                     blurRadius: 20,
//                     offset: Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.workspace_premium,
//                     size: 60,
//                     color: Colors.white,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'Naseej Handmade Carpets',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Egyptian Heritage Since 1990',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.white.withOpacity(0.9),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             SizedBox(height: 40),
//
//             // Meet Our Team Section
//             Text(
//               'Meet Our Team',
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: AppColor.primaryColor,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               'Three generations of expertise in Egyptian handmade carpets',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: AppColor.grey,
//               ),
//             ),
//             SizedBox(height: 32),
//
//             // Horizontal Scrollable Team Members - FIXED HEIGHT
//             Container(
//               height: 520, // Fixed height for horizontal scroll
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(horizontal: 8),
//                 children: [
//                   _buildTeamMemberCard(
//                     context: context,
//                     imagePath: "assets/images/father2.png",
//                     name: "Ashraf Gaber",
//                     role: "Owner & Manager",
//                     experience: "30+ Years Experience",
//                     description: "Master craftsman with over three decades of experience in authentic Egyptian handmade carpets. Known for exceptional craftsmanship and business excellence.",
//                     isDark: isDark,
//                     contacts: [
//                       _TeamContact(
//                         type: ContactType.whatsapp,
//                         url: 'https://wa.me/201016508371',
//                         tooltip: 'Contact via WhatsApp',
//                       ),
//                       _TeamContact(
//                         type: ContactType.phone,
//                         url: 'tel:+201016508371',
//                         tooltip: 'Call directly',
//                       ),
//                     ],
//                   ),
//                   SizedBox(width: 16),
//                   _buildTeamMemberCard(
//                     context: context,
//                     imagePath: "assets/images/amr.jpg",
//                     name: "Amr Gaber",
//                     role: "Co-Founder & Senior Designer",
//                     experience: "Graphic & UI/UX Designer",
//                     description: "Creative director and senior designer specializing in visual identity, brand design, and user experience design for modern businesses.",
//                     isDark: isDark,
//                     contacts: [
//                       _TeamContact(
//                         type: ContactType.linkedin,
//                         url: 'https://linkedin.com/in/amrgaber',
//                         tooltip: 'View LinkedIn profile',
//                       ),
//                       _TeamContact(
//                         type: ContactType.portfolio,
//                         url: 'https://amrgaber-portfolio.com',
//                         tooltip: 'View portfolio',
//                       ),
//                     ],
//                   ),
//                   SizedBox(width: 16),
//                   _buildTeamMemberCard(
//                     context: context,
//                     imagePath: "assets/images/profile.jpg",
//                     name: "Eng. Yasser Ashraf",
//                     role: "Mobile App Developer",
//                     experience: "Flutter & Dart Expert",
//                     description: "Specialized in building production-ready mobile applications with modern technology stacks. Bringing traditional craftsmanship to digital platforms.",
//                     isDark: isDark,
//                     contacts: [
//                       _TeamContact(
//                         type: ContactType.whatsapp,
//                         url: 'https://wa.me/201003640081',
//                         tooltip: 'Contact via WhatsApp',
//                       ),
//                       _TeamContact(
//                         type: ContactType.website,
//                         url: 'https://yasser-ashraf-production-ready-mobile-apps.vercel.app/',
//                         tooltip: 'View Portfolio',
//                       ),
//                     ],
//                   ),
//                   SizedBox(width: 8),
//                 ],
//               ),
//             ),
//
//             SizedBox(height: 40),
//
//             // Family Pride Section
//             Container(
//               padding: EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: isDark ? Color(0xFF2C2520) : Colors.white,
//                 borderRadius: BorderRadius.circular(25),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColor.primaryColor.withOpacity(0.1),
//                     blurRadius: 15,
//                     offset: Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: AppColor.primaryColor,
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: Icon(
//                           Icons.family_restroom,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                       ),
//                       SizedBox(width: 14),
//                       Expanded(
//                         child: Text(
//                           'Family Pride & Legacy',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: AppColor.primaryColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   _buildCraftItem('Three Generations', Icons.history_edu),
//                   _buildCraftItem('Egyptian Weaving', Icons.flag),
//                   _buildCraftItem('Natural Materials', Icons.eco),
//                   _buildCraftItem('Custom Designs', Icons.design_services),
//                   _buildCraftItem('Quality Guaranteed', Icons.verified_user),
//                   _buildCraftItem('Tradition & Tech', Icons.phone_iphone),
//                 ],
//               ),
//             ),
//
//             SizedBox(height: 40),
//
//             // Legacy Section
//             Container(
//               padding: EdgeInsets.all(28),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [AppColor.earthBrown, AppColor.goldAccent],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(25),
//               ),
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.auto_awesome,
//                     size: 50,
//                     color: Colors.white,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'A Family Legacy',
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 12),
//                   Text(
//                     'Proudly continuing our family tradition of excellence in Egyptian handmade carpets, now enhanced with modern technology to serve customers worldwide. Our commitment to quality and authenticity remains unchanged through generations.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.white.withOpacity(0.9),
//                       height: 1.5,
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: Text(
//                       'The Gaber Family',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             SizedBox(height: 50),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTeamMemberCard({
//     required BuildContext context,
//     required String imagePath,
//     required String name,
//     required String role,
//     required String experience,
//     required String description,
//     required bool isDark,
//     required List<_TeamContact> contacts,
//   }) {
//     return Container(
//       width: 300, // Fixed width for horizontal scroll
//       margin: EdgeInsets.symmetric(horizontal: 8),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: isDark ? Color(0xFF2C2520) : Colors.white,
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: AppColor.primaryColor.withOpacity(0.15),
//             blurRadius: 15,
//             offset: Offset(0, 6),
//           ),
//         ],
//         border: Border.all(
//           color: isDark ? AppColor.earthBrown.withOpacity(0.3) : AppColor.borderGray,
//           width: 1.5,
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           // Profile Image
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               Container(
//                 width: 110,
//                 height: 110,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [
//                       AppColor.primaryColor.withOpacity(0.2),
//                       AppColor.goldAccent.withOpacity(0.2),
//                     ],
//                   ),
//                 ),
//               ),
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: AppColor.goldAccent,
//                     width: 3,
//                   ),
//                 ),
//                 child: ClipOval(
//                   child: Image.asset(
//                     imagePath,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         color: AppColor.backgroundcolor2,
//                         child: Icon(
//                           Icons.person,
//                           size: 40,
//                           color: AppColor.primaryColor,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//
//           // Name
//           Text(
//             name,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: AppColor.primaryColor,
//             ),
//             textAlign: TextAlign.center,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           SizedBox(height: 6),
//
//           // Role
//           Text(
//             role,
//             style: TextStyle(
//               fontSize: 13,
//               color: AppColor.goldAccent,
//               fontWeight: FontWeight.w600,
//             ),
//             textAlign: TextAlign.center,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           SizedBox(height: 12),
//
//           // Experience Badge
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: AppColor.successColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: AppColor.successColor.withOpacity(0.3)),
//             ),
//             child: Text(
//               experience,
//               style: TextStyle(
//                 fontSize: 11,
//                 color: AppColor.successColor,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           SizedBox(height: 16),
//
//           // Description
//           Expanded(
//             child: SingleChildScrollView(
//               child: Text(
//                 description,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: AppColor.grey,
//                   height: 1.4,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//
//           // Contact Buttons
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: contacts.map((contact) {
//               return Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 6),
//                 child: _buildSmallContactButton(contact),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSmallContactButton(_TeamContact contact) {
//     final iconData = _getContactIcon(contact.type);
//     final color = _getContactColor(contact.type);
//
//     return Tooltip(
//       message: contact.tooltip,
//       child: InkWell(
//         onTap: () => _launchURL(contact.url),
//         borderRadius: BorderRadius.circular(20),
//         child: Container(
//           width: 45,
//           height: 45,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: color.withOpacity(0.3), width: 2),
//           ),
//           child: Icon(
//             iconData,
//             size: 20,
//             color: color,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCraftItem(String text, IconData icon) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColor.primaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 18, color: AppColor.primaryColor),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 13,
//                 height: 1.3,
//                 color: AppColor.grey,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   IconData _getContactIcon(ContactType type) {
//     switch (type) {
//       case ContactType.whatsapp:
//         return FontAwesomeIcons.whatsapp;
//       case ContactType.phone:
//         return Icons.phone;
//       case ContactType.email:
//         return Icons.email;
//       case ContactType.linkedin:
//         return FontAwesomeIcons.linkedin;
//       case ContactType.portfolio:
//         return Icons.palette;
//       case ContactType.website:
//         return Icons.public;
//     }
//   }
//
//   Color _getContactColor(ContactType type) {
//     switch (type) {
//       case ContactType.whatsapp:
//         return Color(0xFF25D366);
//       case ContactType.phone:
//         return AppColor.primaryColor;
//       case ContactType.email:
//         return Color(0xFFEA4335);
//       case ContactType.linkedin:
//         return Color(0xFF0077B5);
//       case ContactType.portfolio:
//         return AppColor.goldAccent;
//       case ContactType.website:
//         return AppColor.secondColor;
//     }
//   }
//
//   Future<void> _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       throw Exception("Could not launch $url");
//     }
//   }
// }
//
// // Enums and Data Classes
// enum ContactType {
//   whatsapp,
//   phone,
//   email,
//   linkedin,
//   portfolio,
//   website,
// }
//
// class _TeamContact {
//   final ContactType type;
//   final String url;
//   final String tooltip;
//
//   _TeamContact({
//     required this.type,
//     required this.url,
//     required this.tooltip,
//   });
// }