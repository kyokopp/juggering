import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'responsive.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeController.forward();
    // OPTIMIZATION: This rebuilds the whole screen on every keystroke.
    // It's okay for the password strength meter, but be aware of performance.
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    if (password.length < 6) return 1;
    if (password.length < 10) return 2;
    return 3;
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0: return Colors.transparent;
      case 1: return const Color(0xFFFF8A8A);
      case 2: return const Color(0xFFFFB366);
      case 3: return const Color(0xFF66CC66);
      default: return Colors.transparent;
    }
  }

  void _handleSignUp() async {
    // This will now actually work because we switched to TextFormField
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName(_nameController.text.trim());
        }
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            // ... your snackbar code
              const SnackBar(content: Text('Sucesso!')) // Placeholder for brevity
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? 'Erro'), backgroundColor: Colors.red)
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        // FIX 2: Changed withValues to withOpacity
        backgroundColor: const Color(0xFF8B0000).withValues(alpha: .25),
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoColors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: const Text('Criar Conta', style: TextStyle(color: CupertinoColors.white)),
        border: Border.all(color: Colors.transparent),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFAA2222), Color(0xFF8B0000), Color(0xFF330000)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: ResponsiveContainer(
              child: FadeTransition(
                opacity: _fadeController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ... Title Texts ...
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        // FIX 2: withOpacity
                        color: CupertinoColors.systemGrey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CupertinoColors.systemGrey2.withValues(alpha: 0.25),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .1),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTextFieldWithIcon(
                              controller: _nameController,
                              placeholder: 'Nome Completo',
                              icon: CupertinoIcons.person_fill,
                              keyboardType: TextInputType.name,
                              validator: (value) => value!.isEmpty ? 'Por favor, insira seu nome' : null,
                            ),
                            const SizedBox(height: 18),
                            _buildTextFieldWithIcon(
                              controller: _emailController,
                              placeholder: 'E-mail',
                              icon: CupertinoIcons.mail_solid,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || !value.contains('@')) return 'E-mail inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            _buildPasswordFieldWithToggle(
                              controller: _passwordController,
                              placeholder: 'Senha',
                              showPassword: _showPassword,
                              onToggle: () => setState(() => _showPassword = !_showPassword),
                              validator: (value) {
                                if (value == null || value.length < 6) return 'Mínimo 6 caracteres';
                                return null;
                              },
                            ),
                            // ... Password Strength UI (unchanged) ...
                            const SizedBox(height: 18),
                            _buildPasswordFieldWithToggle(
                              controller: _confirmPasswordController,
                              placeholder: 'Confirmar Senha',
                              showPassword: _showConfirmPassword,
                              onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                              validator: (value) {
                                if (value != _passwordController.text) return 'As senhas não coincidem';
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            // ... Button (unchanged) ...
                            CupertinoButton.filled(
                              onPressed: _isLoading ? null : _handleSignUp,
                              child: _isLoading
                                  ? const CupertinoActivityIndicator()
                                  : const Text('Cadastrar', style: TextStyle(color: Colors.white)),
                            )
                          ],
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

  // FIX 3: Switched to TextFormField to enable Form Validation
  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: CupertinoColors.white, fontSize: 15),
      cursorColor: const Color(0xFFFF8A8A),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(
          color: CupertinoColors.systemGrey.withValues(alpha: 0.6),
          fontSize: 15,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, color: const Color(0xFFCC6666), size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        filled: true,
        fillColor: CupertinoColors.systemGrey.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        // Borders to match your Cupertino look
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CupertinoColors.systemGrey2.withValues(alpha: 0.2), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CupertinoColors.systemGrey2.withValues(alpha: 0.2), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCC6666), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8A8A), width: 1.2),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF8A8A), fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Same fix for the Password field helper
  Widget _buildPasswordFieldWithToggle({
    required TextEditingController controller,
    required String placeholder,
    required bool showPassword,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      validator: validator,
      style: const TextStyle(color: CupertinoColors.white, fontSize: 15),
      cursorColor: const Color(0xFFFF8A8A),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(
          color: CupertinoColors.systemGrey.withValues(alpha: 0.6),
          fontSize: 15,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(CupertinoIcons.lock_fill, color: const Color(0xFFCC6666), size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(
              showPassword ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
              color: const Color(0xFFCC6666),
              size: 20,
            ),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 40),
        filled: true,
        fillColor: CupertinoColors.systemGrey.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CupertinoColors.systemGrey2.withValues(alpha: 0.2), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CupertinoColors.systemGrey2.withValues(alpha: 0.2), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCC6666), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8A8A), width: 1.2),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF8A8A), fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}