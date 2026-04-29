enum Severity {
  healthy('Healthy'),
  mild('Mild'),
  moderate('Moderate'),
  severe('Severe');

  const Severity(this.displayName);
  final String displayName;
}

enum RecordStatus {
  improving('Improving'),
  stable('Stable'),
  worsening('Worsening'),
  recovered('Recovered');

  const RecordStatus(this.displayName);
  final String displayName;
}

enum SessionStatus {
  active('Active'),
  recovered('Recovered'),
  archived('Archived');

  const SessionStatus(this.displayName);
  final String displayName;
}

class ScanResult {
  final String id;
  final int timestamp;
  final String plantName;
  final String diagnosis;
  final Severity severity;
  final String organicTreatment;
  final String chemicalTreatment;
  final String prevention;
  final List<String> powerTips;
  final String? stressFactor;
  final String? imageUrl;
  final bool archived;
  final bool isPlant;
  final double confidence; // Added confidence field
  final String? imageHash; // Added for duplicate detection

  const ScanResult({
    required this.id,
    required this.timestamp,
    required this.plantName,
    required this.diagnosis,
    required this.severity,
    required this.organicTreatment,
    required this.chemicalTreatment,
    required this.prevention,
    required this.powerTips,
    this.stressFactor,
    this.imageUrl,
    this.archived = false,
    this.isPlant = true,
    this.confidence = 0.0, // Default confidence
    this.imageHash, // Added for duplicate detection
  });

  ScanResult copyWith({
    String? id,
    int? timestamp,
    String? plantName,
    String? diagnosis,
    Severity? severity,
    String? organicTreatment,
    String? chemicalTreatment,
    String? prevention,
    List<String>? powerTips,
    String? stressFactor,
    String? imageUrl,
    bool? archived,
    bool? isPlant,
    double? confidence,
    String? imageHash,
  }) {
    return ScanResult(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      plantName: plantName ?? this.plantName,
      diagnosis: diagnosis ?? this.diagnosis,
      severity: severity ?? this.severity,
      organicTreatment: organicTreatment ?? this.organicTreatment,
      chemicalTreatment: chemicalTreatment ?? this.chemicalTreatment,
      prevention: prevention ?? this.prevention,
      powerTips: powerTips ?? this.powerTips,
      stressFactor: stressFactor ?? this.stressFactor,
      imageUrl: imageUrl ?? this.imageUrl,
      archived: archived ?? this.archived,
      isPlant: isPlant ?? this.isPlant,
      confidence: confidence ?? this.confidence,
      imageHash: imageHash ?? this.imageHash,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'plantName': plantName,
      'diagnosis': diagnosis,
      'severity': severity.name,
      'organicTreatment': organicTreatment,
      'chemicalTreatment': chemicalTreatment,
      'prevention': prevention,
      'powerTips': powerTips,
      'stressFactor': stressFactor,
      'imageUrl': imageUrl,
      'archived': archived,
      'isPlant': isPlant,
      'confidence': confidence,
      'imageHash': imageHash,
    };
  }

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id'],
      timestamp: json['timestamp'],
      plantName: json['plantName'],
      diagnosis: json['diagnosis'],
      severity: Severity.values.firstWhere((e) => e.name == json['severity']),
      organicTreatment: json['organicTreatment'],
      chemicalTreatment: json['chemicalTreatment'],
      prevention: json['prevention'],
      powerTips: List<String>.from(json['powerTips'] ?? []),
      stressFactor: json['stressFactor'],
      imageUrl: json['imageUrl'],
      archived: json['archived'] ?? false,
      isPlant: json['isPlant'] ?? true,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      imageHash: json['imageHash'],
    );
  }
}

class DailyRecord {
  final int day;
  final int timestamp;
  final RecordStatus status;
  final String notes;
  final ScanResult? result;
  final String? imageHash; // Added for duplicate detection

  const DailyRecord({
    required this.day,
    required this.timestamp,
    required this.status,
    required this.notes,
    this.result,
    this.imageHash,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'timestamp': timestamp,
      'status': status.name,
      'notes': notes,
      'result': result?.toJson(),
      'imageHash': imageHash,
    };
  }

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      day: json['day'],
      timestamp: json['timestamp'],
      status: RecordStatus.values.firstWhere((e) => e.name == json['status']),
      notes: json['notes'],
      result: json['result'] != null ? ScanResult.fromJson(json['result']) : null,
      imageHash: json['imageHash'],
    );
  }
}

class MonitoringSession {
  final String id;
  final String plantName;
  final int startDate;
  final int currentDay;
  final SessionStatus status;
  final List<DailyRecord> dailyRecords;

  const MonitoringSession({
    required this.id,
    required this.plantName,
    required this.startDate,
    required this.currentDay,
    required this.status,
    required this.dailyRecords,
  });

  MonitoringSession copyWith({
    String? id,
    String? plantName,
    int? startDate,
    int? currentDay,
    SessionStatus? status,
    List<DailyRecord>? dailyRecords,
  }) {
    return MonitoringSession(
      id: id ?? this.id,
      plantName: plantName ?? this.plantName,
      startDate: startDate ?? this.startDate,
      currentDay: currentDay ?? this.currentDay,
      status: status ?? this.status,
      dailyRecords: dailyRecords ?? this.dailyRecords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantName': plantName,
      'startDate': startDate,
      'currentDay': currentDay,
      'status': status.name,
      'dailyRecords': dailyRecords.map((r) => r.toJson()).toList(),
    };
  }

  factory MonitoringSession.fromJson(Map<String, dynamic> json) {
    return MonitoringSession(
      id: json['id'],
      plantName: json['plantName'],
      startDate: json['startDate'],
      currentDay: json['currentDay'],
      status: SessionStatus.values.firstWhere((e) => e.name == json['status']),
      dailyRecords: (json['dailyRecords'] as List?)
          ?.map((r) => DailyRecord.fromJson(r))
          .toList() ?? [],
    );
  }
}

class AppAlert {
  final String id;
  final String title;
  final String message;
  final String severity;
  final int timestamp;

  const AppAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'severity': severity,
      'timestamp': timestamp,
    };
  }

  factory AppAlert.fromJson(Map<String, dynamic> json) {
    return AppAlert(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      severity: json['severity'],
      timestamp: json['timestamp'],
    );
  }
}
