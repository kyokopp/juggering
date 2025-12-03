import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../services/project_model.dart';
import '../services/project_service.dart';
import 'package:juggering/screens/projects_screens.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final ProjectService _projectService = ProjectService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  void _handleDelete() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Excluir Projeto'),
        content: const Text('Tem certeza? Esta ação não pode ser desfeita.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Excluir'),
            onPressed: () {
              _projectService.deleteProject(widget.project.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);

    //calcula quanto tempo o projeto vai durar
    final duration = widget.project.endDate.difference(widget.project.startDate).inDays;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8B0000), Color(0xFF110000)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Detalhes do Projeto',
                        style: iosFont.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {

                          showDialog(
                            context: context,
                            barrierColor: Colors.black.withValues(alpha: 0.7),
                            builder: (context) => ProjectDialog(project: widget.project),
                          ).then((_) {

                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(CupertinoIcons.pencil, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Status
                        Text(
                          widget.project.name.toUpperCase(),
                          style: iosFont.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.project.status).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _getStatusColor(widget.project.status)),
                          ),
                          child: Text(
                            _getStatusLabel(widget.project.status),
                            style: iosFont.copyWith(
                                color: _getStatusColor(widget.project.status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Location Card
                        _buildGlassCard(
                          icon: CupertinoIcons.location_solid,
                          title: 'LOCALIZAÇÃO',
                          content: '${widget.project.city} - ${widget.project.state}',
                        ),
                        const SizedBox(height: 16),

                        // Dates Card
                        _buildGlassCard(
                          icon: CupertinoIcons.calendar,
                          title: 'CRONOGRAMA',
                          content: '${_dateFormat.format(widget.project.startDate)} até ${_dateFormat.format(widget.project.endDate)}\n($duration dias estimados)',
                        ),
                        const SizedBox(height: 16),

                        // Description
                        _buildGlassCard(
                          icon: CupertinoIcons.doc_text,
                          title: 'DESCRIÇÃO',
                          content: widget.project.description,
                        ),
                        const SizedBox(height: 16),

                        // Observations
                        _buildGlassCard(
                          icon: CupertinoIcons.exclamationmark_circle,
                          title: 'OBSERVAÇÕES',
                          content: widget.project.observations.isEmpty ? 'Nenhuma observação.' : widget.project.observations,
                        ),

                        const SizedBox(height: 40),

                        // Delete Button
                        Center(
                          child: CupertinoButton(
                            onPressed: _handleDelete,
                            child: Text(
                              'Excluir Projeto',
                              style: iosFont.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      ],
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

  Widget _buildGlassCard({required IconData icon, required String title, required String content}) {
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(title, style: iosFont.copyWith(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 12),
              Text(content, style: iosFont.copyWith(fontSize: 16, height: 1.4)),
            ],
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

  String _getStatusLabel(String status) {
    switch (status) {
      case 'ongoing': return 'EM ANDAMENTO';
      case 'incoming': return 'EM BREVE';
      case 'finished': return 'FINALIZADO';
      default: return status.toUpperCase();
    }
  }
}