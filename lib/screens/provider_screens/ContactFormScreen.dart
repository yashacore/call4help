import 'package:first_flutter/baseControllers/APis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../constants/colorConstant/color_constant.dart';

class ContactFormScreen extends StatefulWidget {
  const ContactFormScreen({Key? key}) : super(key: key);

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool isLoading = false;
  bool isSuccess = false;

  // Validation constants
  static const int NAME_MIN_LENGTH = 2;
  static const int NAME_MAX_LENGTH = 50;
  static const int PHONE_MIN_LENGTH = 10;
  static const int PHONE_MAX_LENGTH = 15;
  static const int SUBJECT_MIN_LENGTH = 3;
  static const int SUBJECT_MAX_LENGTH = 100;
  static const int MESSAGE_MIN_LENGTH = 10;
  static const int MESSAGE_MAX_LENGTH = 1000;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Validation methods
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < NAME_MIN_LENGTH) {
      return 'Name must be at least $NAME_MIN_LENGTH characters';
    }

    if (trimmedValue.length > NAME_MAX_LENGTH) {
      return 'Name must not exceed $NAME_MAX_LENGTH characters';
    }

    // Check if name contains only letters, spaces, hyphens, and apostrophes
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(trimmedValue)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    // Check if name doesn't start or end with spaces
    if (value != trimmedValue) {
      return 'Name cannot start or end with spaces';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedValue = value.trim();

    // Comprehensive email validation
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }

    // Check for consecutive dots
    if (trimmedValue.contains('..')) {
      return 'Email cannot contain consecutive dots';
    }

    // Check email length
    if (trimmedValue.length > 254) {
      return 'Email address is too long';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final trimmedValue = value.trim();

    // Remove common separators for validation
    final digitsOnly = trimmedValue.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    if (!RegExp(r'^[0-9]+$').hasMatch(digitsOnly)) {
      return 'Phone number can only contain digits';
    }

    if (digitsOnly.length < PHONE_MIN_LENGTH) {
      return 'Phone number must be at least $PHONE_MIN_LENGTH digits';
    }

    if (digitsOnly.length > PHONE_MAX_LENGTH) {
      return 'Phone number must not exceed $PHONE_MAX_LENGTH digits';
    }

    return null;
  }

  String? _validateSubject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Subject is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < SUBJECT_MIN_LENGTH) {
      return 'Subject must be at least $SUBJECT_MIN_LENGTH characters';
    }

    if (trimmedValue.length > SUBJECT_MAX_LENGTH) {
      return 'Subject must not exceed $SUBJECT_MAX_LENGTH characters';
    }

    // Check for suspicious patterns (all special characters)
    if (RegExp(r'^[^a-zA-Z0-9]+$').hasMatch(trimmedValue)) {
      return 'Subject must contain letters or numbers';
    }

    return null;
  }

  String? _validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < MESSAGE_MIN_LENGTH) {
      return 'Message must be at least $MESSAGE_MIN_LENGTH characters';
    }

    if (trimmedValue.length > MESSAGE_MAX_LENGTH) {
      return 'Message must not exceed $MESSAGE_MAX_LENGTH characters';
    }

    // Check if message contains at least some meaningful content
    if (RegExp(r'^[^a-zA-Z0-9]+$').hasMatch(trimmedValue)) {
      return 'Message must contain letters or numbers';
    }

    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fix the errors in the form');
      return;
    }

    setState(() {
      isLoading = true;
      isSuccess = false;
    });

    try {
      final response = await http.post(
        Uri.parse('$base_url/api/contact'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'subject': _subjectController.text.trim(),
          'message': _messageController.text.trim(),
        }),
      );

      setState(() {
        isLoading = false;
      });


      print(response.body);
      print(_nameController.text.trim());
      print(_emailController.text.trim());
      print(_phoneController.text.trim());
      print(_subjectController.text.trim());
      print(_messageController.text.trim());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            isSuccess = true;
          });
          _showSuccessDialog(data['message'] ?? 'Message sent successfully!');
          _clearForm();
        } else {
          _showErrorDialog(data['message'] ?? 'Failed to send message. Please try again.');
        }
      } else if (response.statusCode == 422) {
        // Validation error from server
        final data = json.decode(response.body);
        _showErrorDialog(data['message'] ?? 'Invalid data submitted.');
      } else if (response.statusCode >= 500) {
        _showErrorDialog('Server error. Please try again later.');
      } else {
        _showErrorDialog('Failed to send message. Please try again.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Network error. Please check your connection and try again.');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _subjectController.clear();
    _messageController.clear();
    _formKey.currentState?.reset();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: ColorConstant.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: ColorConstant.moyoGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: ColorConstant.moyoGreen,
                  size: 64.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Success!',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorConstant.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: ColorConstant.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstant.moyoOrange,
                    foregroundColor: ColorConstant.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: ColorConstant.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorConstant.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: ColorConstant.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstant.moyoOrange,
                    foregroundColor: ColorConstant.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldGray,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorConstant.moyoOrangeFade.withOpacity(0.3),
              ColorConstant.scaffoldGray,
              ColorConstant.buttonBg.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 24.h),
                      _buildInfoCard(),
                      SizedBox(height: 24.h),
                      _buildContactForm(),
                      SizedBox(height: 32.h),
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: ColorConstant.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: ColorConstant.onSurface),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorConstant.onSurface,
                ),
              ),
              Text(
                'We\'d love to hear from you',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorConstant.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConstant.moyoOrange,
            ColorConstant.moyoScaffoldGradient,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.moyoOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: ColorConstant.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: ColorConstant.white,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Help?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorConstant.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Fill out the form and we\'ll get back to you within 24 hours',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: ColorConstant.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: ColorConstant.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send us a message',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: ColorConstant.onSurface,
              ),
            ),
            SizedBox(height: 24.h),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              validator: _validateName,
              inputFormatters: [
                LengthLimitingTextInputFormatter(NAME_MAX_LENGTH),
                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\-']")),
              ],
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              inputFormatters: [
                LengthLimitingTextInputFormatter(254),
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
              inputFormatters: [
                LengthLimitingTextInputFormatter(PHONE_MAX_LENGTH),
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-\(\)\+]')),
              ],
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _subjectController,
              label: 'Subject',
              hint: 'What is this about?',
              icon: Icons.subject_outlined,
              validator: _validateSubject,
              inputFormatters: [
                LengthLimitingTextInputFormatter(SUBJECT_MAX_LENGTH),
              ],
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _messageController,
              label: 'Message',
              hint: 'Write your message here...',
              icon: Icons.message_outlined,
              maxLines: 5,
              validator: _validateMessage,
              inputFormatters: [
                LengthLimitingTextInputFormatter(MESSAGE_MAX_LENGTH),
              ],
              counterText: true,
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstant.moyoOrange,
                  foregroundColor: ColorConstant.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                  shadowColor: ColorConstant.moyoOrange.withOpacity(0.3),
                  disabledBackgroundColor: ColorConstant.moyoOrange.withOpacity(0.5),
                ),
                child: isLoading
                    ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorConstant.white,
                    ),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Send Message',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.send_rounded, size: 20.sp),
                  ],
                ),
              ),
            ),
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
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool counterText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: ColorConstant.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: 15.sp, color: ColorConstant.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: ColorConstant.onSurface.withOpacity(0.4),
            ),
            prefixIcon: Icon(
              icon,
              color: ColorConstant.moyoOrange,
              size: 22.sp,
            ),
            filled: true,
            fillColor: ColorConstant.scaffoldGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: ColorConstant.scaffoldGray,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: ColorConstant.moyoOrange, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            counterText: counterText ? null : '',
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}