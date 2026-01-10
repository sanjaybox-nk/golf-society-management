import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/season.dart';

// Mock Season Data
// Note: Since Season model is minimal, we might need to rely on the 'agmData' map for details
// or just standard fields if we updated the model. Checked model: has `agmData` map.

final archiveSeasonsProvider = Provider<List<Season>>((ref) {
  return [
    Season(
      id: '2024',
      year: 2024,
      agmData: {
        'captain': 'David Miller',
        'playerOfTheYear': 'Sanjay Patel',
        'majorWinners': ['Spring: John Smith', 'Summer: Bob Wilson', 'Autumn: James Doe'],
      },
    ),
    Season(
      id: '2023',
      year: 2023,
      agmData: {
        'captain': 'John Smith',
        'playerOfTheYear': 'David Miller',
        'majorWinners': ['Spring: Rob Taylor', 'Summer: Sanjay Patel', 'Autumn: John Smith'],
      },
    ),
    Season(
      id: '2022',
      year: 2022,
      agmData: {
        'captain': 'Bob Wilson',
        'playerOfTheYear': 'Bob Wilson',
        'majorWinners': ['Spring: TBD', 'Summer: TBD', 'Autumn: TBD'],
      },
    ),
  ];
});
