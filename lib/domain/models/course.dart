import 'package:cloud_firestore/cloud_firestore.dart';

class TeeConfig {
  final String name;
  final double rating;
  final int slope;
  final List<int> holePars;
  final List<int> holeSIs;
  final List<int> yardages;

  TeeConfig({
    required this.name,
    required this.rating,
    required this.slope,
    required this.holePars,
    required this.holeSIs,
    required this.yardages,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'slope': slope,
      'holePars': holePars,
      'holeSIs': holeSIs,
      'yardages': yardages,
    };
  }

  factory TeeConfig.fromMap(Map<String, dynamic> data) {
    return TeeConfig(
      name: data['name'] ?? 'Standard',
      rating: (data['rating'] as num?)?.toDouble() ?? 72.0,
      slope: (data['slope'] as num?)?.toInt() ?? 113,
      holePars: List<int>.from(data['holePars'] ?? List.filled(18, 4)),
      holeSIs: List<int>.from(data['holeSIs'] ?? List.generate(18, (i) => i + 1)),
      yardages: List<int>.from(data['yardages'] ?? List.filled(18, 0)),
    );
  }

  TeeConfig copyWith({
    String? name,
    double? rating,
    int? slope,
    List<int>? holePars,
    List<int>? holeSIs,
    List<int>? yardages,
  }) {
    return TeeConfig(
      name: name ?? this.name,
      rating: rating ?? this.rating,
      slope: slope ?? this.slope,
      holePars: holePars ?? this.holePars,
      holeSIs: holeSIs ?? this.holeSIs,
      yardages: yardages ?? this.yardages,
    );
  }
}

class Course {
  final String id;
  final String name;
  final String address;
  final List<TeeConfig> tees;
  final bool isGlobal;

  Course({
    required this.id,
    required this.name,
    required this.address,
    required this.tees,
    this.isGlobal = true,
  });

  // Legacy compatibility getters
  double get rating => tees.isEmpty ? 72.0 : tees.first.rating;
  int get slope => tees.isEmpty ? 113 : tees.first.slope;
  List<int> get holePars => tees.isEmpty ? List.filled(18, 4) : tees.first.holePars;
  List<int> get holeSIs => tees.isEmpty ? List.generate(18, (i) => i + 1) : tees.first.holeSIs;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'tees': tees.map((t) => t.toMap()).toList(),
      'isGlobal': isGlobal,
    };
  }

  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Course.fromMap(doc.id, data);
  }

  factory Course.fromMap(String id, Map<String, dynamic> data) {
    final List<dynamic> teesData = data['tees'] ?? [];
    
    // Support legacy flat format if tees list is empty
    List<TeeConfig> parsedTees = teesData.map((t) => TeeConfig.fromMap(t as Map<String, dynamic>)).toList();
    
    if (parsedTees.isEmpty && data.containsKey('rating')) {
      parsedTees = [
        TeeConfig(
          name: 'Standard',
          rating: (data['rating'] as num?)?.toDouble() ?? 72.0,
          slope: (data['slope'] as num?)?.toInt() ?? 113,
          holePars: List<int>.from(data['holePars'] ?? List.filled(18, 4)),
          holeSIs: List<int>.from(data['holeSIs'] ?? List.generate(18, (i) => i + 1)),
          yardages: List<int>.from(data['yardages'] ?? List.filled(18, 0)),
        )
      ];
    }

    return Course(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      tees: parsedTees,
      isGlobal: data['isGlobal'] ?? true,
    );
  }

  Course copyWith({
    String? id,
    String? name,
    String? address,
    List<TeeConfig>? tees,
    bool? isGlobal,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      tees: tees ?? this.tees,
      isGlobal: isGlobal ?? this.isGlobal,
    );
  }
}
