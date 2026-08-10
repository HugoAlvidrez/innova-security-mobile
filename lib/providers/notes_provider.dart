import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

class NotesProvider extends ChangeNotifier {
  List<NoteModel> _notes = MockData.notes;
  List<AppointmentModel> _appointments = List.from(MockData.appointments);

  List<NoteModel> get notes => _notes;
  List<AppointmentModel> get appointments => _appointments;

  List<AppointmentModel> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments
        .where((a) => a.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<AppointmentModel> getAppointmentsForDay(DateTime day) {
    return _appointments.where((a) {
      return a.dateTime.year == day.year &&
          a.dateTime.month == day.month &&
          a.dateTime.day == day.day;
    }).toList();
  }

  Set<DateTime> get appointmentDays {
    return _appointments
        .map((a) => DateTime(a.dateTime.year, a.dateTime.month, a.dateTime.day))
        .toSet();
  }

  // ─── Notes CRUD ────────────────────────────────────────────────────────────

  void addNote(String title, String content, String colorHex) {
    _notes = [
      NoteModel(
        id: 'note_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        colorHex: colorHex,
      ),
      ..._notes,
    ];
    notifyListeners();
  }

  void updateNote(String id, String title, String content) {
    final note = _notes.firstWhere((n) => n.id == id);
    note.title = title;
    note.content = content;
    note.updatedAt = DateTime.now();
    notifyListeners();
  }

  void deleteNote(String id) {
    _notes = _notes.where((n) => n.id != id).toList();
    notifyListeners();
  }

  // ─── Appointments ──────────────────────────────────────────────────────────

  void addAppointment(AppointmentModel appointment) {
    _appointments = [..._appointments, appointment]
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    notifyListeners();
  }

  void deleteAppointment(String id) {
    _appointments = _appointments.where((a) => a.id != id).toList();
    notifyListeners();
  }
}
