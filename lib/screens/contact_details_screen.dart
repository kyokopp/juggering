import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/contact_model.dart';
import '../services/contact_service.dart';

class ContactDetailsScreen extends StatefulWidget {
  final Contact contact;

  const ContactDetailsScreen({super.key, required this.contact});

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final ContactService _contactService;
  late Contact _currentContact;

  // Single animation controller for entrance
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static final _backButtonBg = Colors.white.withValues(alpha: 0.1);
  static final _roleBadgeBg = Colors.white.withValues(alpha: 0.1);
  static final _infoCardBg = Colors.white.withValues(alpha: 0.05);
  static final _iconBg = Colors.white.withValues(alpha: 0.1);

  @override
  void initState() {
    super.initState();

    _enableHighRefreshRate();

    _contactService = ContactService();
    _currentContact = widget.contact;

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

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _enableHighRefreshRate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void _showEditDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: _currentContact.name);
    final emailCtrl = TextEditingController(text: _currentContact.email);
    final phoneCtrl = TextEditingController(text: _currentContact.phone);
    final roleCtrl = TextEditingController(text: _currentContact.role);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => _EditContactDialog(
        nameController: nameCtrl,
        emailController: emailCtrl,
        phoneController: phoneCtrl,
        roleController: roleCtrl,
        onSave: () {
          _contactService.updateContact(
            _currentContact.id,
            nameCtrl.text,
            emailCtrl.text,
            phoneCtrl.text,
            roleCtrl.text,
          );
          setState(() {
            _currentContact = Contact(
              id: _currentContact.id,
              name: nameCtrl.text,
              email: emailCtrl.text,
              phone: phoneCtrl.text,
              role: roleCtrl.text,
              isFavorite: _currentContact.isFavorite,
            );
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteContact() {
    _contactService.deleteContact(_currentContact.id);
    Navigator.pop(context);
  }

  void _toggleFavorite() async {
    await _contactService.toggleFavorite(
      _currentContact.id,
      _currentContact.isFavorite,
    );
    setState(() {
      _currentContact = Contact(
        id: _currentContact.id,
        name: _currentContact.name,
        email: _currentContact.email,
        phone: _currentContact.phone,
        role: _currentContact.role,
        isFavorite: !_currentContact.isFavorite,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Background - const to prevent rebuilds
          const _BackgroundGradient(),

          // 2. Main Content
          SafeArea(
            child: Stack(
              children: [
                // Back Button
                Positioned(
                  left: 20,
                  top: 10,
                  child: _SimpleButton(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _backButtonBg,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white24),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Side Actions
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
                          onTap: () => _showEditDialog(context),
                        ),
                        const SizedBox(height: 16),
                        _SideActionButton(
                          label: 'Excluir',
                          icon: CupertinoIcons.trash,
                          color: Colors.redAccent,
                          onTap: _deleteContact,
                        ),
                        const SizedBox(height: 24),
                        _FavoriteToggle(
                          isFavorite: _currentContact.isFavorite,
                          onToggle: _toggleFavorite,
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ProfileAvatar(
                              contactId: _currentContact.id,
                            ),
                            const SizedBox(height: 30),

                            Text(
                              _currentContact.name.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  )
                                ],
                              ),
                            ),

                            if (_currentContact.role.isNotEmpty) ...[
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
                                  _currentContact.role.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 60),

                            _InfoCard(
                              label: 'TELEFONE',
                              value: _currentContact.phone,
                              icon: CupertinoIcons.phone_fill,
                            ),
                            const SizedBox(height: 16),
                            _InfoCard(
                              label: 'EMAIL',
                              value: _currentContact.email,
                              icon: CupertinoIcons.mail_solid,
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

class _ProfileAvatar extends StatelessWidget {
  final String contactId;

  const _ProfileAvatar({required this.contactId});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Hero(
        tag: 'avatar_$contactId',
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80000000),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/images/aino.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

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
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteToggle extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;

  const _FavoriteToggle({
    required this.isFavorite,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return _SimpleButton(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isFavorite
              ? Colors.red.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFavorite ? Colors.redAccent : Colors.white24,
            width: isFavorite ? 1.5 : 1,
          ),
        ),
        child: Icon(
          isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          color: isFavorite ? Colors.redAccent : Colors.white,
          size: 30,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '---' : value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class _EditContactDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController roleController;
  final VoidCallback onSave;

  const _EditContactDialog({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.roleController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
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
              ),
            ),
            const SizedBox(height: 24),
            _DialogTextField(
              nameController,
              'Nome',
              CupertinoIcons.person,
            ),
            const SizedBox(height: 12),
            _DialogTextField(
              roleController,
              'Cargo',
              CupertinoIcons.briefcase,
            ),
            const SizedBox(height: 12),
            _DialogTextField(
              emailController,
              'E-mail',
              CupertinoIcons.mail,
              type: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _DialogTextField(
              phoneController,
              'Telefone',
              CupertinoIcons.phone,
              type: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
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
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType type;

  const _DialogTextField(
      this.controller,
      this.hint,
      this.icon, {
        this.type = TextInputType.text,
      });

  static final _fieldBg = Colors.white.withValues(alpha: 0.05);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
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
