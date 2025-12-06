import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final ProjectService _projectService;
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  late final int _duration;
  late final Color _statusColor;
  late final String _statusLabel;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _projectService = ProjectService();

    _duration = widget.project.endDate.difference(widget.project.startDate).inDays;
    _statusColor = _getStatusColor(widget.project.status);
    _statusLabel = _getStatusLabel(widget.project.status);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    HapticFeedback.heavyImpact();
    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Excluir Projeto'),
        content: const Text("Tem certeza? Esta ação não pode ser desfeita."),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      try {
        await _projectService.deleteProject(widget.project.id);
        if (mounted) {
          HapticFeedback.mediumImpact();
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          HapticFeedback.vibrate();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleEdit() async {
    HapticFeedback.selectionClick();
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => ProjectDialog(project: widget.project),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderButton(
                          icon: CupertinoIcons.arrow_left,
                          color: Colors.white.withValues(alpha: 0.1),
                          iconColor: Colors.white,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          'Detalhes do Projeto',
                          style: textStyle.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily: '.SF Pro Text',
                          ),
                        ),
                        _buildHeaderButton(
                          icon: CupertinoIcons.pencil,
                          color: Colors.blueAccent.withValues(alpha: 0.2),
                          iconColor: Colors.blueAccent,
                          onPressed: _handleEdit,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitleSection(textStyle),
                              const SizedBox(height: 30),

                              _buildGlassCard(
                                icon: CupertinoIcons.location_solid,
                                title: 'LOCALIZAÇÃO',
                                content: '${widget.project.city} - ${widget.project.state}',
                              ),
                              const SizedBox(height: 16),

                              _buildGlassCard(
                                icon: CupertinoIcons.calendar,
                                title: 'CRONOGRAMA',
                                content: '${_dateFormat.format(widget.project.startDate)} até ${_dateFormat.format(widget.project.endDate)}\n($_duration dias estimados)',
                              ),
                              const SizedBox(height: 16),

                              _buildGlassCard(
                                icon: CupertinoIcons.doc_text,
                                title: 'DESCRIÇÃO',
                                content: widget.project.description,
                              ),
                              const SizedBox(height: 16),

                              _buildGlassCard(
                                icon: CupertinoIcons.exclamationmark_circle,
                                title: 'OBSERVAÇÕES',
                                content: widget.project.observations.isEmpty
                                    ? 'Nenhuma observação.'
                                    : widget.project.observations,
                              ),

                              const SizedBox(height: 40),

                              Center(
                                child: CupertinoButton(
                                  onPressed: _handleDelete,
                                  child: Text(
                                    'Excluir Projeto',
                                    style: textStyle.copyWith(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed, minimumSize: Size(0, 0),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildTitleSection(TextStyle baseStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'project_title_${widget.project.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              widget.project.name.toUpperCase(),
              style: baseStyle.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: '.SF Pro Display',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _statusColor.withValues(alpha: 0.5)),
          ),
          child: Text(
            _statusLabel,
            style: baseStyle.copyWith(
              color: _statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    const textStyle = TextStyle(color: Colors.white);

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
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: textStyle.copyWith(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: '.SF Pro Text',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: textStyle.copyWith(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontFamily: '.SF Pro Text',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ongoing':
        return const Color(0xFF0A84FF);
      case 'incoming':
        return const Color(0xFFFF9F0A);
      case 'finished':
        return const Color(0xFF32D74B);
      default:
        return Colors.white;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'ongoing':
        return 'EM ANDAMENTO';
      case 'incoming':
        return 'EM BREVE';
      case 'finished':
        return 'FINALIZADO';
      default:
        return status.toUpperCase();
    }
  }
}