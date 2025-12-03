import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juggering/screens/create-account.dart';
import 'responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _autoValidate = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const _primaryRed = Color(0xFFB81C1C);
  static const _lightRed = Color(0xFFFF8A8A);
  static final _fieldBgColor = CupertinoColors.systemGrey.withValues(alpha: 0.08);
  static final _fieldBorderColor = CupertinoColors.systemGrey2.withValues(alpha: 0.25);
  static final _cardBgColor = CupertinoColors.systemGrey.withValues(alpha:0.25);
  static final _cardBorderColor = CupertinoColors.systemGrey2.withValues(alpha: 0.4);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // Dismiss keyboard immediately for better UX
    FocusScope.of(context).unfocus();

    // Enable validation feedback after first attempt
    if (!_autoValidate) {
      setState(() => _autoValidate = true);
    }

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
              backgroundColor: _primaryRed,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _handleForgotPassword() {
    FocusScope.of(context).unfocus();

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Recuperar Senha'),
        content: const Text(
          'Digite seu e-mail para receber instruções de recuperação',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
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

  void _navigateToSignUp() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const CreateAccountScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: _BackgroundGradient(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ResponsiveContainer(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _LogoSection(),
                      const SizedBox(height: 32),
                      const _WelcomeText(),
                      const SizedBox(height: 48),
                      _LoginForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        emailFocusNode: _emailFocusNode,
                        passwordFocusNode: _passwordFocusNode,
                        obscurePassword: _obscurePassword,
                        isLoading: _isLoading,
                        autoValidate: _autoValidate,
                        onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                        onLogin: _handleLogin,
                        onForgotPassword: _handleForgotPassword,
                      ),
                      const SizedBox(height: 32),
                      _SignUpLink(onSignUp: _navigateToSignUp),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extracted gradient as const to prevent rebuilds
class _BackgroundGradient extends StatelessWidget {
  final Widget child;

  const _BackgroundGradient({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

// Extracted logo section with const shadow
class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB81C1C).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/vopec_icon.png',
        height: 100,
        cacheWidth: 200, // Cache at 2x size for better performance
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

// Extracted welcome text as const
class _WelcomeText extends StatelessWidget {
  const _WelcomeText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Bem-vindo',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
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
      ],
    );
  }
}

// Extracted form into separate widget to isolate rebuilds
class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool obscurePassword;
  final bool isLoading;
  final bool autoValidate;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.obscurePassword,
    required this.isLoading,
    required this.autoValidate,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onForgotPassword,
  });

  // Cache colors
  static final _fieldBgColor = CupertinoColors.systemGrey.withValues(alpha: 0.08);
  static final _fieldBorderColor = CupertinoColors.systemGrey2.withValues(alpha: 0.25);
  static final _cardBgColor = CupertinoColors.systemGrey.withValues(alpha: 0.25);
  static final _cardBorderColor = CupertinoColors.systemGrey2.withValues(alpha: 0.4);
  static final _placeholderColor = CupertinoColors.systemGrey.withValues(alpha: 0.6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _cardBorderColor,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        autovalidateMode: autoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CupertinoTextField(
              controller: emailController,
              focusNode: emailFocusNode,
              placeholder: 'E-mail',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              prefix: const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Icon(
                  CupertinoIcons.mail,
                  color: Color(0xFFFF8A8A),
                  size: 18,
                ),
              ),
              decoration: BoxDecoration(
                color: _fieldBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _fieldBorderColor, width: 1),
              ),
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
              ),
              placeholderStyle: TextStyle(color: _placeholderColor),
              cursorColor: const Color(0xFFFF8A8A),
              onSubmitted: (_) => passwordFocusNode.requestFocus(),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              placeholder: 'Senha',
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              prefix: const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Icon(
                  CupertinoIcons.lock,
                  color: Color(0xFFFF8A8A),
                  size: 18,
                ),
              ),
              suffix: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onTogglePassword, minimumSize: Size(0, 0),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                    color: const Color(0xFFFF8A8A),
                    size: 18,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: _fieldBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _fieldBorderColor, width: 1),
              ),
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
              ),
              placeholderStyle: TextStyle(color: _placeholderColor),
              cursorColor: const Color(0xFFFF8A8A),
              onSubmitted: (_) => onLogin(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onForgotPassword, minimumSize: Size(0, 0),
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
            CupertinoButton(
              onPressed: isLoading ? null : onLogin,
              padding: const EdgeInsets.symmetric(vertical: 14),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFB81C1C),
              disabledColor: const Color(0xFF8B5A5A),
              child: isLoading
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CupertinoActivityIndicator(
                  radius: 8,
                  color: CupertinoColors.white,
                ),
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
    );
  }
}

class _SignUpLink extends StatelessWidget {
  final VoidCallback onSignUp;

  const _SignUpLink({required this.onSignUp});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Não tem uma conta? ',
          style: TextStyle(
            color: CupertinoColors.systemGrey3,
            fontSize: 15,
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onSignUp, minimumSize: Size(0, 0),
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
    );
  }
}