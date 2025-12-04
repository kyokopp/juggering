import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../services/project_model.dart';
import '../services/project_service.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late final ProjectService _projectService;

  @override
  void initState() {
    super.initState();
    _projectService = ProjectService();
    _enableHighRefreshRate();
  }

  void _enableHighRefreshRate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => const ProjectDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(
      fontFamily: '.SF Pro Text',
      color: Colors.white,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoColors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text(
          'Projetos',
          style: iosFont.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showAddProjectDialog,
          child: const Icon(CupertinoIcons.add, color: Colors.white),
        ),
        border: Border.all(color: Colors.transparent),
      ),
      body: const _BackgroundGradient(
        child: SafeArea(
          child: _ProjectsList(),
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
          colors: [Color(0xFF8B0000), Color(0xFF220000)],
        ),
      ),
      child: child,
    );
  }
}

class _ProjectsList extends StatelessWidget {
  const _ProjectsList();

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(
      fontFamily: '.SF Pro Text',
      color: Colors.white,
    );

    return StreamBuilder<List<Project>>(
      stream: ProjectService().getProjects(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(color: Colors.white),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "Nenhum projeto encontrado",
              style: iosFont.copyWith(color: Colors.white54),
            ),
          );
        }

        final ongoing = snapshot.data!
            .where((p) => p.status == 'ongoing')
            .toList();
        final incoming = snapshot.data!
            .where((p) => p.status == 'incoming')
            .toList();
        final finished = snapshot.data!
            .where((p) => p.status == 'finished')
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (ongoing.isNotEmpty) ...[
              const _SectionHeader(title: 'EM ANDAMENTO'),
              ...ongoing.map((p) => _ProjectCard(project: p)),
            ],
            if (incoming.isNotEmpty) ...[
              const SizedBox(height: 24),
              const _SectionHeader(title: 'FUTUROS'),
              ...incoming.map((p) => _ProjectCard(project: p)),
            ],
            if (finished.isNotEmpty) ...[
              const SizedBox(height: 24),
              const _SectionHeader(title: 'FINALIZADOS'),
              ...finished.map((p) => _ProjectCard(project: p)),
            ],
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: '.SF Pro Text',
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  static final _cardBg = Colors.white.withValues(alpha: 0.1);
  static final _borderColor = Colors.white.withValues(alpha: 0.1);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM');
    const iosFont = TextStyle(
      fontFamily: '.SF Pro Text',
      color: Colors.white,
    );

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => ProjectDetailsScreen(project: project),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _ProjectIcon(status: project.status),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: iosFont.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${project.city}, ${project.state}',
                          style: iosFont.copyWith(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Fim',
                        style: iosFont.copyWith(
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                      Text(
                        dateFormat.format(project.endDate),
                        style: iosFont.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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

class _ProjectIcon extends StatelessWidget {
  final String status;

  const _ProjectIcon({required this.status});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ongoing':
        return Colors.blueAccent;
      case 'incoming':
        return Colors.orangeAccent;
      case 'finished':
        return Colors.greenAccent;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Icon(
        CupertinoIcons.doc_text_fill,
        color: color,
      ),
    );
  }
}

class ProjectDialog extends StatefulWidget {
  final Project? project;

  const ProjectDialog({super.key, this.project});

  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _status = 'ongoing';

  static final _dialogBg = const Color(0xFF2C2C2C).withValues(alpha: 0.92);
  static final _borderColor = Colors.white.withValues(alpha: 0.1);
  static final _fieldBg = Colors.white.withValues(alpha: 0.05);
  static final _segmentBg = Colors.white.withValues(alpha: 0.1);

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      final p = widget.project!;
      _nameCtrl.text = p.name;
      _cityCtrl.text = p.city;
      _stateCtrl.text = p.state;
      _descCtrl.text = p.description;
      _obsCtrl.text = p.observations;
      _startDate = p.startDate;
      _endDate = p.endDate;
      _status = p.status;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _descCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.redAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF2C2C2C),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _handleSave() {
    if (_nameCtrl.text.trim().isEmpty || _cityCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome e Cidade são obrigatórios'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final p = Project(
      id: widget.project?.id ?? '',
      name: _nameCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      description: _descCtrl.text.trim(),
      observations: _obsCtrl.text.trim(),
      status: _status,
    );

    if (widget.project == null) {
      ProjectService().addProject(p);
    } else {
      ProjectService().updateProject(p);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(
      fontFamily: '.SF Pro Text',
      color: Colors.white,
    );

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: 340,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _dialogBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.project == null
                            ? 'Novo Projeto'
                            : 'Editar Projeto',
                        style: iosFont.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _DialogTextField(
                        controller: _nameCtrl,
                        hint: 'Nome do Projeto',
                        icon: CupertinoIcons.doc_text,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DialogTextField(
                              controller: _cityCtrl,
                              hint: 'Cidade',
                              icon: CupertinoIcons.map,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: _DialogTextField(
                              controller: _stateCtrl,
                              hint: 'UF',
                              icon: CupertinoIcons.map_pin_ellipse,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _DialogTextField(
                        controller: _descCtrl,
                        hint: 'Descrição',
                        icon: CupertinoIcons.text_alignleft,
                      ),
                      const SizedBox(height: 12),
                      _DialogTextField(
                        controller: _obsCtrl,
                        hint: 'Observações',
                        icon: CupertinoIcons.exclamationmark_circle,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      CupertinoSlidingSegmentedControl<String>(
                        backgroundColor: _segmentBg,
                        thumbColor: Colors.redAccent,
                        groupValue: _status,
                        children: const {
                          'ongoing': Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'Andamento',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          'incoming': Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'Futuro',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          'finished': Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'Final',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        },
                        onValueChanged: (v) => setState(() => _status = v!),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _DateButton(
                              label: 'Início',
                              date: _startDate,
                              onTap: () => _selectDate(context, true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DateButton(
                              label: 'Fim',
                              date: _endDate,
                              onTap: () => _selectDate(context, false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CupertinoButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancelar',
                              style: iosFont.copyWith(color: Colors.white60),
                            ),
                          ),
                          CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            onPressed: _handleSave,
                            child: Text(
                              'Salvar',
                              style: iosFont.copyWith(
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
          ),
        ),
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _DialogTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  static final _fieldBg = Colors.white.withValues(alpha: 0.05);
  static final _borderColor = Colors.white.withValues(alpha: 0.1);
  static final _hintColor = Colors.white.withValues(alpha: 0.3);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: _hintColor),
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

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  static final _buttonBg = Colors.white.withValues(alpha: 0.05);
  static final _borderColor = Colors.white.withValues(alpha: 0.1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _buttonBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yy').format(date),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}