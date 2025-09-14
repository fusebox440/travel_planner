import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../widgets/common/custom_button.dart';
import '../../../../widgets/common/custom_text_field.dart';
import '../../../../widgets/common/loading_screen.dart';
import '../../../../widgets/common/animated_page.dart';
import '../../domain/auth_constants.dart';

/// Page for phone number input
class PhoneInputPage extends ConsumerStatefulWidget {
  const PhoneInputPage({super.key});

  @override
  ConsumerState<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends ConsumerState<PhoneInputPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  // Country codes for dropdown
  final _countryCodes = [
    {'code': '+1', 'country': 'US', 'flag': '🇺🇸'},
    {'code': '+91', 'country': 'IN', 'flag': '🇮🇳'},
    {'code': '+44', 'country': 'UK', 'flag': '🇬🇧'},
    {'code': '+33', 'country': 'FR', 'flag': '🇫🇷'},
    {'code': '+49', 'country': 'DE', 'flag': '🇩🇪'},
    {'code': '+81', 'country': 'JP', 'flag': '🇯🇵'},
    {'code': '+86', 'country': 'CN', 'flag': '🇨🇳'},
  ];

  String _selectedCountryCode = '+1';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PhoneVerificationState>(phoneVerificationProvider,
        (previous, next) {
      switch (next) {
        case PhoneVerificationSendingCode():
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
          break;

        case PhoneVerificationCodeSent():
          setState(() => _isLoading = false);
          context.push(
              '${AuthConstants.otpInputRoute}?verificationId=${next.verificationId}&phoneNumber=${next.phoneNumber}');
          break;

        case PhoneVerificationAutoVerified():
        case PhoneVerificationVerified():
          setState(() => _isLoading = false);
          if (next is PhoneVerificationVerified) {
            if (next.isNewUser) {
              context.go(AuthConstants.profileSetupRoute);
            } else {
              context.go(AuthConstants.homeRoute);
            }
          }
          break;

        case PhoneVerificationError():
          setState(() {
            _isLoading = false;
            _errorMessage = next.message;
          });
          _showErrorSnackBar(next.message);
          break;

        default:
          setState(() => _isLoading = false);
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Phone Number'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: AnimatedPage(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'What\'s your phone number?',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'We\'ll send you a verification code to confirm your number.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),

                    const SizedBox(height: 32),

                    // Phone input with country code
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country code dropdown
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            items: _countryCodes.map((country) {
                              return DropdownMenuItem<String>(
                                value: country['code'] as String,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Text(
                                    '${country['flag']} ${country['code']}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCountryCode = value);
                              }
                            },
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Phone number input
                        Expanded(
                          child: CustomTextField(
                            controller: _phoneController,
                            labelText: 'Phone Number',
                            hintText: 'Enter your phone number',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(15),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }

                              final fullNumber = _selectedCountryCode + value;
                              if (!AuthUtils.isValidPhoneNumber(fullNumber)) {
                                return 'Please enter a valid phone number';
                              }

                              return null;
                            },
                            onChanged: (value) {
                              if (_errorMessage != null) {
                                setState(() => _errorMessage = null);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Test numbers info
                    if (AuthUtils.isTestPhoneNumber(
                        _selectedCountryCode + _phoneController.text))
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Test number detected. Use code: ${AuthUtils.getTestOtp(_selectedCountryCode + _phoneController.text)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: _isLoading ? null : _handleContinue,
                        text: _isLoading ? 'Sending Code...' : 'Continue',
                        isLoading: _isLoading,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Terms notice
                    Text(
                      'By continuing, you confirm that you can receive SMS messages at this number. Message and data rates may apply.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (!_formKey.currentState!.validate()) return;

    final fullPhoneNumber = _selectedCountryCode + _phoneController.text.trim();
    final phoneNotifier = ref.read(phoneVerificationProvider.notifier);
    phoneNotifier.verifyPhoneNumber(fullPhoneNumber);
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
