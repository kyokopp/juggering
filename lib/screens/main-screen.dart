import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'contacts_screen.dart';
import 'profile_screen.dart';
import '../services/contact_service.dart';
import '../services/contact_model.dart';
import 'package:juggering/screens/responsive.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isSidebarOpen = false;
  late final ContactService _contactService;
  late final Stream<List<Contact>> _favoritesStream;
  String? _cachedFirstName;

  @override
  void initState() {
    super.initState();
    _contactService = ContactService();
    _favoritesStream = _contactService.getFavoriteContacts();
    _cacheUserName();
  }

  void _cacheUserName() {
    final user = FirebaseAuth.instance.currentUser;
    _cachedFirstName = user?.displayName?.split(' ').firstOrNull ?? 'Polaris';
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final sidebarWidth = screenSize.width * 0.7;

    return Scaffold(
      body: Stack(
        children: [
          _MainContent(
            cachedFirstName: _cachedFirstName ?? 'Polaris',
            onMenuTap: _toggleSidebar,
            favoritesStream: _favoritesStream,
          ),

          // Sidebar Dim Effect
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isSidebarOpen ? 1.0 : 0.0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ),

          // Animated Sidebar
          _AnimatedSidebar(
            isOpen: _isSidebarOpen,
            width: sidebarWidth,
            screenWidth: screenSize.width,
            onClose: _toggleSidebar,
            onLogout: () {
              _toggleSidebar();
              _handleLogout(context);
            },
          ),
        ],
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final String cachedFirstName;
  final VoidCallback onMenuTap;
  final Stream<List<Contact>> favoritesStream;

  const _MainContent({
    required this.cachedFirstName,
    required this.onMenuTap,
    required this.favoritesStream,
  });

  @override
  Widget build(BuildContext context) {
    // iOS Font Style
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8B0000), Color(0xFF220000)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Container (Updated for better visibility and contrast)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey.withValues(alpha: 0.25), // Increased contrast
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profile Shortcut
                      GestureDetector(
                        onTap: () {
                          // Navigate to Profile Screen
                          Navigator.of(context).push(
                            CupertinoPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                        child: Row(
                          children: [
                            Hero(
                              tag: 'current_user_avatar',
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/user.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Olá,',
                                  style: iosFont.copyWith(fontSize: 14, color: Colors.white70),
                                ),
                                Text(
                                  cachedFirstName,
                                  style: iosFont.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: onMenuTap,
                        child: const Icon(
                          CupertinoIcons.bars,
                          color: CupertinoColors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Dashboard Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ResponsiveContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Favorites Section
                      _FavoritesSection(favoritesStream: favoritesStream),
                      const SizedBox(height: 16),
                      const _DashboardCard(
                        title: 'Próximas Tarefas',
                        content: 'Nenhuma tarefa pendente para hoje.',
                        icon: CupertinoIcons.list_bullet,
                      ),
                      const SizedBox(height: 16),
                      const _DashboardCard(
                        title: 'Notificações',
                        content: 'Você não tem novas notificações.',
                        icon: CupertinoIcons.bell,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesSection extends StatelessWidget {
  final Stream<List<Contact>> favoritesStream;

  const _FavoritesSection({required this.favoritesStream});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);

    return SizedBox(
      height: screenSize.height * 0.33,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: CupertinoColors.systemGrey2.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.heart_fill, color: CupertinoColors.systemRed, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Contatos Favoritos',
                      style: iosFont.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<List<Contact>>(
                    stream: favoritesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CupertinoActivityIndicator(color: Colors.white),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Nenhum contato favorito.',
                            style: iosFont.copyWith(color: Colors.white38),
                          ),
                        );
                      }

                      final favorites = snapshot.data!.take(3).toList();

                      return ListView.builder(
                        itemCount: favorites.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final contact = favorites[index];
                          return _FavoriteContactCard(contact: contact);
                        },
                      );
                    },
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

class _FavoriteContactCard extends StatelessWidget {
  final Contact contact;

  const _FavoriteContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white12,
            child: Icon(Icons.person, color: Colors.white70, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              contact.name,
              style: iosFont.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (contact.role.isNotEmpty)
            Text(
              contact.role,
              style: iosFont.copyWith(color: Colors.white54, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: CupertinoColors.systemGrey2.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: CupertinoColors.systemRed, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: iosFont.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: iosFont.copyWith(color: CupertinoColors.systemGrey3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSidebar extends StatelessWidget {
  final bool isOpen;
  final double width;
  final double screenWidth;
  final VoidCallback onClose;
  final VoidCallback onLogout;

  const _AnimatedSidebar({
    required this.isOpen,
    required this.width,
    required this.screenWidth,
    required this.onClose,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: isOpen ? screenWidth - width : screenWidth,
      top: 0,
      bottom: 0,
      width: width,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
              border: const Border(left: BorderSide(color: Colors.white24)),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Menu',
                          style: iosFont.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: onClose,
                          child: const Icon(
                            CupertinoIcons.xmark,
                            color: CupertinoColors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  _SidebarButton(
                    icon: CupertinoIcons.person_2,
                    label: 'Contatos',
                    onTap: () {
                      onClose();
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const ContactsScreen(),
                        ),
                      );
                    },
                  ),
                  _SidebarButton(
                    icon: CupertinoIcons.briefcase,
                    label: 'Projetos',
                    onTap: () {
                      onClose();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navegar para Projetos')),
                      );
                    },
                  ),
                  const Spacer(),
                  const Divider(color: Colors.white24),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CupertinoButton.filled(
                      onPressed: onLogout,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.square_arrow_right,
                            color: CupertinoColors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sair',
                            style: iosFont.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);

    return CupertinoButton(
      onPressed: onTap,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          Icon(icon, color: CupertinoColors.white, size: 28),
          const SizedBox(width: 16),
          Text(
            label,
            style: iosFont.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}