import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pincode;
import '../providers/auth_provider.dart';
import '../../../../widgets/common/custom_button.dart';
import '../../../../widgets/common/loading_screen.dart';
import '../../../../widgets/common/animated_page.dart';
import '../../domain/auth_constants.dart';

/// Page for OTP input and verification
class OtpInputPage extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpInputPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpInputPage> createState() => _OtpInputPageState();
}

class _OtpInputPageState extends ConsumerState<OtpInputPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 30;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PhoneVerificationState>(phoneVerificationProvider,
        (previous, next) {
      switch (next) {
        case PhoneVerificationVerifyingCode():
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
          break;

        case PhoneVerificationVerified():
          setState(() => _isLoading = false);
          if (next.isNewUser) {
            context.go(AuthConstants.profileSetupRoute);
          } else {
            context.go(AuthConstants.homeRoute);
          }
          break;

        case PhoneVerificationCodeSent():
          setState(() => _isLoading = false);
          _startResendTimer();
          _showSuccessSnackBar('Verification code sent successfully');
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
        title: const Text('Verification'),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    Text(
                      'Enter verification code',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                        children: [
                          const TextSpan(text: 'We sent a 6-digit code to '),
                          TextSpan(
                            text:
                                AuthUtils.formatPhoneNumber(widget.phoneNumber),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // OTP input
                    pincode.PinCodeTextField(
                      appContext: context,
                      length: AuthConstants.otpLength,
                      controller: _otpController,
                      animationType: pincode.AnimationType.fade,
                      pinTheme: pincode.PinTheme(
                        shape: pincode.PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12),
                        fieldHeight: 56,
                        fieldWidth: 48,
                        activeFillColor: Theme.of(context).colorScheme.surface,
                        inactiveFillColor:
                            Theme.of(context).colorScheme.surface,
                        selectedFillColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.5),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        errorBorderColor: Theme.of(context).colorScheme.error,
                      ),
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onCompleted: (value) {
                        if (value.length == AuthConstants.otpLength) {
                          _handleVerifyCode();
                        }
                      },
                      onChanged: (value) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the verification code';
                        }
                        if (value.length != AuthConstants.otpLength) {
                          return 'Please enter a 6-digit code';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Test number hint
                    if (AuthUtils.isTestPhoneNumber(widget.phoneNumber))
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Test code: ${AuthUtils.getTestOtp(widget.phoneNumber)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Resend code section
                    if (_canResend)
                      TextButton(
                        onPressed: _handleResendCode,
                        child: Text(
                          'Didn\'t receive the code? Resend',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Resend code in ${_resendCountdown}s',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                      ),

                    const Spacer(),

                    // Verify button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: _isLoading ? null : _handleVerifyCode,
                        text: _isLoading ? 'Verifying...' : 'Verify Code',
                        isLoading: _isLoading,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Change number option
                    TextButton(
                      onPressed: () {
                        ref.read(phoneVerificationProvider.notifier).reset();
                        context.pop();
                      },
                      child: Text(
                        'Use a different phone number',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
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

  void _handleVerifyCode() {
    if (!_formKey.currentState!.validate()) return;

    final otpCode = _otpController.text.trim();
    if (otpCode.length != AuthConstants.otpLength) {
      _showErrorSnackBar('Please enter a 6-digit verification code');
      return;
    }

    final phoneNotifier = ref.read(phoneVerificationProvider.notifier);
    phoneNotifier.verifyOtpCode(widget.verificationId, otpCode);
  }

  void _handleResendCode() {
    if (!_canResend) return;

    final phoneNotifier = ref.read(phoneVerificationProvider.notifier);
    phoneNotifier.resendCode(widget.phoneNumber);
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

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
