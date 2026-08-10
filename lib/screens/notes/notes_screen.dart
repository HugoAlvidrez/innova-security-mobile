import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/notes_provider.dart';
import '../../theme/app_theme.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas y Calendario'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.sticky_note_2_outlined), text: 'Notas'),
            Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Calendario'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _NotesTab(),
          _CalendarTab(),
        ],
      ),
    );
  }
}

// ─── Notes Tab ─────────────────────────────────────────────────────────────────

class _NotesTab extends StatelessWidget {
  const _NotesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (_, provider, __) {
        final notes = provider.notes;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: notes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sticky_note_2_outlined,
                          size: 56, color: AppColors.textHint),
                      SizedBox(height: 12),
                      Text('Sin notas aún',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (_, i) => _NoteCard(
                    note: notes[i],
                    onEdit: () => _showNoteDialog(context, note: notes[i]),
                    onDelete: () => provider.deleteNote(notes[i].id),
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: () => _showNoteDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showNoteDialog(BuildContext context, {NoteModel? note}) {
    final titleCtrl = TextEditingController(text: note?.title ?? '');
    final contentCtrl = TextEditingController(text: note?.content ?? '');
    final colors = [
      '#FFE8E8', '#E3F2FD', '#E8F5E9', '#FFF9C4', '#F3E5F5', '#FFF3E0'
    ];
    String selectedColor = note?.colorHex ?? colors.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note == null ? 'Nueva nota' : 'Editar nota',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(labelText: 'Contenido'),
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              const Text('Color',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(
                children: colors
                    .map((c) => GestureDetector(
                          onTap: () => setModalState(() => selectedColor = c),
                          child: Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _hexToColor(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == c
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) return;
                      final prov = context.read<NotesProvider>();
                      if (note == null) {
                        prov.addNote(
                          titleCtrl.text.trim(),
                          contentCtrl.text.trim(),
                          selectedColor,
                        );
                      } else {
                        prov.updateNote(
                          note.id,
                          titleCtrl.text.trim(),
                          contentCtrl.text.trim(),
                        );
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(note == null ? 'Agregar' : 'Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        decoration: BoxDecoration(
          color: _hexToColor(note.colorHex),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _hexToColor(note.colorHex).withOpacity(0.3), width: 1.5),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('¿Eliminar nota?'),
                      content: Text('Se eliminará "${note.title}"'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emergency),
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  ),
                  child: const Icon(Icons.more_vert,
                      size: 16, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                note.content,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Calendar Tab ──────────────────────────────────────────────────────────────

class _CalendarTab extends StatefulWidget {
  const _CalendarTab();

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (_, provider, __) {
        final todayAppts = provider.getAppointmentsForDay(_selectedDay);
        final markedDays = provider.appointmentDays;

        return Column(
          children: [
            // ── Simple calendar grid ───────────────────────────────────
            _SimpleCalendar(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              markedDays: markedDays,
              onDaySelected: (day) =>
                  setState(() => _selectedDay = day),
              onPageChanged: (day) =>
                  setState(() => _focusedDay = day),
            ),

            const Divider(height: 1),

            // ── Day appointments ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Nueva cita'),
                          onPressed: () =>
                              _showAddAppointment(context, _selectedDay),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: todayAppts.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin citas para este día',
                              style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 14),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            itemCount: todayAppts.length,
                            itemBuilder: (_, i) =>
                                _AppointmentCard(
                                    appointment: todayAppts[i]),
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddAppointment(BuildContext context, DateTime day) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nueva cita',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty) return;
                  context.read<NotesProvider>().addAppointment(
                    AppointmentModel(
                      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      dateTime: day.copyWith(hour: 10),
                      agentName: 'Por confirmar',
                      isConfirmed: false,
                      isReminder: false,
                    ),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Agregar cita'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Simple Calendar ──────────────────────────────────────────────────────────

class _SimpleCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Set<DateTime> markedDays;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  const _SimpleCalendar({
    required this.focusedDay,
    required this.selectedDay,
    required this.markedDays,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth =
        DateTime(focusedDay.year, focusedDay.month, 1);
    final daysInMonth =
        DateTime(focusedDay.year, focusedDay.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7;
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onPageChanged(DateTime(
                    focusedDay.year, focusedDay.month - 1)),
              ),
              Text(
                '${months[focusedDay.month - 1]} ${focusedDay.year}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onPageChanged(DateTime(
                    focusedDay.year, focusedDay.month + 1)),
              ),
            ],
          ),
          // Day labels
          const Row(
            children: [
              _DayLabel('Dom'), _DayLabel('Lun'), _DayLabel('Mar'),
              _DayLabel('Mié'), _DayLabel('Jue'), _DayLabel('Vie'),
              _DayLabel('Sáb'),
            ],
          ),
          const SizedBox(height: 4),
          // Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, childAspectRatio: 1),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (_, index) {
              if (index < startWeekday) return const SizedBox.shrink();
              final day = index - startWeekday + 1;
              final date = DateTime(focusedDay.year, focusedDay.month, day);
              final isSelected = date.day == selectedDay.day &&
                  date.month == selectedDay.month &&
                  date.year == selectedDay.year;
              final isToday = date.day == DateTime.now().day &&
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;
              final hasEvent = markedDays
                  .any((d) => d.day == day && d.month == focusedDay.month);

              return GestureDetector(
                onTap: () => onDaySelected(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primarySurface
                            : null,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                        ),
                      ),
                      if (hasEvent && !isSelected)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String text;
  const _DayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

// ─── Appointment Card ─────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: appointment.isConfirmed
                ? AppColors.primarySurface
                : AppColors.warningLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            appointment.isReminder ? Icons.alarm : Icons.event,
            color: appointment.isConfirmed
                ? AppColors.primary
                : AppColors.warning,
            size: 20,
          ),
        ),
        title: Text(
          appointment.title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (appointment.description.isNotEmpty)
              Text(
                appointment.description,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 2),
            Text(
              '${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')} – ${appointment.agentName}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.primaryAccent),
            ),
          ],
        ),
        trailing: appointment.isConfirmed
            ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
            : const Icon(Icons.schedule, color: AppColors.warning, size: 20),
      ),
    );
  }
}
