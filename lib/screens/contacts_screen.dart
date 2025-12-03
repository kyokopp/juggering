import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/contact_model.dart';
import '../services/contact_service.dart';
import 'contact_details_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late final ContactService _contactService;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  final Set<String> _selectedContactIds = {};
  bool _isSelectionMode = false;


  static final _headerBgColor = CupertinoColors.systemGrey.withValues(alpha: 0.15);
  static final _searchBgColor = Colors.black.withValues(alpha: 0.2);
  static final _cardNormalBgColor = CupertinoColors.systemGrey.withValues(alpha: 0.1);
  static final _cardSelectedBgColor = const Color(0xFF8B0000).withValues(alpha: 0.6);
  static final _bottomBarBgColor = Colors.black.withValues(alpha: 0.6);

  @override
  void initState() {
    super.initState();
    _contactService = ContactService();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedContactIds.contains(id)) {
        _selectedContactIds.remove(id);
        if (_selectedContactIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedContactIds.add(id);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectedContactIds.clear();
      _isSelectionMode = false;
    });
  }

  void _deleteSelectedContacts() {
    if (_selectedContactIds.isNotEmpty) {
      for (var id in _selectedContactIds) {
        _contactService.deleteContact(id);
      }
      setState(() {
        _selectedContactIds.clear();
        _isSelectionMode = false;
      });
    }
  }

  void _onContactLongPress(String contactId) {
    setState(() {
      _isSelectionMode = true;
      _selectedContactIds.add(contactId);
    });
  }

  void _onContactTap(Contact contact) {
    if (_isSelectionMode) {
      _toggleSelection(contact.id);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactDetailsScreen(contact: contact),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [

          const _BackgroundGradient(),


          SafeArea(

            child: Column(
              children: [
                // a search bar
                _ContactsHeader(
                  searchController: _searchController,
                  isSelectionMode: _isSelectionMode,
                  onSearchChanged: (value) => setState(() => _searchQuery = value),
                  onCancelSelection: _cancelSelection,
                  onBack: () => Navigator.pop(context),

                ),

                // a lista de contatos
                  Expanded(
                  child: _ContactsList(
                    contactService: _contactService,
                    searchQuery: _searchQuery,
                    selectedContactIds: _selectedContactIds,
                    isSelectionMode: _isSelectionMode,
                    onContactTap: _onContactTap,
                    onContactLongPress: _onContactLongPress,
                  ),
                ),
              ],
            ),
          ),


          _BottomActionBar(
            isSelectionMode: _isSelectionMode,
            hasSelection: _selectedContactIds.isNotEmpty,
            onDelete: _deleteSelectedContacts,
            onAdd: () => _showDarkContactDialog(context),
          ),
        ],
      ),
    );
  }

  void _showDarkContactDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final roleCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _AddContactDialog(
        nameController: nameCtrl,
        emailController: emailCtrl,
        phoneController: phoneCtrl,
        roleController: roleCtrl,
        onSave: () {
          _contactService.addContact(
            nameCtrl.text,
            emailCtrl.text,
            phoneCtrl.text,
            roleCtrl.text,
          );
          Navigator.pop(context);
        },
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
          colors: [Color(0xFF8B0000), Color(0xFF220000)],
        ),
      ),
    );
  }
}


class _ContactsHeader extends StatelessWidget {
  final TextEditingController searchController;
  final bool isSelectionMode;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCancelSelection;
  final VoidCallback onBack;

  const _ContactsHeader({
    required this.searchController,
    required this.isSelectionMode,
    required this.onSearchChanged,
    required this.onCancelSelection,
    required this.onBack,
  });

