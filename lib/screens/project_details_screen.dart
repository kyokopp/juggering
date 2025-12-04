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

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  // Reuse single instance
  late final ProjectService _projectService;
  late final DateFormat _dateFormat;

  // Cache computed values
  late final int _duration;
  late final Color _statusColor;
  late final String _statusLabel;

  // Animation controller for smooth transitions
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize services
    _projectService = ProjectService();
    _dateFormat = DateFormat('dd/MM/yyyy');

    // Cache computed values (calculated once)
    _duration = widget.project.endDate.difference(widget.project.startDate).inDays;
    _statusColor = _getStatusColor(widget.project.status);
    _statusLabel = _getStatusLabel(widget.project.status);

    // Setup 120Hz-ready animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350), // Smooth duration for 120Hz
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // Smooth curve for high refresh rates
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start entrance animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Note: ProjectService disposal depends on your implementation
    // If it has streams/listeners, dispose them here
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Excluir Projeto'),
        content: const Text('Tem certeza? Esta ação não pode ser desfeita.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Excluir'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await _projectService.deleteProject(widget.project.id);
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate deletion
      }
    }
  }

  Future<void> _handleEdit() async {
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
      body: Stack(
        children: [
          // Background with subtle animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
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
                      _buildHeaderButton(
                        icon: CupertinoIcons.arrow_left,
                        color: Colors.white.withValues(alpha:0.1),
                        iconColor: Colors.white,
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Detalhes do Projeto',
                        style: textStyle.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildHeaderButton(
                        icon: CupertinoIcons.pencil,
                        color: Colors.blueAccent.withValues(alpha:0.2),
                        iconColor: Colors.blueAccent,
                        onPressed: _handleEdit,
                      ),
                    ],
                  ),
                ),

                // Content with smooth animations
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
                            // Title & Status
                            _buildTitleSection(textStyle),
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
                              content: '${_dateFormat.format(widget.project.startDate)} até ${_dateFormat.format(widget.project.endDate)}\n($_duration dias estimados)',
                            ),
                            const SizedBox(height: 16),

                            // Description
                            _buildGlassCard(
                              icon: CupertinoIcons.doc_text,
                              title: 'DESCRIÇÃO',
                              content: widget.project.description,
                            ),
                            const SizedBox(height: 16),

                            // observações
                            _buildGlassCard(
                              icon: CupertinoIcons.exclamationmark_circle,
                              title: 'OBSERVAÇÕES',
                              content: widget.project.observations.isEmpty
                                  ? 'Nenhuma observação.'
                                  : widget.project.observations,
                            ),

                            const SizedBox(height: 40),

                            // delete
                            Center(
                              child: CupertinoButton(
                                onPressed: _handleDelete,
                                child: Text(
                                  'Excluir Projeto',
                                  style: textStyle.copyWith(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
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

  Widget _buildHeaderButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
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
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _statusColor),
          ),
          child: Text(
            _statusLabel,
            style: baseStyle.copyWith(
              color: _statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
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
            color: Colors.white.withValues(alpha:0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: .1),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cached color calculation
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

  // Cached label calculation
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