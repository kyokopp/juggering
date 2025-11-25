import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juggering/screens/create-account.dart';
import 'responsive.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this)
      ..forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'Falha no login'),
              backgroundColor: const Color(0xFFC41E3A),
              // Brighter red for error
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _handleForgotPassword() {
    // TODO: Implement forgot password flow
    showCupertinoDialog(
      context: context,
      builder: (context) =>
          CupertinoAlertDialog(
            title: const Text('Recuperar Senha'),
            content: const Text(
                'Digite seu e-mail para receber instruções de recuperação'),
            actions: [
              CupertinoDialogAction(onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  // Handle password reset
                  Navigator.pop(context);
                },
                child: const Text('Enviar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // <CHANGE> Improved gradient with better color depth and hierarchy
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7A1E1E), // Softer red (top)
              Color(0xFF4A0E0E), // Deep burgundy (middle)
              Color(0xFF2A0808), // Very dark red (bottom)
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ResponsiveContainer(
              child: FadeTransition(
                opacity: _fadeController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // <CHANGE> Improved logo styling with better shadow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB81C1C).withValues(
                                alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/vopec_icon.png',
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // <CHANGE> Enhanced welcome text with better typography
                    Text(
                      'Bem-vindo',
                      style: CupertinoTheme
                          .of(context)
                          .textTheme
                          .navLargeTitleTextStyle
                          .copyWith(
                        color: CupertinoColors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // <CHANGE> Added subtitle for better context
                    Text(
                      'Acesse sua conta',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey3,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // <CHANGE> Improved login form card with better styling and opacity
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey.withValues(
                            alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CupertinoColors.systemGrey2.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF000000).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildEnhancedTextField(
                              controller: _emailController,
                              placeholder: 'E-mail',
                              keyboardType: TextInputType.emailAddress,
                              icon: CupertinoIcons.mail,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu e-mail';
                                }
                                if (!value.contains('@')) {
                                  return 'Por favor, insira um e-mail válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // <CHANGE> Password field with visibility toggle
                            _buildPasswordTextField(
                              controller: _passwordController,
                              placeholder: 'Senha',
                              obscureText: _obscurePassword,
                              onToggleVisibility: () =>
                                  setState(() =>
                                  _obscurePassword = !_obscurePassword),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira sua senha';
                                }
                                if (value.length < 6) {
                                  return 'A senha deve ter pelo menos 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            // <CHANGE> Added forgot password link
                            Align(
                              alignment: Alignment.centerRight,
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: _handleForgotPassword,
                                child: const Text(
                                  'Esqueceu a senha?',
                                  style: TextStyle(
                                    color: Color(0xFFFF8A8A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // <CHANGE> Enhanced login button with better styling
                            CupertinoButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFB81C1C),
                              disabledColor: const Color(0xFF8B5A5A),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CupertinoActivityIndicator(
                                    radius: 8, color: CupertinoColors.white),
                              )
                                  : const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // <CHANGE> Improved sign-up link styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não tem uma conta? ',
                          style: TextStyle(color: CupertinoColors.systemGrey3,
                              fontSize: 15),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(builder: (
                                  context) => const CreateAccountScreen()),
                            );
                          }, minimumSize: Size(0, 0),
                          child: const Text(
                            'Cadastre-se',
                            style: TextStyle(
                              color: Color(0xFFFF8A8A),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  // <CHANGE> New improved text field builder with icons and better styling
  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          prefix: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Icon(icon, color: const Color(0xFFFF8A8A), size: 18),
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: CupertinoColors.systemGrey2.withValues(alpha: 0.25), width: 1),
          ),
          style: const TextStyle(color: CupertinoColors.white, fontSize: 16),
          placeholderStyle: TextStyle(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.6)),
          cursorColor: const Color(0xFFFF8A8A),
        ),
        if (validator != null && controller.text.isNotEmpty &&
            validator(controller.text) != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              validator(controller.text)!,
              style: const TextStyle(color: Color(0xFFFF8A8A),
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  // <CHANGE> New password field builder with visibility toggle
  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String placeholder,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          obscureText: obscureText,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          prefix: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Icon(
                CupertinoIcons.lock, color: const Color(0xFFFF8A8A), size: 18),
          ),
          suffix: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onToggleVisibility, minimumSize: Size(0, 0),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                obscureText ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                color: const Color(0xFFFF8A8A),
                size: 18,
              ),
            ),
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: CupertinoColors.systemGrey2.withValues(alpha: 0.25), width: 1),
          ),
          style: const TextStyle(color: CupertinoColors.white, fontSize: 16),
          placeholderStyle: TextStyle(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.6)),
          cursorColor: const Color(0xFFFF8A8A),
        ),
        if (validator != null && controller.text.isNotEmpty &&
            validator(controller.text) != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              validator(controller.text)!,
              style: const TextStyle(color: Color(0xFFFF8A8A),
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }
}