  static final _headerBgColor = CupertinoColors.systemGrey.withValues(alpha: 0.15);
  static final _searchBgColor = Colors.black.withValues(alpha: 0.2);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _headerBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 0.5),
            ),
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onBack, minimumSize: Size(30, 30),
                  child: const Icon(
                    CupertinoIcons.arrow_left_circle_fill,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: _searchBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Pesquisar...',
                        hintStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(
                          CupertinoIcons.search,
                          color: Colors.white54,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (isSelectionMode)
                  TextButton(
                    onPressed: onCancelSelection,
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white12,
                    backgroundImage: AssetImage('assets/images/vopec_logo.png'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactsList extends StatelessWidget {
  final ContactService contactService;
  final String searchQuery;
  final Set<String> selectedContactIds;
  final bool isSelectionMode;
  final Function(Contact) onContactTap;
  final Function(String) onContactLongPress;

  const _ContactsList({
    required this.contactService,
    required this.searchQuery,
    required this.selectedContactIds,
    required this.isSelectionMode,
    required this.onContactTap,
    required this.onContactLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Contact>>(
      stream: contactService.getContacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(color: Colors.white),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "Nenhum contato encontrado",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        final contacts = searchQuery.isEmpty
            ? snapshot.data!
            : snapshot.data!.where((contact) {
          return contact.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
        }).toList();

        if (contacts.isEmpty) {
          return const Center(
            child: Text(
              "Nenhum resultado encontrado",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 120,
            left: 16,
            right: 16,
          ),
          itemCount: contacts.length,
          itemExtent: 95,
          cacheExtent: 500,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            final isSelected = selectedContactIds.contains(contact.id);

            return _ContactCard(
              contact: contact,
              isSelected: isSelected,
              isSelectionMode: isSelectionMode,
              onTap: () => onContactTap(contact),
              onLongPress: () => onContactLongPress(contact.id),
            );
          },
        );
      },
    );
  }
}

class _ContactCard extends StatelessWidget {
  final Contact contact;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ContactCard({
    required this.contact,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  static final _cardNormalBgColor = CupertinoColors.systemGrey.withValues(alpha: 0.1);
  static final _cardSelectedBgColor = const Color(0xFF8B0000).withValues(alpha: 0.6);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? _cardSelectedBgColor : _cardNormalBgColor,
            border: Border.all(
              color: isSelected ? Colors.redAccent : Colors.white12,
              width: isSelected ? 1.5 : 0.5,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  CupertinoIcons.person_fill,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.role.isNotEmpty ? contact.role : contact.email,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (contact.isFavorite)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              if (isSelected)
                const Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extracted bottom action bar
class _BottomActionBar extends StatelessWidget {
  final bool isSelectionMode;
  final bool hasSelection;
  final VoidCallback onDelete;
  final VoidCallback onAdd;

  const _BottomActionBar({
    required this.isSelectionMode,
    required this.hasSelection,
    required this.onDelete,
    required this.onAdd,
  });

  static final _bottomBarBgColor = Colors.black.withValues(alpha: 0.6);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: _bottomBarBgColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: CupertinoIcons.trash,
                  isEnabled: isSelectionMode && hasSelection,
                  isDestructive: true,
                  onTap: onDelete,
                ),
                Container(height: 24, width: 1, color: Colors.white24),
                _ActionButton(
                  icon: CupertinoIcons.add,
                  isEnabled: true,
                  isPrimary: true,
                  onTap: onAdd,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extracted action button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isDestructive;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.isEnabled = true,
    this.isDestructive = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: CupertinoButton(
        onPressed: isEnabled ? onTap : null,
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isPrimary
                ? Colors.white
                : (isDestructive
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.white10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isPrimary
                ? Colors.black
                : (isDestructive ? Colors.red : Colors.white),
            size: 26,
          ),
        ),
      ),
    );
  }
}

// Extracted dialog as separate widget
class _AddContactDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController roleController;
  final VoidCallback onSave;

  const _AddContactDialog({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.roleController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Novo Contato',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DialogField(nameController, 'Nome', Icons.person),
                  const SizedBox(height: 12),
                  _DialogField(roleController, 'Cargo', Icons.work),
                  const SizedBox(height: 12),
                  _DialogField(
                    emailController,
                    'E-mail',
                    Icons.email,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _DialogField(
                    phoneController,
                    'Telefone',
                    Icons.phone,
                    type: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: onSave,
                        child: const Text(
                          'Salvar',
                          style: TextStyle(color: Colors.white),
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
    );
  }
}

// Extracted dialog field
class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType type;

  const _DialogField(
      this.controller,
      this.hint,
      this.icon, {
        this.type = TextInputType.text,
      });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.black26,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}