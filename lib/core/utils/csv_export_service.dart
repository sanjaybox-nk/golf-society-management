import 'dart:ui';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../features/events/domain/registration_logic.dart';
import '../../models/golf_event.dart';

class CsvExportService {
  static Future<void> exportRegistrations({
    required GolfEvent event,
    required List<RegistrationItem> participants,
    required List<RegistrationItem> dinnerOnly,
    Rect? sharePositionOrigin,
  }) async {
    final List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Name',
      'Type',
      'Status',
      'Golf',
      'Buggy',
      'Dinner',
      'Paid',
      'Registered At',
    ]);

    // Data Row Generator
    void addRow(RegistrationItem item, String statusLabel) {
      rows.add([
        item.name,
        item.isGuest ? 'Guest' : 'Member',
        statusLabel,
        item.registration.attendingGolf ? 'Yes' : 'No',
        item.needsBuggy ? 'Yes' : 'No',
        (item.isGuest ? item.registration.guestAttendingDinner : item.registration.attendingDinner) ? 'Yes' : 'No',
        item.hasPaid ? 'Yes' : 'No',
        DateFormat('yyyy-MM-dd HH:mm').format(item.registeredAt),
      ]);
    }

    // 1. Process Participants (sorted as in UI)
    for (int i = 0; i < participants.length; i++) {
        final item = participants[i];
        final status = RegistrationLogic.calculateStatus(
          isGuest: item.isGuest, 
          registeredAt: item.registeredAt, 
          hasPaid: item.hasPaid, 
          indexInList: i, 
          capacity: event.maxParticipants ?? 999, 
          deadline: event.registrationDeadline
        );
        addRow(item, status.name.toUpperCase());
    }

    // 2. Process Dinner Only
    for (final item in dinnerOnly) {
      addRow(item, 'DINNER');
    }

    // Generate CSV String
    String csvData = const ListToCsvConverter().convert(rows);

    // Share/Save the file
    final dateStr = DateFormat('yyyyMMdd').format(event.date);
    final fileName = 'Registrations_${event.title.replaceAll(' ', '_')}_$dateStr.csv';
    
    await Share.shareXFiles(
      [XFile.fromData(
        Uint8List.fromList(csvData.codeUnits), 
        name: fileName,
        mimeType: 'text/csv',
      )], 
      subject: 'Registrations for ${event.title}',
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
