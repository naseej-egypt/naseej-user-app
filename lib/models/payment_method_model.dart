class PaymentMethodModel {
  final String id;
  final String customerId;
  final String cardType;
  final String cardHolderName;
  final String cardNumber;
  final String lastFourDigits;
  final String expiryMonth;
  final String expiryYear;
  final String expiryDate;
  final String? nickname;
  bool isDefault;
  final String token;
  final String? createdAt;
  final String? updatedAt;

  PaymentMethodModel({
    required this.id,
    required this.customerId,
    required this.cardType,
    required this.cardHolderName,
    required this.cardNumber,
    required this.lastFourDigits,
    required this.expiryMonth,
    required this.expiryYear,
    required this.expiryDate,
    this.nickname,
    this.isDefault = false,
    required this.token,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'card_type': cardType,
      'card_holder_name': cardHolderName,
      'card_number': cardNumber,
      'last_four_digits': lastFourDigits,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'expiry_date': expiryDate,
      'nickname': nickname,
      'is_default': isDefault,
      'token': token,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      cardType: json['card_type'] ?? 'Visa',
      cardHolderName: json['card_holder_name'] ?? '',
      cardNumber: json['card_number'] ?? '',
      lastFourDigits: json['last_four_digits'] ?? '',
      expiryMonth: json['expiry_month'] ?? '',
      expiryYear: json['expiry_year'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      nickname: json['nickname'],
      isDefault: json['is_default'] == true || json['is_default'] == '1',
      token: json['token'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Helper method to get card icon based on type
  String get cardIcon {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return 'assets/icons/visa.png';
      case 'mastercard':
        return 'assets/icons/mastercard.png';
      case 'amex':
        return 'assets/icons/amex.png';
      default:
        return 'assets/icons/credit_card.png';
    }
  }

  // Helper method to get display name
  String get displayName {
    if (nickname != null && nickname!.isNotEmpty) {
      return nickname!;
    }
    return '$cardType •••• $lastFourDigits';
  }
}