import 'package:first_flutter/config/baseControllers/APis.dart';
import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class LegalDocument {
  final int id;
  final String type;
  final String? role;
  final String title;
  final String content;
  final bool isActive;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  LegalDocument({
    required this.id,
    required this.type,
    this.role, // Remove required
    required this.title,
    required this.content,
    required this.isActive,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      role: json['role'],
      // Can be null
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isActive: json['is_active'] ?? false,
      version: json['version'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}

// Provider for managing legal documents
class LegalDocumentProvider extends ChangeNotifier {
  List<LegalDocument> _documents = [];
  bool _isLoading = false;
  String? _error;
  bool _isDocumentNotAvailable = false;

  List<LegalDocument> get documents => _documents;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isDocumentNotAvailable => _isDocumentNotAvailable;

  Future<void> fetchDocument(String type, String role) async {
    _isLoading = true;
    _error = null;
    _isDocumentNotAvailable = false;
    notifyListeners();

    try {
      final url = '$base_url/api/admin/legal/by-type?type=$type';

      debugPrint('🌐 API URL: $url');

      final response = await http.get(Uri.parse(url));

      debugPrint('📡 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] is List) {
          _documents = (jsonData['data'] as List)
              .map((e) => LegalDocument.fromJson(e))
              .toList();

          _isDocumentNotAvailable = _documents.isEmpty;
        } else {
          _error = 'Invalid response format';
        }
      } else if (response.statusCode == 404) {
        _isDocumentNotAvailable = true;
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearDocument() {
    _documents = [];
    _error = null;
    _isLoading = false;
    _isDocumentNotAvailable = false;
    notifyListeners();
  }
}

// Legal Document Screen
class TermsandConditions extends StatefulWidget {
  final String type; // privacy_policy, terms, code_of_conduct
  final List<String> roles; // ["user", "provider"]

  const TermsandConditions({Key? key, required this.type, required this.roles})
    : super(key: key);

  @override
  State<TermsandConditions> createState() => _TermsandConditionsState();
}

class _TermsandConditionsState extends State<TermsandConditions> {
  late LegalDocumentProvider _provider;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _provider = LegalDocumentProvider();
    _selectedRole = widget.roles.isNotEmpty ? widget.roles.first : null;
    if (_selectedRole != null) {
      _loadDocument();
    }
  }

  void _loadDocument() {
    if (_selectedRole != null) {
      _provider.fetchDocument(widget.type, _selectedRole!);
    }
  }

  String _getTitle() {
    switch (widget.type) {
      case 'privacy_policy':
        return 'Privacy Policy';
                                                                                                                                                                                                                                                                                                      case 'terms':
        return 'Terms of Service';
      case 'code_of_conduct':
        return 'Code of Conduct';
      default:
        return 'Legal Document';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: ColorConstant.scaffoldGray,
          appBar: AppBar(
            backgroundColor: ColorConstant.appColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: ColorConstant.white,
                size: 24.sp,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              _getTitle(),
              style: TextStyle(
                color: ColorConstant.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: AnimatedBuilder(
          animation: _provider,
          builder: (context, child) {
            if (_provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (_provider.isDocumentNotAvailable) {
              return _EmptyState(
                icon: Icons.description_outlined,
                title: 'No Document Available',
                subtitle: 'This document is not published yet.',
              );
            }

            if (_provider.error != null) {
              return _EmptyState(
                icon: Icons.error_outline,
                title: 'Something went wrong',
                subtitle: _provider.error!,
                actionText: 'Retry',
                onAction: _loadDocument,
              );
            }

            if (_provider.documents.isEmpty) {
              return const _EmptyState(
                icon: Icons.info_outline,
                title: 'No Content',
                subtitle: 'Nothing to show here.',
              );
            }

            final document = _provider.documents.first;

            return Column(
              children: [
                /// ROLE SELECTOR (STICKY)
                if (widget.roles.length > 1)
                  Container(
                    margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 18),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Wrap(
                            spacing: 8.w,
                            children: widget.roles.map((role) {
                              final isSelected = role == _selectedRole;
                              return ChoiceChip(
                                label: Text(role.toUpperCase()),
                                selected: isSelected,
                                selectedColor: ColorConstant.call4helpOrange,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (_) {
                                  setState(() => _selectedRole = role);
                                  _loadDocument();
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                /// DOCUMENT CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER CARD
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                document.title,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  _MetaChip(
                                    icon: Icons.update,
                                    label: 'v${document.version}',
                                  ),
                                  SizedBox(width: 8.w),
                                  _MetaChip(
                                    icon: Icons.calendar_today,
                                    label:
                                    'Updated ${_formatDate(document.updatedAt)}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        /// CONTENT CARD
                        Container(
                          padding: EdgeInsets.all(18.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Html(
                            data: document.content,
                            style: {
                              "body": Style(
                                fontSize: FontSize(15.sp),
                                lineHeight: LineHeight(1.7),
                                color: ColorConstant.black,
                              ),
                              "h1": Style(fontSize: FontSize(22.sp)),
                              "h2": Style(fontSize: FontSize(20.sp)),
                              "p": Style(margin: Margins.only(bottom: 12.h)),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }


}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: ColorConstant.call4helpOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ColorConstant.call4helpOrange),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: ColorConstant.call4helpOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text(subtitle, textAlign: TextAlign.center),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
