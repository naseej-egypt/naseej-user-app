import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/models/cart_item.dart';
import 'package:naseej/core/services/orders_service.dart';
import 'package:naseej/core/services/address_service.dart';
import 'package:naseej/core/services/payment_service.dart';
import 'package:naseej/core/services/store_service.dart';
import 'package:naseej/pages/address/add_address_page.dart';
import 'package:naseej/pages/payment/add_payment_method_page.dart';
import 'package:naseej/models/address_model.dart' as models;
import 'package:naseej/models/payment_method_model.dart' as models;
import 'package:naseej/models/store_model.dart';
import 'package:naseej/l10n/app_localizations.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final CartSummary cartSummary;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.cartSummary,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final OrdersService _ordersService = OrdersService();
  final AddressService _addressService = AddressService();
  final PaymentService _paymentService = PaymentService();
  final StoreService _storeService = StoreService();

  models.AddressModel? _selectedAddress;
  models.PaymentMethodModel? _selectedPaymentMethod;
  DeliveryMethod _selectedDeliveryMethod = DeliveryMethod.delivery;
  PaymentType _selectedPaymentType = PaymentType.cashOnDelivery;
  Store? _selectedStore;

  List<models.PaymentMethodModel> _paymentMethods = [];
  List<models.AddressModel> _addresses = [];
  List<Store> _stores = [];

  bool _isLoading = true;
  bool _isPlacingOrder = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load addresses, payment methods, and stores in parallel
      final results = await Future.wait([
        _loadAddresses(),
        _loadPaymentMethods(),
        _loadStores(),
      ]);

      // Check if any operation failed
      final hasError = results.any((result) => result['success'] == false);

      if (hasError && mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.failedToLoadCheckoutData;
          _isLoading = false;
        });
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '${AppLocalizations.of(context)!.errorLoadingCheckoutData}: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _loadAddresses() async {
    try {
      final result = await _addressService.getAddresses();

      if (result['success'] == true) {
        final addresses = result['data'] ?? [];
        setState(() {
          _addresses = List<models.AddressModel>.from(addresses);
          // Set default address if available
          if (_addresses.isNotEmpty) {
            _selectedAddress = _addresses.firstWhere(
                  (address) => address.isDefault,
              orElse: () => _addresses.first,
            );
          }
        });
        return {'success': true};
      } else {
        return {'success': false, 'message': result['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _loadPaymentMethods() async {
    try {
      final result = await _paymentService.getPaymentMethods();

      if (result['success'] == true) {
        final paymentMethods = result['data'] ?? [];
        setState(() {
          _paymentMethods = List<models.PaymentMethodModel>.from(paymentMethods);
          // Set default payment method if available
          if (_paymentMethods.isNotEmpty) {
            _selectedPaymentMethod = _paymentMethods.firstWhere(
                  (method) => method.isDefault,
              orElse: () => _paymentMethods.first,
            );
          }
        });
        return {'success': true};
      } else {
        return {'success': false, 'message': result['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _loadStores() async {
    try {
      final result = await _storeService.getStores();

      if (result['success'] == true) {
        final stores = result['data'] ?? [];
        setState(() {
          _stores = List<Store>.from(stores);
          // Set first store as default for pickup
          if (_stores.isNotEmpty) {
            _selectedStore = _stores.first;
          }
        });
        return {'success': true};
      } else {
        return {'success': false, 'message': result['error']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> _placeOrder() async {
    // Validation
    if (_selectedDeliveryMethod == DeliveryMethod.delivery && _selectedAddress == null) {
      if (mounted) {
        _showErrorSnackBar(
            AppLocalizations.of(context)!.pleaseSelectDeliveryAddress);
      }
      return;
    }

    if (_selectedDeliveryMethod == DeliveryMethod.pickup && _selectedStore == null) {
      _showErrorSnackBar(AppLocalizations.of(context)!.pleaseSelectStoreForPickup);
      return;
    }

    if (_selectedPaymentType == PaymentType.online && _selectedPaymentMethod == null) {
      _showErrorSnackBar(AppLocalizations.of(context)!.pleaseSelectPaymentMethod);
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      var result = await _ordersService.createOrder(
        deliveryMethod: _selectedDeliveryMethod == DeliveryMethod.delivery ? 'delivery' : 'pickup',
        paymentType: _selectedPaymentType == PaymentType.cashOnDelivery ? 'cash' : 'online',
        addressId: _selectedAddress?.id,
        storeId: _selectedStore?.id,
        paymentMethodId: _selectedPaymentMethod?.id,
        notes: null,
      );

      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.orderPlacedSuccessfully),
            backgroundColor: AppColor.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to orders page
        Navigator.of(context).pushNamedAndRemoveUntil('/orders', (route) => false);
      } else if (mounted) {
        _showErrorSnackBar(result['message'] ?? AppLocalizations.of(context)!.failedToPlaceOrder);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('${AppLocalizations.of(context)!.errorPlacingOrder}: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.warningColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddressSelectionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.selectDeliveryAddress,
          style: TextStyle(
            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Address List
              if (_addresses.isNotEmpty)
                Container(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      final isSelected = _selectedAddress?.id == address.id;

                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColor.primaryColor : AppColor.borderGray,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getLabelColor(address.label),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(_getLabelIcon(address.label), color: Colors.white, size: 20),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  address.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8),
                              if (address.isDefault)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColor.successColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColor.successColor),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.defaultLabel,
                                    style: TextStyle(
                                      color: AppColor.successColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 2),
                              Text(
                                address.streetAddress,
                                style: TextStyle(fontSize: 12, color: AppColor.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${address.city}, ${address.state} ${address.zipCode}',
                                style: TextStyle(fontSize: 12, color: AppColor.grey),
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: AppColor.primaryColor)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedAddress = address;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_location_alt, size: 48, color: AppColor.primaryColor),
                      ),
                      SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noAddressesYet,
                        style: TextStyle(
                          color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.addDeliveryAddressToContinue,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.grey,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _navigateToAddAddress();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.add_location_alt, size: 20),
                          label: Text(AppLocalizations.of(context)!.addNewAddress, style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_addresses.isNotEmpty) ...[
                SizedBox(height: 16),
                // Add New Address Button (when addresses exist)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToAddAddress();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primaryColor,
                    side: BorderSide(color: AppColor.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.add, size: 18),
                  label: Text(AppLocalizations.of(context)!.addNewAddress),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: AppColor.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _showStoreSelectionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.selectStoreForPickup,
          style: TextStyle(
            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: _stores.isNotEmpty
              ? ListView.builder(
            shrinkWrap: true,
            itemCount: _stores.length,
            itemBuilder: (context, index) {
              final store = _stores[index];
              final isSelected = _selectedStore?.id == store.id;

              return Container(
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColor.primaryColor : AppColor.borderGray,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.store, color: AppColor.primaryColor),
                  ),
                  title: Text(
                    store.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.address,
                        style: TextStyle(fontSize: 12, color: AppColor.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: AppColor.grey),
                          SizedBox(width: 4),
                          Text(
                            '${store.distance.toStringAsFixed(1)} km',
                            style: TextStyle(fontSize: 11, color: AppColor.grey),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.star, size: 12, color: AppColor.goldAccent),
                          SizedBox(width: 2),
                          Text(
                            store.rating.toStringAsFixed(1),
                            style: TextStyle(fontSize: 11, color: AppColor.goldAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: AppColor.primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedStore = store;
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            },
          )
              : Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.store_mall_directory, size: 48, color: AppColor.grey),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.noStoresAvailable,
                  style: TextStyle(
                    color: AppColor.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.pleaseTryAgainLater,
                  style: TextStyle(
                    color: AppColor.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: AppColor.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodSelectionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.selectPaymentMethod,
          style: TextStyle(
            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Payment Methods List
              if (_paymentMethods.isNotEmpty)
                Container(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _paymentMethods.length,
                    itemBuilder: (context, index) {
                      final paymentMethod = _paymentMethods[index];
                      final isSelected = _selectedPaymentMethod?.id == paymentMethod.id;

                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColor.primaryColor : AppColor.borderGray,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getCardColor(paymentMethod.cardType),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                paymentMethod.cardType == 'Visa' ? 'VISA' :
                                paymentMethod.cardType == 'Mastercard' ? 'MC' : 'AMEX',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      paymentMethod.nickname ?? paymentMethod.cardType,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  if (paymentMethod.isDefault)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColor.successColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColor.successColor),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.defaultLabel,
                                        style: TextStyle(
                                          color: AppColor.successColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                paymentMethod.cardNumber,
                                style: TextStyle(fontSize: 12, color: AppColor.grey),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${AppLocalizations.of(context)!.expires} ${paymentMethod.expiryDate}',
                                style: TextStyle(fontSize: 11, color: AppColor.grey),
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: AppColor.primaryColor)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethod = paymentMethod;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_card, size: 48, color: AppColor.primaryColor),
                      ),
                      SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noPaymentMethodsYet,
                        style: TextStyle(
                          color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.addPaymentCardToUseOnlinePayment,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.grey,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _navigateToAddPaymentMethod();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.add_card, size: 20),
                          label: Text(AppLocalizations.of(context)!.addNewCard, style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_paymentMethods.isNotEmpty) ...[
                SizedBox(height: 16),
                // Add New Payment Method Button (when methods exist)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToAddPaymentMethod();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primaryColor,
                    side: BorderSide(color: AppColor.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.add_card, size: 18),
                  label: Text(AppLocalizations.of(context)!.addNewCard),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: AppColor.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAddressPage()),
    );
    if (result == true) {
      // Reload addresses — newly added address will be auto-selected
      await _loadAddresses();
      // If this was the first address, auto-select it
      if (_addresses.isNotEmpty && _selectedAddress == null) {
        setState(() {
          _selectedAddress = _addresses.first;
        });
      }
    }
  }

  Future<void> _navigateToAddPaymentMethod() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPaymentMethodPage()),
    );
    if (result == true) {
      // Reload payment methods — newly added method will be auto-selected
      await _loadPaymentMethods();
      // If this was the first payment method, auto-select it
      if (_paymentMethods.isNotEmpty && _selectedPaymentMethod == null) {
        setState(() {
          _selectedPaymentMethod = _paymentMethods.first;
        });
      }
    }
  }

  Color _getLabelColor(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return AppColor.primaryColor;
      case 'work':
        return AppColor.goldAccent;
      case 'other':
        return AppColor.earthBrown;
      default:
        return AppColor.primaryColor;
    }
  }

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.business;
      case 'other':
        return Icons.location_on;
      default:
        return Icons.location_on;
    }
  }

  Color _getCardColor(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Color(0xFF1A1F71);
      case 'mastercard':
        return Color(0xFFEB001B);
      case 'amex':
        return Color(0xFF2E77BC);
      default:
        return AppColor.primaryColor;
    }
  }

  String _getTodayOpeningHours(List<String> openingHours) {
    final now = DateTime.now();
    final today = now.weekday - 1; // Monday = 0, Sunday = 6
    if (today < openingHours.length) {
      return openingHours[today];
    }
    return AppLocalizations.of(context)!.hoursNotAvailable;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.checkout),
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColor.primaryColor),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.loadingCheckoutData,
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.checkout),
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.failedToLoadCheckoutData,
                style: TextStyle(
                  color: AppColor.warningColor,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _errorMessage,
                  style: TextStyle(
                    color: AppColor.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCheckoutData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                ),
                child: Text(AppLocalizations.of(context)!.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.checkout),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show address section only for delivery
                  if (_selectedDeliveryMethod == DeliveryMethod.delivery) ...[
                    _buildSectionHeader(
                      title: AppLocalizations.of(context)!.shippingAddress,
                      onEdit: _showAddressSelectionDialog,
                    ),
                    _buildAddressSelectionSection(isDark),
                    SizedBox(height: 24),
                  ],

                  _buildSectionHeader(title: AppLocalizations.of(context)!.deliveryMethod),
                  const SizedBox(height: 12),
                  _buildDeliveryMethodSection(isDark),

                  // Show store selection only for pickup
                  if (_selectedDeliveryMethod == DeliveryMethod.pickup) ...[
                    SizedBox(height: 16),
                    _buildStoreSelectionSection(isDark),
                  ],

                  SizedBox(height: 24),
                  _buildSectionHeader(title: AppLocalizations.of(context)!.paymentMethod),
                  _buildPaymentMethodSection(isDark),

                  // Show payment method selection only for online payment
                  if (_selectedPaymentType == PaymentType.online) ...[
                    SizedBox(height: 16),
                    _buildPaymentMethodSelectionSection(isDark),
                  ],

                  SizedBox(height: 24),
                  _buildSectionHeader(title: '${AppLocalizations.of(context)!.orderSummary} (${widget.cartItems.length})'),
                  _buildOrderItemsSection(isDark),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildOrderSummary(isDark),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(bool isDark) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSummaryRow(AppLocalizations.of(context)!.subtotal, widget.cartSummary.subtotal),
              _buildSummaryRow(AppLocalizations.of(context)!.shipping, widget.cartSummary.shipping),
              _buildSummaryRow(AppLocalizations.of(context)!.tax, widget.cartSummary.tax),
              Divider(height: 20, thickness: 2),
              _buildSummaryRow(AppLocalizations.of(context)!.total, widget.cartSummary.total, isTotal: true),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isPlacingOrder ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isPlacingOrder
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 20),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${AppLocalizations.of(context)!.placeOrder} - \$${widget.cartSummary.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSelectionSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedAddress != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getLabelColor(_selectedAddress!.label).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getLabelIcon(_selectedAddress!.label),
                        color: _getLabelColor(_selectedAddress!.label),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedAddress!.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8),
                              if (_selectedAddress!.isDefault)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColor.successColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColor.successColor),
                                  ),
                                  child: Text(
                                    'Default',
                                    style: TextStyle(
                                      color: AppColor.successColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                      color: AppColor.grey),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  _selectedAddress!.streetAddress,
                  style: TextStyle(fontSize: 14, color: AppColor.grey),
                ),
                SizedBox(height: 4),
                Text(
                  '${_selectedAddress!.city}, ${_selectedAddress!.state} ${_selectedAddress!.zipCode}',
                  style: TextStyle(fontSize: 14, color: AppColor.grey),
                ),
              ],
            )
          else
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.warningColor),
              ),
              child: Center(
                child: Text(
                  '${AppLocalizations.of(context)!.pleaseAddAddress}',
                  style: TextStyle(
                    color: AppColor.warningColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreSelectionSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pickup Store',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: _showStoreSelectionDialog,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(50, 30),
                ),
                child: Text(
                  AppLocalizations.of(context)!.changeStore,
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (_selectedStore != null)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF3A3129) : AppColor.backgroundcolor2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.store, color: AppColor.primaryColor),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedStore!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _selectedStore!.address,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 12, color: AppColor.grey),
                            SizedBox(width: 4),
                            Text(
                              '${_selectedStore!.distance.toStringAsFixed(1)} km away',
                              style: TextStyle(fontSize: 11, color: AppColor.grey),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.access_time, size: 12, color: AppColor.grey),
                            SizedBox(width: 4),
                            Text(
                              _getTodayOpeningHours(_selectedStore!.openingHours),
                              style: TextStyle(fontSize: 11, color: AppColor.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    color: AppColor.grey),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.warningColor),
              ),
              child: Center(
                child: Text(
                  'Please select a store for pickup',
                  style: TextStyle(
                    color: AppColor.warningColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelectionSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Payment Card',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: _showPaymentMethodSelectionDialog,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(50, 30),
                ),
                child: Text(
                  AppLocalizations.of(context)!.changeCard,
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (_selectedPaymentMethod != null)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF3A3129) : AppColor.backgroundcolor2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCardColor(_selectedPaymentMethod!.cardType),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _selectedPaymentMethod!.cardType == 'Visa' ? 'VISA' :
                        _selectedPaymentMethod!.cardType == 'Mastercard' ? 'MC' : 'AMEX',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedPaymentMethod!.nickname ?? _selectedPaymentMethod!.cardType,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            if (_selectedPaymentMethod!.isDefault)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColor.successColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColor.successColor),
                                ),
                                child: Text(
                                  'Default',
                                  style: TextStyle(
                                    color: AppColor.successColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          _selectedPaymentMethod!.cardNumber,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.grey,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Expires ${_selectedPaymentMethod!.expiryDate}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColor.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    color: AppColor.grey),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.warningColor),
              ),
              child: Center(
                child: Text(
                  'Please select a payment method',
                  style: TextStyle(
                    color: AppColor.warningColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, VoidCallback? onEdit}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.primaryColor,
            ),
          ),
          Spacer(),
          if (onEdit != null)
            TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(50, 30),
              ),
              child: Text(
                AppLocalizations.of(context)!.changeAction,
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderGray),
      ),
      child: Column(
        children: [
          // Delivery Option
          _buildDeliveryOption(
            isDark: isDark,
            method: DeliveryMethod.delivery,
            title: 'Home Delivery',
            subtitle: '2-3 business days',
            price: widget.cartSummary.shipping > 0 ? '\$${widget.cartSummary.shipping.toStringAsFixed(2)}' : 'Free',
            isSelected: _selectedDeliveryMethod == DeliveryMethod.delivery,
          ),
          SizedBox(height: 12),

          // Pickup Option
          _buildDeliveryOption(
            isDark: isDark,
            method: DeliveryMethod.pickup,
            title: 'Store Pickup',
            subtitle: 'Pick up from our nearest store',
            price: 'Free',
            isSelected: _selectedDeliveryMethod == DeliveryMethod.pickup,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOption({
    required bool isDark,
    required DeliveryMethod method,
    required String title,
    required String subtitle,
    required String price,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeliveryMethod = method;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : AppColor.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColor.primaryColor : AppColor.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14, color: AppColor.primaryColor)
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColor.primaryColor : AppColor.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderGray),
      ),
      child: Column(
        children: [
          // Cash on Delivery Option
          _buildPaymentTypeOption(
            isDark: isDark,
            type: PaymentType.cashOnDelivery,
            title: AppLocalizations.of(context)!.cashOnDelivery,
            subtitle: 'Pay when you receive your order',
            isSelected: _selectedPaymentType == PaymentType.cashOnDelivery,
          ),
          SizedBox(height: 12),

          // Online Payment Option
          _buildPaymentTypeOption(
            isDark: isDark,
            type: PaymentType.online,
            title: AppLocalizations.of(context)!.creditCard,
            subtitle: 'Pay securely with your card',
            isSelected: _selectedPaymentType == PaymentType.online,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTypeOption({
    required bool isDark,
    required PaymentType type,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : AppColor.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColor.primaryColor : AppColor.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14, color: AppColor.primaryColor)
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderGray),
      ),
      child: Column(
        children: widget.cartItems.map((item) {
          return _buildOrderItem(item, isDark);
        }).toList(),
      ),
    );
  }

  Widget _buildOrderItem(CartItem item, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColor.backgroundcolor2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.images.isNotEmpty
                  ? Image.network(
                item.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
                  : _buildImagePlaceholder(),
            ),
          ),
          SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                if (item.sizes.isNotEmpty || item.colors.isNotEmpty)
                  Text(
                    '${item.sizes.isNotEmpty ? item.sizes.first : ''}${item.sizes.isNotEmpty && item.colors.isNotEmpty ? ' • ' : ''}${item.colors.isNotEmpty ? item.colors.first : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.grey,
                    ),
                  ),
                SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.grey,
                  ),
                ),
              ],
            ),
          ),

          // Price
          Text(
            '\$${(item.finalPrice * item.quantity).toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColor.backgroundcolor2,
      child: Icon(
        Icons.image_outlined,
        size: 20,
        color: AppColor.grey,
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 17 : 15,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? AppColor.primaryColor : AppColor.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 16),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 19 : 15,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColor.primaryColor : AppColor.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Enums for delivery and payment methods
enum DeliveryMethod { delivery, pickup }
enum PaymentType { cashOnDelivery, online }