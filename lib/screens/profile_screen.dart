import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late User? _user;

  // BOILERPLATE DE STATUS
  String _role = 'DESENVOLVEDOR';
  String _phone = '+55 (11) 99999-9999';
  bool _isLoading = true;
  bool _isSaving = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // CORES JA SALVAS NO CACHE PARA EVITAR REDUNDANCIA
  static final _backButtonBg = Colors.white.withValues(alpha: 0.1);
  static final _roleBadgeBg = Colors.white.withValues(alpha: 0.1);
  static final _infoCardBg = Colors.white.withValues(alpha: 0.05);
  static final _iconBg = Colors.white.withValues(alpha: 0.1);
  static final _dialogBg = const Color(0xFF2C2C2C).withValues(alpha: 0.92);

  @override
  void initState() {
    super.initState();
    _enableHighRefreshRate();
    _user = FirebaseAuth.instance.currentUser;
    _loadUserProfile();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  // ERROR HANDLE
  Future<void> _loadUserProfile() async {
    if (_user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get()
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout ao carregar perfil'),
      );

      if (mounted) {
        if (doc.exists) {
          final data = doc.data();
          setState(() {
            _role = data?['role'] ?? 'DESENVOLVEDOR';
            _phone = data?['phone'] ?? '+55 (11) 99999-9999';
            _isLoading = false;
          });
        } else {
          await _createDefaultProfile();
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar perfil: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _createDefaultProfile() async {
    if (_user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'role': _role,
        'phone': _phone,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error creating default profile: $e");
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _enableHighRefreshRate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // suporte para tela 120hz
    });
  }

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pop(context);
  }

  // EDIT
  void _handleEdit() {
    final nameCtrl = TextEditingController(
      text: _user?.displayName ?? 'Polaris',
    );
    final roleCtrl = TextEditingController(text: _role);
    final phoneCtrl = TextEditingController(text: _phone);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => _EditProfileDialog(
        nameController: nameCtrl,
        roleController: roleCtrl,
        phoneController: phoneCtrl,
        isSaving: _isSaving,
        onSave: () async {
          if (_isSaving) return; //EVITA SALVAR DUAS VEZES A MESMA COISA

          setState(() => _isSaving = true);
          await _saveProfile(
            nameCtrl.text,
            roleCtrl.text,
            phoneCtrl.text,
          );
          setState(() => _isSaving = false);

          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> _saveProfile(String newName, String newRole, String newPhone) async {
    if (_user == null) return;

    try {
      // VALIDA OS INPUTS DO USER AO TENTAR MUDAR O NOME
      if (newName.trim().isEmpty) {
        throw Exception('Nome não pode estar vazio');
      }
      if (newRole.trim().isEmpty) {
        throw Exception('Cargo não pode estar vazio');
      }

      // UPDATE DO NOME
      final trimmedName = newName.trim();
      if (trimmedName != _user!.displayName) {
        await _user!.updateDisplayName(trimmedName);
        await _user!.reload();
        _user = FirebaseAuth.instance.currentUser;
      }

      // UPDATE NO FIREBASE
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .set({
        'role': newRole.trim(),
        'phone': newPhone.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // UPDATE LOCAL STATE (FEEDBACK)
      if (mounted) {
        setState(() {
          _role = newRole.trim();
          _phone = newPhone.trim();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(
      fontFamily: '.SF Pro Text',
      color: Colors.white,
    );

    final displayName = _user?.displayName?.isNotEmpty == true
        ? _user!.displayName!
        : 'Polaris';

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const _BackgroundGradient(),

          SafeArea(
            child: Stack(
              children: [
                // BOTAO DE VOLTAR
                Positioned(
                  left: 20,
                  top: 10,
                  child: _SimpleButton(
                    onTap: () => Navigator.pop(context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _backButtonBg,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                CupertinoIcons.chevron_back,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Voltar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: '.SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 20,
                  top: 80,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _SideActionButton(
                          label: 'Editar',
                          icon: CupertinoIcons.pencil,
                          color: Colors.blueAccent,
                          onTap: _handleEdit,
                        ),
                        const SizedBox(height: 16),
                        _SideActionButton(
                          label: 'Logout',
                          icon: CupertinoIcons.square_arrow_right,
                          color: Colors.redAccent,
                          onTap: _handleLogout,
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content
                Positioned.fill(
                  top: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _isLoading
                            ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CupertinoActivityIndicator(
                                color: Colors.white,
                                radius: 20,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Carregando perfil...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontFamily: '.SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ProfileAvatar(
                              userId: _user?.uid ?? 'default',
                            ),
                            const SizedBox(height: 30),

                            // NOME
                            Text(
                              displayName.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: iosFont.copyWith(
                                fontSize: 28,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  )
                                ],
                              ),
                            ),

                            // ABA DE CARGO
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _roleBadgeBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Text(
                                _role.toUpperCase(),
                                style: iosFont.copyWith(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),

                            const SizedBox(height: 60),

                            // Info Cards
                            _InfoCard(
                              label: 'EMAIL',
                              value: _user?.email ?? '---',
                              icon: CupertinoIcons.mail_solid,
                            ),
                            const SizedBox(height: 16),
                            _InfoCard(
                              label: 'TELEFONE',
                              value: _phone,
                              icon: CupertinoIcons.phone_fill,
                            ),
                            const SizedBox(height: 16),
                            _InfoCard(
                              label: 'UID',
                              value: _user?.uid.substring(0, 8) ?? '---',
                              icon: CupertinoIcons.barcode,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController roleController;
  final TextEditingController phoneController;
  final bool isSaving;
  final VoidCallback onSave;

  const _EditProfileDialog({
    required this.nameController,
    required this.roleController,
    required this.phoneController,
    required this.isSaving,
    required this.onSave,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  @override
  void dispose() {
    widget.nameController.dispose();
    widget.roleController.dispose();
    widget.phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Editar Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: '.SF Pro Text',
                  ),
                ),
                const SizedBox(height: 24),

                // BOTOES DE EDITAR
                _DialogTextField(
                  controller: widget.nameController,
                  hint: 'Nome',
                  icon: CupertinoIcons.person,
                ),
                const SizedBox(height: 12),
                _DialogTextField(
                  controller: widget.roleController,
                  hint: 'Cargo',
                  icon: CupertinoIcons.briefcase,
                ),
                const SizedBox(height: 12),
                _DialogTextField(
                  controller: widget.phoneController,
                  hint: 'Telefone',
                  icon: CupertinoIcons.phone,
                  type: TextInputType.phone,
                ),

                const SizedBox(height: 24),

                // BOTOES DE CANCELAR E SALVAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      onPressed: widget.isSaving
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: widget.isSaving
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: widget.isSaving ? null : widget.onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        disabledBackgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: widget.isSaving
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Text(
                        'Salvar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
    );
  }
}

// DIALOGO DO TEXT FIELD
class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType type;

  const _DialogTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// GRADIENTE DO BACKGROUND
class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8B0000), Color(0xFF110000)],
        ),
      ),
    );
  }
}

// FOTO DE PERFIL DO USER
class _ProfileAvatar extends StatelessWidget {
  final String userId;

  const _ProfileAvatar({required this.userId});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Hero(
        tag: 'current_user_avatar',
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: -5,
              ),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/images/user.png'), //NO MOMENTO USANDO UM PLACEHOLDER
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

// SIDE BUTTON
class _SideActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SideActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SimpleButton(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: '.SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  static final _cardBg = Colors.white.withValues(alpha: 0.05);
  static final _iconBg = Colors.white.withValues(alpha: 0.1);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white70, size: 20),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontFamily: '.SF Pro Text',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: '.SF Pro Text',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple button
class _SimpleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SimpleButton({
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}