import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../services/event_model.dart';
import '../services/event_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with TickerProviderStateMixin {
  final EventService _eventService = EventService();
  DateTime _focusedDay = DateTime.now();

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];

    final firstWeekday = firstDay.weekday;
    for (int i = 1; i < firstWeekday; i++) {
      days.add(firstDay.subtract(Duration(days: firstWeekday - i)));
    }

    for (int i = 0; i < lastDay.day; i++) {
      days.add(firstDay.add(Duration(days: i)));
    }
    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

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
        middle: Text('Eventos', style: iosFont.copyWith(fontWeight: FontWeight.w600)),
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
          child: StreamBuilder<List<Event>>(
            stream: _eventService.getEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator(color: Colors.white));
              }

              final events = snapshot.data ?? [];
              final days = _getDaysInMonth(_focusedDay);

              return Column(
                children: [
                  _buildMonthSelector(iosFont),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Column(
                              children: [
                                _buildWeekDays(iosFont),
                                Expanded(
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(8),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 7,
                                      childAspectRatio: 0.8,
                                    ),
                                    itemCount: days.length,
                                    itemBuilder: (context, index) {
                                      final date = days[index];
                                      final isCurrentMonth = date.month == _focusedDay.month;
                                      final isToday = _isSameDay(date, DateTime.now());
                                      final dayEvents = events.where((e) => _isSameDay(e.date, date)).toList();

                                      return GestureDetector(
                                        onTap: () => _handleDayTap(date, dayEvents),
                                        child: _buildDayCell(date, isCurrentMonth, isToday, dayEvents.isNotEmpty, iosFont),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _buildMonthSelector(TextStyle font) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.chevron_left, color: Colors.white),
            onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1)),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedDay).toUpperCase(),
            style: font.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.chevron_right, color: Colors.white),
            onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays(TextStyle font) {
    final weekDays = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays.map((day) => Text(
            day,
            style: font.copyWith(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.bold)
        )).toList(),
      ),
    );
  }

  Widget _buildDayCell(DateTime date, bool isCurrentMonth, bool isToday, bool hasEvents, TextStyle font) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isToday ? Colors.redAccent.withValues(alpha: 0.8) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isToday ? null : Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: font.copyWith(
              color: isCurrentMonth ? (isToday ? Colors.white : Colors.white) : Colors.white24,
              fontSize: 16,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (hasEvents) ...[
            const SizedBox(height: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isToday ? Colors.white : Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ]
        ],
      ),
    );
  }


  void _handleDayTap(DateTime date, List<Event> events) {
    if (events.isEmpty) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.7),
        builder: (context) => EventDialog(date: date),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildEventsListSheet(date, events),
      );
    }
  }

  Widget _buildEventsListSheet(DateTime date, List<Event> events) {
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Eventos em ${DateFormat('dd/MM').format(date)}',
                style: iosFont.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...events.map((e) => GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withValues(alpha: 0.7),
                    builder: (context) => EventDialog(date: date, event: e),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.name, style: iosFont.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                            Text(e.description, style: iosFont.copyWith(fontSize: 12, color: Colors.white54)),
                          ],
                        ),
                      ),
                      const Icon(CupertinoIcons.pencil, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              )),

              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.add, size: 16),
                    const SizedBox(width: 4),
                    Text('Adicionar outro evento', style: iosFont.copyWith(fontSize: 14)),
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withValues(alpha: 0.7),
                    builder: (context) => EventDialog(date: date),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventDialog extends StatefulWidget {
  final DateTime date;
  final Event? event;

  const EventDialog({super.key, required this.date, this.event});

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _nameCtrl.text = widget.event!.name;
      _descCtrl.text = widget.event!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    const iosFont = TextStyle(fontFamily: '.SF Pro Text', color: Colors.white);
    final daysUntil = widget.date.difference(DateTime.now()).inDays;
    String timeText = daysUntil == 0
        ? 'Hoje'
        : (daysUntil > 0 ? 'Faltam $daysUntil dias' : 'Passu há ${daysUntil.abs()} dias');

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.event == null ? 'Novo Evento' : 'Editar Evento',
                      style: iosFont.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(widget.date)} • $timeText',
                      style: iosFont.copyWith(fontSize: 12, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField(_nameCtrl, 'Nome do Evento', CupertinoIcons.tag),
                    const SizedBox(height: 12),
                    _buildTextField(_descCtrl, 'Descrição', CupertinoIcons.text_alignleft, maxLines: 3),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.event != null)
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
                            onPressed: () {
                              _eventService.deleteEvent(widget.event!.id);
                              Navigator.pop(context);
                            },
                          ),
                        const Spacer(),
                        CupertinoButton(
                          child: Text('Cancelar', style: iosFont.copyWith(color: Colors.white60)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        CupertinoButton.filled(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text('Salvar', style: iosFont.copyWith(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            if (_nameCtrl.text.isNotEmpty) {
                              final e = Event(
                                id: widget.event?.id ?? '',
                                name: _nameCtrl.text,
                                date: widget.date,
                                description: _descCtrl.text,
                              );

                              if (widget.event == null) {
                                _eventService.addEvent(e);
                              } else {
                                _eventService.updateEvent(e);
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
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10, top: 12),
            child: Icon(icon, color: Colors.white54, size: 20),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}