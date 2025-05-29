import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:money_clone/auth/auth_service.dart';
import 'package:money_clone/ui/theme.dart';

class AuthScreen extends StatefulWidget {
  final Widget child;

  const AuthScreen({super.key, required this.child});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _pinController = TextEditingController();
  bool _isAuthenticated = false;
  bool _isBiometricAvailable = false;
  bool _isCheckingBiometrics = true;
  bool _isPinSetup = false;
  bool _isConfirmingPin = false;
  String _temporaryPin = '';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _checkPinSetup();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final isBiometricAvailable = await _authService.isBiometricAvailable();
    setState(() {
      _isBiometricAvailable = isBiometricAvailable;
      _isCheckingBiometrics = false;
    });

    if (isBiometricAvailable) {
      _authenticateWithBiometrics();
    }
  }
  Future<void> _checkPinSetup() async {
    final storedPin = await _authService.getStoredPIN();
    setState(() {
      _isPinSetup = storedPin != null && storedPin.isNotEmpty;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isBiometricAvailable) {
      final authenticated = await _authService.authenticateWithBiometrics();
      if (authenticated) {
        setState(() {
          _isAuthenticated = true;
        });
      }
    }
  }

  Future<void> _authenticateWithPIN() async {
    if (_pinController.text.isNotEmpty) {
      final authenticated = await _authService.authenticateWithPIN(_pinController.text);
      if (authenticated) {
        setState(() {
          _isAuthenticated = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid PIN. Please try again.')),
        );
        _pinController.clear();
      }
    }
  }

  Future<void> _setupPIN() async {
    if (_pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be at least 4 digits')),
      );
      return;
    }

    if (!_isConfirmingPin) {
      // First entry - store PIN temporarily and ask for confirmation
      setState(() {
        _temporaryPin = _pinController.text;
        _isConfirmingPin = true;
      });
      _pinController.clear();
      return;
    }

    // Second entry - confirm PIN
    if (_pinController.text == _temporaryPin) {
      final success = await _authService.setPIN(_pinController.text);
      if (success) {
        setState(() {
          _isPinSetup = true;
          _isConfirmingPin = false;
          _isAuthenticated = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to set PIN. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs do not match. Please try again.')),
      );
      setState(() {
        _isConfirmingPin = false;
      });
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return widget.child;
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _isCheckingBiometrics
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.security,
                      size: 80,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _isPinSetup
                          ? 'Enter PIN to unlock'
                          : _isConfirmingPin
                              ? 'Confirm your PIN'
                              : 'Create a PIN to secure your data',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isPinSetup
                          ? 'Please enter your PIN to access your financial data'
                          : _isConfirmingPin
                              ? 'Enter the PIN again to confirm'
                              : 'This PIN will be used to protect your financial data',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _pinController,
                      decoration: const InputDecoration(
                        labelText: 'PIN',
                        hintText: 'Enter your PIN',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isPinSetup ? _authenticateWithPIN : _setupPIN,
                      child: Text(_isPinSetup ? 'Unlock' : 'Set PIN'),
                    ),
                    if (_isPinSetup && _isBiometricAvailable) ...[
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: _authenticateWithBiometrics,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Use biometric authentication'),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
