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
  final ProjectService _projectService = ProjectService();

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoColors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text('Projetos', style: iosFont.copyWith(fontWeight: FontWeight.w600)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add, color: Colors.white),
          onPressed: () => showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.7),
            builder: (context) => const ProjectDialog(),
          ),
        ),
        border: Border.all(color: Colors.transparent),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B0000), Color(0xFF220000)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<Project>>(
            stream: _projectService.getProjects(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator(color: Colors.white));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("Nenhum projeto encontrado", style: iosFont.copyWith(color: Colors.white54)));
              }

              // Group projects by status
              final ongoing = snapshot.data!.where((p) => p.status == 'ongoing').toList();
              final incoming = snapshot.data!.where((p) => p.status == 'incoming').toList();
              final finished = snapshot.data!.where((p) => p.status == 'finished').toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (ongoing.isNotEmpty) ...[
                    _buildSectionHeader('EM ANDAMENTO'),
                    ...ongoing.map((p) => _ProjectCard(project: p)),
                  ],
                  if (incoming.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader('FUTUROS'),
                    ...incoming.map((p) => _ProjectCard(project: p)),
                  ],
                  if (finished.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader('FINALIZADOS'),
                    ...finished.map((p) => _ProjectCard(project: p)),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM');
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => ProjectDetailsScreen(project: project)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getStatusColor(project.status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(project.status).withValues(alpha: 0.5)),
                    ),
                    child: Icon(CupertinoIcons.doc_text_fill, color: _getStatusColor(project.status)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: iosFont.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${project.city}, ${project.state}',
                          style: iosFont.copyWith(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Fim',
                        style: iosFont.copyWith(fontSize: 10, color: Colors.white38),
                      ),
                      Text(
                        dateFormat.format(project.endDate),
                        style: iosFont.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ongoing': return Colors.blueAccent;
      case 'incoming': return Colors.orangeAccent;
      case 'finished': return Colors.greenAccent;
      default: return Colors.white;
    }
  }
}

// --- ADD/EDIT DIALOG ---
class ProjectDialog extends StatefulWidget {
  final Project? project; // If null, create new. If exists, edit.

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
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.project == null ? 'Novo Projeto' : 'Editar Projeto',
                        style: iosFont.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      _buildTextField(_nameCtrl, 'Nome do Projeto', CupertinoIcons.doc_text),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_cityCtrl, 'Cidade', CupertinoIcons.map)),
                          const SizedBox(width: 8),
                          SizedBox(width: 80, child: _buildTextField(_stateCtrl, 'UF', CupertinoIcons.map_pin_ellipse)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(_descCtrl, 'Descrição', CupertinoIcons.text_alignleft),
                      const SizedBox(height: 12),
                      _buildTextField(_obsCtrl, 'Observações', CupertinoIcons.exclamationmark_circle, maxLines: 2),
                      const SizedBox(height: 16),

                      // Status Picker
                      CupertinoSlidingSegmentedControl<String>(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        thumbColor: Colors.redAccent,
                        groupValue: _status,
                        children: const {
                          'ongoing': Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('Andamento', style: TextStyle(color: Colors.white, fontSize: 10))),
                          'incoming': Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('Futuro', style: TextStyle(color: Colors.white, fontSize: 10))),
                          'finished': Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('Final', style: TextStyle(color: Colors.white, fontSize: 10))),
                        },
                        onValueChanged: (v) => setState(() => _status = v!),
                      ),
                      const SizedBox(height: 16),

                      // Date Buttons
                      Row(
                        children: [
                          Expanded(child: _buildDateBtn('Início', _startDate, () => _selectDate(context, true))),
                          const SizedBox(width: 10),
                          Expanded(child: _buildDateBtn('Fim', _endDate, () => _selectDate(context, false))),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CupertinoButton(
                            child: Text('Cancelar', style: iosFont.copyWith(color: Colors.white60)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            child: Text('Salvar', style: iosFont.copyWith(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              if (_nameCtrl.text.isNotEmpty && _cityCtrl.text.isNotEmpty) {
                                final p = Project(
                                  id: widget.project?.id ?? '', // ID handled by Fire service on add, or used on update
                                  name: _nameCtrl.text,
                                  city: _cityCtrl.text,
                                  state: _stateCtrl.text,
                                  startDate: _startDate,
                                  endDate: _endDate,
                                  description: _descCtrl.text,
                                  observations: _obsCtrl.text,
                                  status: _status,
                                );

                                if (widget.project == null) {
                                  ProjectService().addProject(p);
                                } else {
                                  ProjectService().updateProject(p);
                                }
                                Navigator.pop(context);
                              }
                            },
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

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDateBtn(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 4),
            Text(DateFormat('dd/MM/yy').format(date), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}