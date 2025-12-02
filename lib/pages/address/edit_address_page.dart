import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/component/button.dart';
import 'package:naseej/main.dart';
import 'package:naseej/models/address_model.dart';
import 'package:naseej/core/class/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';

class EditAddressPage extends StatefulWidget {
  final AddressModel address;

  const EditAddressPage({Key? key, required this.address}) : super(key: key);

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String selectedLabel = 'Home';
  String? authToken;
  Crud crud = Crud();
  String selectedCountry = 'Egypt';

  // List of Arab countries sorted alphabetically
  final List<String> arabCountries = [
    'Algeria',
    'Bahrain',
    'Comoros',
    'Djibouti',
    'Egypt',
    'Iraq',
    'Jordan',
    'Kuwait',
    'Lebanon',
    'Libya',
    'Mauritania',
    'Morocco',
    'Oman',
    'Palestine',
    'Qatar',
    'Saudi Arabia',
    'Somalia',
    'Sudan',
    'Syria',
    'Tunisia',
    'United Arab Emirates',
    'Yemen'
  ];

  // Controllers
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getAuthToken();
    _fillAddressData();
  }

  void _getAuthToken() {
    authToken = sharedPref.getString("token");
  }

  void _fillAddressData() {
    final address = widget.address;
    selectedLabel = address.label;
    streetController.text = address.streetAddress;
    cityController.text = address.city;
    stateController.text = address.state;
    zipCodeController.text = address.zipCode;
    selectedCountry = address.country;
  }

  @override
  void dispose() {
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _updateAddress() async {
    if (_formKey.currentState!.validate() && authToken != null) {
      setState(() {
        isLoading = true;
      });

      try {
        Map<String, dynamic> addressData = {
          'address_id': widget.address.id,
          'street': streetController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'zip_code': zipCodeController.text.trim(),
          'country': selectedCountry,
          'label': selectedLabel, // Include the selected label
        };

        var response = await crud.postRequest(
          AppLink.updateAddress,
          addressData,
          headers: {'Authorization': 'Bearer $authToken'},
        );

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Address updated successfully!'),
              backgroundColor: AppColor.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to update address'),
              backgroundColor: AppColor.warningColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
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
    } else if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication required'),
          backgroundColor: AppColor.warningColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Edit Address'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // Label Selection
            Text(
              'Address Label *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildLabelChip('Home', Icons.home),
                SizedBox(width: 12),
                _buildLabelChip('Work', Icons.business),
                SizedBox(width: 12),
                _buildLabelChip('Other', Icons.location_on),
              ],
            ),
            SizedBox(height: 24),

            // Street Address
            _buildTextField(
              controller: streetController,
              label: 'Street Address *',
              hint: 'House number and street name',
              icon: Icons.home_outlined,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter street address';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // City
            _buildTextField(
              controller: cityController,
              label: 'City *',
              hint: 'Enter city',
              icon: Icons.location_city,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter city';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // State & Zip Code Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: stateController,
                    label: 'State/Province *',
                    hint: 'State',
                    icon: Icons.map_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: zipCodeController,
                    label: 'Zip Code *',
                    hint: '12345',
                    icon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Country Dropdown
            _buildCountryDropdown(isDark),
            SizedBox(height: 32),

            // Update Button
            Button(
              title: 'Update Address',
              isLoading: isLoading,
              onpressed: _updateAddress,
              icon: Icons.save,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelChip(String label, IconData icon) {
    final bool isSelected = selectedLabel == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedLabel = label;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: _getLabelColors(label),
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
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColor.grey,
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                label,
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

  Widget _buildCountryDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF2C2520) : AppColor.backgroundcolor2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCountry,
            icon: Icon(Icons.arrow_drop_down, color: AppColor.primaryColor),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: Icon(Icons.public, size: 20, color: AppColor.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
              ),
            ),
            items: arabCountries.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(
                  country,
                  style: TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCountry = newValue!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a country';
              }
              return null;
            },
          ),
        ),
      ],
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

  List<Color> _getLabelColors(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return [AppColor.primaryColor, AppColor.secondColor];
      case 'work':
        return [AppColor.goldAccent, AppColor.earthBrown];
      case 'other':
        return [AppColor.earthBrown, AppColor.bronzeAccent];
      default:
        return [AppColor.primaryColor, AppColor.secondColor];
    }
  }
}