import 'dart:ui';
import 'responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isSidebarOpen = false;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // No explicit navigation needed, StreamBuilder in AuthApp handles it.
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenSize = MediaQuery.of(context).size;
    final sidebarWidth = screenSize.width * 0.7; // Sidebar width is 70% of screen

    return Scaffold(
      body: Stack(
        children: [
          // 1. Main Content Layer
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF8B0000), // Darker Red
                  Color(0xFF220000), // Very Dark Red/Black
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Custom Top Container
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Profile Picture Placeholder
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              // Placeholder image, replace with actual user image later
                              backgroundImage: AssetImage('assets/images/aino.jpg'),
                              backgroundColor: Colors.transparent,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Olá, ${user?.displayName?.split(' ')[0] ?? 'CleitonMaster'}',
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Sidebar Toggle Button
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _toggleSidebar,
                          child: const Icon(CupertinoIcons.bars, color: CupertinoColors.white, size: 32),
                        ),
                      ],
                    ),
                  ),

                  // Dashboard Area (Placeholder)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: ResponsiveContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDashboardCard(
                              title: 'Visão Geral do Projeto',
                              content: 'Aqui você verá um resumo dos seus projetos.',
                              icon: CupertinoIcons.graph_square,
                            ),
                            const SizedBox(height: 16),
                            _buildDashboardCard(
                              title: 'Próximas Tarefas',
                              content: 'Nenhuma tarefa pendente para hoje.',
                              icon: CupertinoIcons.list_bullet,
                            ),
                            const SizedBox(height: 16),
                            _buildDashboardCard(
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
          ),

          // 2. Dimmed Background Layer (when sidebar is open)
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar, // Close sidebar on tap outside
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isSidebarOpen ? 1.0 : 0.0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ),

          // 3. Sidebar Layer
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarOpen ? screenSize.width - sidebarWidth : screenSize.width,
            top: 0,
            bottom: 0,
            width: sidebarWidth,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey.withValues(alpha: 0.2), // Semi-transparent for blur
                    border: const Border(left: BorderSide(color: Colors.white24)),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Sidebar Header
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Menu',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: _toggleSidebar,
                                child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.white, size: 28),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.white24),

                        // Navigation Buttons
                        _buildSidebarButton(
                          icon: CupertinoIcons.person_2,
                          label: 'Contatos',
                          onTap: () {
                            // Navigate to Contacts App
                            _toggleSidebar(); // Close sidebar after navigation
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navegar para Contatos')),
                            );
                          },
                        ),
                        _buildSidebarButton(
                          icon: CupertinoIcons.briefcase,
                          label: 'Projetos',
                          onTap: () {
                            // Navigate to Projects App
                            _toggleSidebar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navegar para Projetos')),
                            );
                          },
                        ),

                        const Spacer(), // Pushes logout button to the bottom

                        // Logout Button
                        const Divider(color: Colors.white24),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CupertinoButton.filled(
                            onPressed: () {
                              _toggleSidebar();
                              _handleLogout(context);
                            },
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            borderRadius: BorderRadius.circular(10),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.square_arrow_right, color: CupertinoColors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Sair',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.white,
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
          ),
        ],
      ),
    );
  }

  // Helper for Dashboard Cards
  Widget _buildDashboardCard({required String title, required String content, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: CupertinoColors.systemGrey2.withValues(alpha: 0.3), width: 0.5),
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
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(color: CupertinoColors.systemGrey3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Sidebar Buttons
  Widget _buildSidebarButton({required IconData icon, required String label, required VoidCallback onTap}) {
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
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}