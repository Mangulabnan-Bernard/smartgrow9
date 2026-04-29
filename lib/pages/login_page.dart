import 'package:flutter/cupertino.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }

    if (_isSignUp) {
      if (_nameController.text.isEmpty) {
        setState(() => _errorMessage = 'Please enter your name');
        return;
      }
      if (_confirmPasswordController.text.isEmpty) {
        setState(() => _errorMessage = 'Please confirm your password');
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() => _errorMessage = 'Passwords do not match');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await AuthService.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
      } else {
        await AuthService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      // Navigation will be handled by auth state listener in main.dart
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Logo/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  CupertinoIcons.leaf_arrow_circlepath,
                  color: CupertinoColors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'SmartGrow AI',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                _isSignUp ? 'Create your account' : 'Welcome back',
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (_errorMessage != null) const SizedBox(height: 16),

              // Name field (only for sign up)
              if (_isSignUp) ...[
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'Full Name',
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onChanged: (_) => setState(() => _errorMessage = null),
                ),
                const SizedBox(height: 16),
              ],

              // Email field
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Email',
                keyboardType: TextInputType.emailAddress,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),

              const SizedBox(height: 16),

              // Password field
              CupertinoTextField(
                controller: _passwordController,
                placeholder: 'Password',
                obscureText: true,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),

              const SizedBox(height: 16),

              // Confirm Password field (only for sign up)
              if (_isSignUp) ...[
                CupertinoTextField(
                  controller: _confirmPasswordController,
                  placeholder: 'Confirm Password',
                  obscureText: true,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onChanged: (_) => setState(() => _errorMessage = null),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),

              // Sign in/up button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _isLoading ? null : _handleAuth,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isLoading ? CupertinoColors.systemGrey4 : CupertinoColors.systemGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isLoading
                      ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                      : Text(
                          _isSignUp ? 'Create Account' : 'Sign In',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Toggle sign in/up
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign In'
                      : 'Don\'t have an account? Sign Up',
                  style: const TextStyle(
                    color: CupertinoColors.systemGreen,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
