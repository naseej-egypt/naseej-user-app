import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/component/button.dart';
import 'package:naseej/core/class/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/main.dart';
import 'package:naseej/models/payment_method_model.dart';
import 'package:naseej/l10n/app_localizations.dart';

class EditPaymentMethodPage extends StatefulWidget {
  final PaymentMethodModel paymentMethod;

  const EditPaymentMethodPage({Key? key, required this.paymentMethod}) : super(key: key);

  @override
  State<EditPaymentMethodPage> createState() => _EditPaymentMethodPageState();
}

class _EditPaymentMethodPageState extends State<EditPaymentMethodPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late String selectedCardType;
  late bool isDefaultPayment;

  // Controllers
  late TextEditingController cardHolderNameController;
  late TextEditingController cardNumberController;
  late TextEditingController expiryMonthController;
  late TextEditingController expiryYearController;
  late TextEditingController nicknameController;

  Crud crud = Crud();

  @override
  void initState() {
    super.initState();
    selectedCardType = widget.paymentMethod.cardType;
    isDefaultPayment = widget.paymentMethod.isDefault;

    // Extract expiry month and year from expiry date (MM/YY format)
    List<String> expiryParts = widget.paymentMethod.expiryDate.split('/');
    String expiryMonth = expiryParts[0];
    String expiryYear = '20${expiryParts[1]}'; // Convert YY to YYYY

    cardHolderNameController = TextEditingController(text: widget.paymentMethod.cardHolderName);
    cardNumberController = TextEditingController(text: widget.paymentMethod.cardNumber);
    expiryMonthController = TextEditingController(text: expiryMonth);
    expiryYearController = TextEditingController(text: expiryYear);
    nicknameController = TextEditingController(text: widget.paymentMethod.nickname ?? '');

    print('Initial card type: $selectedCardType'); // Debug log
  }

  @override
  void dispose() {
    cardHolderNameController.dispose();
    cardNumberController.dispose();
    expiryMonthController.dispose();
    expiryYearController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  Future<void> _updatePaymentMethod() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        print('Updating with card type: $selectedCardType'); // Debug log

        var response = await crud.postRequest(
          AppLink.updatePaymentMethod,
          {
            "payment_method_id": widget.paymentMethod.id,
            "card_type": selectedCardType, // Now sending card type
            "card_holder_name": cardHolderNameController.text.trim(),
            "expiry_month": expiryMonthController.text.trim(),
            "expiry_year": expiryYearController.text.trim(),
            "nickname": nicknameController.text.trim().isEmpty ? null : nicknameController.text.trim(),
            "is_default": isDefaultPayment ? '1' : '0',
          },
          headers: {
            'Authorization': 'Bearer ${sharedPref.getString("token")}'
          },
        );

        print('Response: $response'); // Debug log

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment method updated successfully!'),
              backgroundColor: AppColor.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to update payment method'),
              backgroundColor: AppColor.warningColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        print('Error: $e'); // Debug log
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            backgroundColor: AppColor.warningColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildCardTypeChip(String type) {
    final bool isSelected = selectedCardType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCardType = type;
          });
          print('Card type changed to: $selectedCardType'); // Debug log
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [AppColor.primaryColor, AppColor.secondColor],
            )
                : null,
            color: isSelected ? null : (isDark ? Color(0xFF2C2520) : AppColor.backgroundcolor2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColor.borderGray,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 24,
                decoration: BoxDecoration(
                  color: _getCardColor(type),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    type == 'Visa' ? 'VISA' : type == 'Mastercard' ? 'MC' : 'AMEX',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColor.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCardColor(String type) {
    switch (type) {
      case 'Visa':
        return Color(0xFF1A1F71);
      case 'Mastercard':
        return Color(0xFFEB001B);
      case 'Amex':
        return Color(0xFF2E77BC);
      default:
        return AppColor.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editPaymentMethod),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // Card Type Selection
            Text(
              'Card Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildCardTypeChip('Visa'),
                SizedBox(width: 12),
                _buildCardTypeChip('Mastercard'),
                SizedBox(width: 12),
                _buildCardTypeChip('Amex'),
              ],
            ),
            SizedBox(height: 24),

            // Card Nickname (Optional)
            _buildTextField(
              controller: nicknameController,
              label: 'Card Nickname (Optional)',
              hint: 'e.g., Personal Visa, Business Card',
              icon: Icons.credit_card_outlined,
              validator: null, // Optional field
            ),
            SizedBox(height: 16),

            // Cardholder Name
            _buildTextField(
              controller: cardHolderNameController,
              label: AppLocalizations.of(context)!.cardholderName,
              hint: 'Enter name as shown on card',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter cardholder name';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Card Number (Read-only for security)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.cardNumber,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF2C2520) : AppColor.backgroundcolor2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.credit_card, size: 20, color: AppColor.primaryColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cardNumberController.text,
                          style: TextStyle(fontSize: 14, color: AppColor.grey),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColor.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Read-only',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColor.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'For security reasons, card number cannot be edited',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColor.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Expiry Date
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: expiryMonthController,
                    label: AppLocalizations.of(context)!.expiryMonth,
                    hint: 'MM',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (value.length != 2) {
                        return '2 digits';
                      }
                      int month = int.tryParse(value) ?? 0;
                      if (month < 1 || month > 12) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: expiryYearController,
                    label: AppLocalizations.of(context)!.expiryYear,
                    hint: 'YYYY',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (value.length != 4) {
                        return '4 digits';
                      }
                      int year = int.tryParse(value) ?? 0;
                      int currentYear = DateTime.now().year;
                      if (year < currentYear || year > currentYear + 20) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // CVV (Read-only for security)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.cvv,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF2C2520) : AppColor.backgroundcolor2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, size: 20, color: AppColor.primaryColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '•••',
                          style: TextStyle(fontSize: 14, color: AppColor.grey),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColor.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Hidden',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColor.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'CVV cannot be viewed or edited for security',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColor.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Set as Default Payment Method
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF2C2520) : AppColor.backgroundcolor2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_outline,
                    color: AppColor.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Set as default payment method',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.primaryColor,
                      ),
                    ),
                  ),
                  Switch(
                    value: isDefaultPayment,
                    onChanged: (value) {
                      setState(() {
                        isDefaultPayment = value;
                      });
                    },
                    activeColor: AppColor.primaryColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Update Button
            Button(
              title: AppLocalizations.of(context)!.savePaymentMethod,
              isLoading: isLoading,
              onpressed: _updatePaymentMethod,
              icon: Icons.save,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColor.grey, fontSize: 13),
            prefixIcon: Icon(icon, size: 20, color: AppColor.primaryColor),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: isDark ? Color(0xFF2C2520) : AppColor.backgroundcolor2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.warningColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.warningColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}