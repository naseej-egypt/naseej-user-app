import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/core/class/crud.dart';
import 'package:naseej/pages/payment/add_payment_method_page.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/main.dart';
import 'package:naseej/pages/payment/edit_payment_method_page.dart';
import 'package:naseej/models/payment_method_model.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  Crud crud = Crud();
  List<PaymentMethodModel> paymentMethods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await crud.postRequest(
        AppLink.getPaymentMethods,
        {},
        headers: {
          'Authorization': 'Bearer ${sharedPref.getString("token")}'
        },
      );

      if (response['status'] == 'success') {
        List<dynamic> data = response['data']['payment_methods'] ?? [];
        setState(() {
          paymentMethods = data.map((item) {
            print('Loading payment method: ${item['card_type']}'); // Debug log
            return PaymentMethodModel.fromJson(item);
          }).toList();
        });
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to load payment methods');
      }
    } catch (e) {
      print('Error loading payment methods: $e'); // Debug log
      _showErrorSnackBar('Network error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deletePaymentMethod(String id, int index) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColor.warningColor),
            SizedBox(width: 12),
            Text('Delete Card', style: TextStyle(color: AppColor.primaryColor)),
          ],
        ),
        content: Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColor.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.warningColor),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        var response = await crud.postRequest(
          AppLink.deletePaymentMethod,
          {
            "payment_method_id": id,
          },
          headers: {
            'Authorization': 'Bearer ${sharedPref.getString("token")}'
          },
        );

        if (response['status'] == 'success') {
          setState(() {
            paymentMethods.removeAt(index);
          });
          _showSuccessSnackBar('Payment method deleted successfully');
        } else {
          _showErrorSnackBar(response['message'] ?? 'Failed to delete payment method');
        }
      } catch (e) {
        _showErrorSnackBar('Network error: $e');
      }
    }
  }

  Future<void> _setDefaultPaymentMethod(int index) async {
    try {
      var response = await crud.postRequest(
        AppLink.setDefaultPaymentMethod,
        {
          "payment_method_id": paymentMethods[index].id,
        },
        headers: {
          'Authorization': 'Bearer ${sharedPref.getString("token")}'
        },
      );

      if (response['status'] == 'success') {
        // Update local state
        setState(() {
          for (var i = 0; i < paymentMethods.length; i++) {
            paymentMethods[i].isDefault = (i == index);
          }
        });
        _showSuccessSnackBar('Default payment method updated');
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to set default payment method');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.successColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.warningColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Payment Methods'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.primaryColor))
          : paymentMethods.isEmpty
          ? _buildEmptyState()
          : _buildPaymentMethodsList(isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPaymentMethodPage()),
          ).then((result) {
            if (result == true) {
              _loadPaymentMethods();
            }
          });
        },
        backgroundColor: AppColor.primaryColor,
        icon: Icon(Icons.add_card),
        label: Text('Add Card'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.credit_card_off_outlined,
                size: 80,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Payment Methods',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Add your payment methods to\nmake checkout faster',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColor.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList(bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: paymentMethods.length,
      itemBuilder: (context, index) {
        return _buildPaymentMethodCard(paymentMethods[index], index, isDark);
      },
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodModel paymentMethod, int index, bool isDark) {
    // Debug log
    print('Displaying card: ${paymentMethod.cardType}');

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: paymentMethod.isDefault
              ? AppColor.primaryColor
              : (isDark ? AppColor.earthBrown.withOpacity(0.2) : AppColor.borderGray),
          width: paymentMethod.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Card Type Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCardColor(paymentMethod.cardType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.credit_card, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        paymentMethod.cardType,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),

                // Default Badge
                if (paymentMethod.isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColor.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.successColor),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        color: AppColor.successColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                Spacer(),

                // Actions Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColor.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPaymentMethodPage(paymentMethod: paymentMethod),
                        ),
                      ).then((result) {
                        if (result == true) {
                          _loadPaymentMethods();
                        }
                      });
                    } else if (value == 'default' && !paymentMethod.isDefault) {
                      _setDefaultPaymentMethod(index);
                    } else if (value == 'delete') {
                      _deletePaymentMethod(paymentMethod.id, index);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: AppColor.primaryColor),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!paymentMethod.isDefault)
                      PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 18, color: AppColor.successColor),
                            SizedBox(width: 12),
                            Text('Set as Default'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: AppColor.warningColor),
                          SizedBox(width: 12),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),
            Divider(height: 1),
            SizedBox(height: 12),

            // Card Nickname (if exists)
            if (paymentMethod.nickname != null && paymentMethod.nickname!.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.label_outline, size: 18, color: AppColor.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      paymentMethod.nickname!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            if (paymentMethod.nickname != null && paymentMethod.nickname!.isNotEmpty)
              SizedBox(height: 8),

            // Card Number
            Row(
              children: [
                Icon(Icons.credit_card_outlined, size: 18, color: AppColor.grey),
                SizedBox(width: 8),
                Text(
                  paymentMethod.cardNumber,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColor.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Cardholder Name & Expiry
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 18, color: AppColor.grey),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          paymentMethod.cardHolderName,
                          style: TextStyle(fontSize: 14, color: AppColor.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 18, color: AppColor.grey),
                    SizedBox(width: 8),
                    Text(
                      'Expires ${paymentMethod.expiryDate}',
                      style: TextStyle(fontSize: 14, color: AppColor.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(String cardType) {
    print('Getting color for card type: $cardType'); // Debug log
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Color(0xFF1A1F71);
      case 'mastercard':
        return Color(0xFFEB001B);
      case 'amex':
        return Color(0xFF2E77BC);
      default:
        print('Unknown card type, using default color'); // Debug log
        return AppColor.primaryColor;
    }
  }
}