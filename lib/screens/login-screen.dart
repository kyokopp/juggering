import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
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

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      HapticFeedback.mediumImpact();

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        String message = 'Falha no login';
        if (e.code == 'user-not-found') {
          message = 'Usuário não encontrado.';
        } else if (e.code == 'wrong-password') {
          message = 'Senha incorreta.';
        } else if (e.code == 'invalid-email') {
          message = 'E-mail inválido.';
        }

        if (mounted) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: const Color(0xFFB81C1C),
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
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _handleForgotPassword() {
    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();

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
              
              Navigator.pop(context);
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _navigateToSignUp() {
    HapticFeedback.lightImpact();
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
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: _BackgroundGradient(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: ResponsiveContainer(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: AutofillGroup(
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
                            onTogglePassword: () {
                              HapticFeedback.selectionClick();
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
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
        ),
      ),
    );
  }
}

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
            Color(0xFF7A1E1E),
            Color(0xFF4A0E0E),
            Color(0xFF2A0808),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB81C1C).withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/vopec_icon.png',
        height: 100,
        width: 100,
        cacheWidth: 200,
        cacheHeight: 200,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

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
            fontFamily: '.SF Pro Display',
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
            fontFamily: '.SF Pro Text',
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool obscurePassword;
  final bool isLoading;
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
    required this.onTogglePassword,
    required this.onLogin,
    required this.onForgotPassword,
  });

  static final _cardBgColor = CupertinoColors.systemGrey.withValues(alpha: 0.25);
  static final _cardBorderColor = CupertinoColors.systemGrey2.withValues(alpha: 0.4);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CustomFormField(
              controller: emailController,
              focusNode: emailFocusNode,
              placeholder: 'E-mail',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              icon: CupertinoIcons.mail,
              autofillHints: const [AutofillHints.email],
              onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Digite seu e-mail';
                if (!value.contains('@')) return 'E-mail inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _CustomFormField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              placeholder: 'Senha',
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              icon: CupertinoIcons.lock,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => onLogin(),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Digite sua senha';
                if (value.length < 6) return 'Senha muito curta';
                return null;
              },
              suffixIcon: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onTogglePassword,
                child: Icon(
                  obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  color: const Color(0xFFFF8A8A),
                  size: 18,
                ),
              ),
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

class _CustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;

  const _CustomFormField({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffixIcon,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
  });

  static final _fieldBgColor = CupertinoColors.systemGrey.withValues(alpha: 0.08);
  static final _fieldBorderColor = CupertinoColors.systemGrey2.withValues(alpha: 0.25);
  static final _placeholderColor = CupertinoColors.systemGrey.withValues(alpha: 0.6);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: const TextStyle(
        color: CupertinoColors.white,
        fontSize: 16,
      ),
      cursorColor: const Color(0xFFFF8A8A),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: _placeholderColor, fontSize: 16),
        filled: true,
        fillColor: _fieldBgColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, color: const Color(0xFFFF8A8A), size: 18),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        suffixIcon: suffixIcon != null
            ? Padding(padding: const EdgeInsets.only(right: 8), child: suffixIcon)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _fieldBorderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _fieldBorderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8A8A), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF453A), fontSize: 12),
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