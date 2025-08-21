import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vehicle.dart';

/// Vehicle model for data layer with Firebase serialization
/// Handles conversion between Firestore documents and Vehicle entities
class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.licensePlate,
    required super.model,
    required super.brand,
    required super.isActive,
    required super.createdAt,
    required super.userId,
    super.lastKnownStatus,
  });

  /// Creates a VehicleModel from a Vehicle entity
  factory VehicleModel.fromEntity(Vehicle vehicle) {
    return VehicleModel(
      id: vehicle.id,
      licensePlate: vehicle.licensePlate,
      model: vehicle.model,
      brand: vehicle.brand,
      isActive: vehicle.isActive,
      createdAt: vehicle.createdAt,
      userId: vehicle.userId,
      lastKnownStatus: vehicle.lastKnownStatus,
    );
  }

  /// Creates a VehicleModel from Firestore document
  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return VehicleModel(
      id: doc.id,
      licensePlate: data['licensePlate'] as String,
      model: data['model'] as String,
      brand: data['brand'] as String,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] as String,
      lastKnownStatus: data['lastKnownStatus'] as String?,
    );
  }

  /// Creates a VehicleModel from JSON map
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      licensePlate: json['licensePlate'] as String,
      model: json['model'] as String,
      brand: json['brand'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
      lastKnownStatus: json['lastKnownStatus'] as String?,
    );
  }

  /// Converts VehicleModel to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'licensePlate': licensePlate,
      'model': model,
      'brand': brand,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'lastKnownStatus': lastKnownStatus,
      'updatedAt': Timestamp.now(),
    };
  }

  /// Converts VehicleModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'model': model,
      'brand': brand,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'lastKnownStatus': lastKnownStatus,
    };
  }

  /// Creates a copy with updated fields
  @override
  VehicleModel copyWith({
    String? id,
    String? licensePlate,
    String? model,
    String? brand,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastKnownStatus,
    String? userId,
  }) {
    // updatedAt is not used in VehicleModel constructor, but included for compatibility
    return VehicleModel(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      model: model ?? this.model,
      brand: brand ?? this.brand,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastKnownStatus: lastKnownStatus ?? this.lastKnownStatus,
      userId: userId ?? this.userId,
    );
  }

  /// Converts to Vehicle entity
  Vehicle toEntity() {
    return Vehicle(
      id: id,
      licensePlate: licensePlate,
      model: model,
      brand: brand,
      isActive: isActive,
      createdAt: createdAt,
      userId: userId,
      lastKnownStatus: lastKnownStatus,
    );
  }
}
