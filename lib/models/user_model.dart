class UserModel {
  final String id;
  final String name;
  final String employeeId;
  final String email;
  final String position;
  final String department;
  final String officeName;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.email,
    required this.position,
    required this.department,
    this.officeName = 'Headquarters • 3rd Floor',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'employeeId': employeeId,
      'email': email,
      'position': position,
      'department': department,
      'officeName': officeName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      employeeId: map['employeeId'] ?? '',
      email: map['email'] ?? '',
      position: map['position'] ?? '',
      department: map['department'] ?? 'Engineering',
      officeName: map['officeName'] ?? 'Headquarters • 3rd Floor',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String
              ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
              : (map['createdAt'] as dynamic).toDate())
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? employeeId,
    String? email,
    String? position,
    String? department,
    String? officeName,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      position: position ?? this.position,
      department: department ?? this.department,
      officeName: officeName ?? this.officeName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
