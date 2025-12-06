import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'responsive.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      HapticFeedback.mediumImpact();

      UserCredential? userCredential;

      try {
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName(_nameController.text.trim());

          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'phone': _phoneController.text.trim(),
              'role': 'Usuário',
              'email': _emailController.text.trim(),
              'createdAt': FieldValue.serverTimestamp(),
            });
          } catch (firestoreError) {
            await userCredential.user!.delete();
            throw Exception("Erro ao salvar dados. Tente novamente.");
          }
        }

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Conta criada com sucesso!',
                style: TextStyle(fontFamily: '.SF Pro Text'),
              ),
              backgroundColor: Color(0xFF32D74B),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Erro ao criar conta';
        if (e.code == 'email-already-in-use') {
          message = 'Este e-mail já está em uso.';
        } else if (e.code == 'weak-password') {
          message = 'A senha é muito fraca.';
        } else if (e.message != null) {
          message = e.message!;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: const Color(0xFFFF453A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll("Exception: ", "")),
              backgroundColor: const Color(0xFFFF453A),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(
      fontFamily: '.SF Pro Text',
      color: Colors.white,
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CupertinoNavigationBar(
          backgroundColor: Colors.transparent,
          leading: CupertinoNavigationBarBackButton(
            color: CupertinoColors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          middle: Text(
            'Criar Conta',
            style: iosFont.copyWith(fontWeight: FontWeight.w600),
          ),
          border: Border.all(color: Colors.transparent),
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: _BackgroundGradient(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20,
                ),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: ResponsiveContainer(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 80),
                          _SignUpForm(
                            formKey: _formKey,
                            nameController: _nameController,
                            emailController: _emailController,
                            phoneController: _phoneController,
                            passwordController: _passwordController,
                            confirmPasswordController: _confirmPasswordController,
                            nameFocusNode: _nameFocusNode,
                            emailFocusNode: _emailFocusNode,
                            phoneFocusNode: _phoneFocusNode,
                            passwordFocusNode: _passwordFocusNode,
                            confirmPasswordFocusNode: _confirmPasswordFocusNode,
                            showPassword: _showPassword,
                            showConfirmPassword: _showConfirmPassword,
                            isLoading: _isLoading,
                            onTogglePassword: () {
                              HapticFeedback.lightImpact();
                              setState(() => _showPassword = !_showPassword);
                            },
                            onToggleConfirmPassword: () {
                              HapticFeedback.lightImpact();
                              setState(() => _showConfirmPassword = !_showConfirmPassword);
                            },
                            onSignUp: _handleSignUp,
                          ),
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
            Color(0xFFB71C1C),
            Color(0xFF500000),
            Color(0xFF000000),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: child,
    );
  }
}

class _SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode nameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode phoneFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final bool showPassword;
  final bool showConfirmPassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onSignUp;

  const _SignUpForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameFocusNode,
    required this.emailFocusNode,
    required this.phoneFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSignUp,
  });

  static final _cardBg = const Color(0xFF1C1C1E).withValues(alpha: 0.6);
  static final _borderColor = Colors.white.withValues(alpha: 0.1);
  static final _shadowColor = Colors.black.withValues(alpha: 0.3);

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(
      fontFamily: '.SF Pro Text',
      color: Colors.white,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: _shadowColor,
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Junte-se a nós',
                  textAlign: TextAlign.center,
                  style: iosFont.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),

                _CustomTextField(
                  controller: nameController,
                  focusNode: nameFocusNode,
                  placeholder: 'Nome Completo',
                  icon: CupertinoIcons.person_fill,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: (value) =>
                  value!.isEmpty ? 'Por favor, insira seu nome' : null,
                  onFieldSubmitted: (_) => emailFocusNode.requestFocus(),
                ),
                const SizedBox(height: 18),

                _CustomTextField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  placeholder: 'E-mail',
                  icon: CupertinoIcons.mail_solid,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => phoneFocusNode.requestFocus(),
                ),
                const SizedBox(height: 18),

                _CustomTextField(
                  controller: phoneController,
                  focusNode: phoneFocusNode,
                  placeholder: 'Telefone',
                  icon: CupertinoIcons.phone_fill,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: (value) =>
                  value!.isEmpty ? 'Por favor, insira seu telefone' : null,
                  onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
                ),
                const SizedBox(height: 18),

                _PasswordTextField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  placeholder: 'Senha',
                  showPassword: showPassword,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  onToggle: onTogglePassword,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => confirmPasswordFocusNode.requestFocus(),
                ),

                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: passwordController,
                  builder: (context, value, child) {
                    if (value.text.isNotEmpty) {
                      return _PasswordStrengthIndicator(password: value.text);
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 18),

                _PasswordTextField(
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  placeholder: 'Confirmar Senha',
                  showPassword: showConfirmPassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onToggle: onToggleConfirmPassword,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => onSignUp(),
                ),

                const SizedBox(height: 32),

                _SignUpButton(
                  isLoading: isLoading,
                  onPressed: onSignUp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final IconData icon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;

  const _CustomTextField({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
  });

  static final _fieldBg = Colors.black.withValues(alpha: 0.3);
  static final _borderColor = Colors.white.withValues(alpha: 0.1);
  static final _hintColor = Colors.white.withValues(alpha: 0.4);

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(
      fontFamily: '.SF Pro Text',
      color: Colors.white,
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: iosFont.copyWith(fontSize: 15),
      cursorColor: const Color(0xFFFF453A),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: iosFont.copyWith(color: _hintColor, fontSize: 15),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1),
        ),
        errorStyle: iosFont.copyWith(
          color: const Color(0xFFFF453A),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final bool showPassword;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;

  const _PasswordTextField({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.showPassword,
    required this.textInputAction,
    required this.onToggle,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
  });

  static final _fieldBg = Colors.black.withValues(alpha: 0.3);
  static final _borderColor = Colors.white.withValues(alpha: 0.1);
  static final _hintColor = Colors.white.withValues(alpha: 0.4);

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(
      fontFamily: '.SF Pro Text',
      color: Colors.white,
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: !showPassword,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: iosFont.copyWith(fontSize: 15),
      cursorColor: const Color(0xFFFF453A),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: iosFont.copyWith(color: _hintColor, fontSize: 15),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14, right: 10),
          child: Icon(
            CupertinoIcons.lock_fill,
            color: Colors.white70,
            size: 20,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(
              showPassword
                  ? CupertinoIcons.eye_fill
                  : CupertinoIcons.eye_slash_fill,
              color: Colors.white54,
              size: 20,
            ),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 40),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1),
        ),
        errorStyle: iosFont.copyWith(
          color: const Color(0xFFFF453A),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const _PasswordStrengthIndicator({required this.password});

  int _calculateStrength(String password) {
    if (password.isEmpty) return 0;
    if (password.length < 6) return 1;
    if (password.length < 10) return 2;
    return 3;
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0: return Colors.transparent;
      case 1: return const Color(0xFFFF453A);
      case 2: return const Color(0xFFFF9F0A);
      case 3: return const Color(0xFF32D74B);
      default: return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(
      fontFamily: '.SF Pro Text',
      color: Colors.white,
    );

    final strength = _calculateStrength(password);

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                tween: Tween<double>(begin: 0, end: strength / 3),
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStrengthColor(strength),
                    ),
                    minHeight: 4,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ['Fraca', 'Média', 'Forte'][(strength - 1).clamp(0, 2)],
            style: iosFont.copyWith(fontSize: 10, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SignUpButton({
    required this.isLoading,
    required this.onPressed,
  });

  static final _shadowColor = const Color(0xFFD32F2F).withValues(alpha: 0.4);

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(
      fontFamily: '.SF Pro Text',
      color: Colors.white,
    );

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [const Color(0xFFB71C1C), const Color(0xFFB71C1C)]
                : [const Color(0xFFD32F2F), const Color(0xFFB71C1C)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _shadowColor,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: isLoading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
          'Cadastrar',
          textAlign: TextAlign.center,
          style: iosFont.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}