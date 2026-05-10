import 'package:crypto_wallet_demo/app/theme/app_colors.dart';
import 'package:crypto_wallet_demo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:crypto_wallet_demo/features/auth/presentation/bloc/auth_event.dart';
import 'package:crypto_wallet_demo/features/auth/presentation/bloc/auth_state.dart';
import 'package:crypto_wallet_demo/features/auth/presentation/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateWalletPage extends StatefulWidget {
  const CreateWalletPage({super.key});

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _agreedToTerms = false;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go('/onboarding'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Create Your Wallet',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Set a secure PIN to protect your wallet. This PIN will be\nrequired to authorize transactions.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),
                // PIN Field
                _buildPinField(
                  controller: _pinController,
                  label: 'Wallet PIN',
                  obscure: _obscurePin,
                  onToggle: () => setState(() => _obscurePin = !_obscurePin),
                  validator: (value) {
                    if (value == null || value.length < 4) {
                      return 'PIN must be at least 4 digits';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'PIN must contain only numbers';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Confirm PIN Field
                _buildPinField(
                  controller: _confirmPinController,
                  label: 'Confirm PIN',
                  obscure: _obscureConfirmPin,
                  onToggle: () =>
                      setState(() => _obscureConfirmPin = !_obscureConfirmPin),
                  validator: (value) {
                    if (value != _pinController.text) {
                      return 'PINs do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Terms agreement
                _buildTermsCheckbox(),
                const SizedBox(height: 32),
                // Continue button
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthWalletCreated) {
                      _navigateToBackup(context);
                    } else if (state is AuthFailureState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.failure.message),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return AbsorbPointer(
                      absorbing: isLoading,
                      child: AuthButton(
                        text: 'Create Wallet',
                        onPressed: _onCreatePressed,
                        isLoading: isLoading,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Back link
                Center(
                  child: TextButton(
                    onPressed: () => GoRouter.of(context).go('/onboarding'),
                    child: const Text('Back to welcome'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textTertiary,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildTermsCheckbox() {
    return CheckboxListTile(
      title: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'I agree to the '),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(color: AppColors.primary),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(color: AppColors.primary),
            ),
          ],
        ),
      ),
      value: _agreedToTerms,
      onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
    );
  }

  void _onCreatePressed() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the terms to continue'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthCreateWallet(
            pin: _pinController.text,
          ),
        );
  }

  void _navigateToBackup(BuildContext context) {
    GoRouter.of(context).go('/onboarding/backup');
  }
}