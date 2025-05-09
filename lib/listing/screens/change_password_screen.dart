import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _newPasswordError;
  String? _confirmPasswordError;

  bool get _isNewPasswordValid => _newPasswordController.text.length >= 6;
  bool get _doPasswordsMatch =>
      _newPasswordController.text == _confirmPasswordController.text;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      _newPasswordError =
          _isNewPasswordValid ? null : 'Must be at least 6 characters';
      _confirmPasswordError =
          _doPasswordsMatch ? null : 'Passwords do not match';
    });
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    _validateFields();

    if (!_isNewPasswordValid || !_doPasswordsMatch) return;
    if (currentPassword.isEmpty) {
      _showMessage('Please enter your current password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      _showMessage('Password changed successfully');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showMessage('Firebase Error: ${e.message}');
    } catch (e) {
      _showMessage('Unexpected error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    String? errorText,
    bool showValidation = false,
    bool isValid = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: (_) => _validateFields(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: errorText,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showValidation)
              Icon(
                isValid ? Icons.check_circle : Icons.cancel,
                color: isValid ? Colors.green : Colors.red,
              ),
            IconButton(
              icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: toggleVisibility,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPasswordField(
              label: "Current Password",
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              toggleVisibility: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: "New Password",
              controller: _newPasswordController,
              obscureText: _obscureNew,
              toggleVisibility: () =>
                  setState(() => _obscureNew = !_obscureNew),
              errorText: _newPasswordError,
              showValidation: _newPasswordController.text.isNotEmpty,
              isValid: _isNewPasswordValid,
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: "Confirm New Password",
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              toggleVisibility: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              errorText: _confirmPasswordError,
              showValidation: _confirmPasswordController.text.isNotEmpty,
              isValid: _doPasswordsMatch,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text("Change Password"),
                  ),
          ],
        ),
      ),
    );
  }
}
