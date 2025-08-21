/// Vehicle entity representing a vehicle in the system
/// Contains all the business logic and validation for vehicles
class Vehicle {
  final String id;
  final String licensePlate;
  final String model;
  final String brand;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userId;
  final String? lastKnownStatus;

  const Vehicle({
    required this.id,
    required this.licensePlate,
    required this.model,
    required this.brand,
    required this.isActive,
    required this.createdAt,
    required this.userId,
    this.updatedAt,
    this.lastKnownStatus,
  });

  /// Creates a copy of this vehicle with the given fields replaced with new values
  Vehicle copyWith({
    String? id,
    String? licensePlate,
    String? model,
    String? brand,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? lastKnownStatus,
  }) {
    return Vehicle(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      model: model ?? this.model,
      brand: brand ?? this.brand,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      lastKnownStatus: lastKnownStatus ?? this.lastKnownStatus,
    );
  }

  /// Returns a display name for the vehicle (brand + model)
  String get displayName => '$brand $model';

  /// Returns the status text based on active state
  String get statusText => isActive ? 'Ativo' : 'Inativo';

  /// Validates if the license plate format is valid for Brazilian plates
  bool get hasValidLicensePlate {
    // Brazilian license plate patterns:
    // Old format: ABC1234 (3 letters + 4 numbers)
    // New format: ABC1D23 (3 letters + 1 number + 1 letter + 2 numbers)
    final oldPattern = RegExp(r'^[A-Z]{3}[0-9]{4}$');
    final newPattern = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');

    final cleanPlate =
        licensePlate.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return oldPattern.hasMatch(cleanPlate) || newPattern.hasMatch(cleanPlate);
  }

  /// Returns formatted license plate with dash (ABC-1234 or ABC-1D23)
  String get formattedLicensePlate {
    final cleanPlate =
        licensePlate.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleanPlate.length == 7) {
      return '${cleanPlate.substring(0, 3)}-${cleanPlate.substring(3)}';
    }
    return licensePlate;
  }

  /// Checks if the vehicle was recently created (within last 24 hours)
  bool get isRecentlyCreated {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Checks if the vehicle was recently updated (within last hour)
  bool get isRecentlyUpdated {
    if (updatedAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(updatedAt!);
    return difference.inHours < 1;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Vehicle &&
        other.id == id &&
        other.licensePlate == licensePlate &&
        other.model == model &&
        other.brand == brand &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.userId == userId &&
        other.lastKnownStatus == lastKnownStatus;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      licensePlate,
      model,
      brand,
      isActive,
      createdAt,
      updatedAt,
      userId,
      lastKnownStatus,
    );
  }

  @override
  String toString() {
    return 'Vehicle('
        'id: $id, '
        'licensePlate: $licensePlate, '
        'model: $model, '
        'brand: $brand, '
        'isActive: $isActive, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'userId: $userId, '
        'lastKnownStatus: $lastKnownStatus'
        ')';
  }

  /// Converts the vehicle to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'model': model,
      'brand': brand,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'userId': userId,
      'lastKnownStatus': lastKnownStatus,
    };
  }

  /// Creates a vehicle from a map
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      model: map['model'] ?? '',
      brand: map['brand'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      userId: map['userId'] ?? '',
      lastKnownStatus: map['lastKnownStatus'],
    );
  }
}
