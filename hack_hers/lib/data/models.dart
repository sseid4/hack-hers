class Profile {
  final int? id;
  String name;
  String relationship;
  String? photoPath; // path to local image asset/file
  String? tags; // comma separated memory tags
  String? note; // voice/video placeholder

  Profile({
    this.id,
    required this.name,
    required this.relationship,
    this.photoPath,
    this.tags,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'relationship': relationship,
    'photoPath': photoPath,
    'tags': tags,
    'note': note,
  };

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map['id'] as int?,
    name: map['name'] as String,
    relationship: map['relationship'] as String,
    photoPath: map['photoPath'] as String?,
    tags: map['tags'] as String?,
    note: map['note'] as String?,
  );
}

class EventItem {
  final int? id;
  final int? profileId; // may be null for general events
  DateTime dateTime;
  String title;
  String? type; // family/medical/social
  String? notes;

  EventItem({
    this.id,
    this.profileId,
    required this.dateTime,
    required this.title,
    this.type,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'profileId': profileId,
    'dateTime': dateTime.toIso8601String(),
    'title': title,
    'type': type,
    'notes': notes,
  };

  factory EventItem.fromMap(Map<String, dynamic> map) => EventItem(
    id: map['id'] as int?,
    profileId: map['profileId'] as int?,
    dateTime: DateTime.parse(map['dateTime'] as String),
    title: map['title'] as String,
    type: map['type'] as String?,
    notes: map['notes'] as String?,
  );
}

class AppSettings {
  bool narration;
  double fontScale;
  bool aiSuggestions;
  bool faceRecognitionConsent;
  String? emergencyName;
  String? emergencyPhone;

  AppSettings({
    this.narration = false,
    this.fontScale = 1.0,
    this.aiSuggestions = true,
    this.faceRecognitionConsent = false,
    this.emergencyName,
    this.emergencyPhone,
  });

  Map<String, dynamic> toMap() => {
    'narration': narration ? 1 : 0,
    'fontScale': fontScale,
    'aiSuggestions': aiSuggestions ? 1 : 0,
    'faceRecognitionConsent': faceRecognitionConsent ? 1 : 0,
    'emergencyName': emergencyName,
    'emergencyPhone': emergencyPhone,
  };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
    narration: (map['narration'] as int? ?? 0) == 1,
    fontScale: (map['fontScale'] as num?)?.toDouble() ?? 1.0,
    aiSuggestions: (map['aiSuggestions'] as int? ?? 1) == 1,
    faceRecognitionConsent: (map['faceRecognitionConsent'] as int? ?? 0) == 1,
    emergencyName: map['emergencyName'] as String?,
    emergencyPhone: map['emergencyPhone'] as String?,
  );
}
