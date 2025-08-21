// lib/domain/repositories/vehicle_repository.dart

import '../entities/vehicle.dart';

/// Abstract repository interface for vehicle operations
/// Defines the contract for vehicle data access
abstract class VehicleRepository {
  /// Adds a new vehicle to the repository
  /// Returns the created vehicle with generated ID
  /// Throws [VehicleException] if operation fails
  Future<Vehicle> addVehicle(Vehicle vehicle);

  /// Retrieves all vehicles for a specific user
  /// Returns empty list if no vehicles found
  /// Throws [VehicleException] if operation fails
  Future<List<Vehicle>> getVehicles(String userId);

  /// Retrieves active vehicles only for a specific user
  /// Returns empty list if no active vehicles found
  /// Throws [VehicleException] if operation fails
  Future<List<Vehicle>> getActiveVehicles(String userId);

  /// Retrieves a specific vehicle by ID
  /// Returns null if vehicle not found
  /// Throws [VehicleException] if operation fails
  Future<Vehicle?> getVehicleById(String vehicleId);

  /// Updates an existing vehicle
  /// Returns the updated vehicle
  /// Throws [VehicleException] if vehicle not found or operation fails
  Future<Vehicle> updateVehicle(Vehicle vehicle);

  /// Deletes a vehicle by ID
  /// Returns true if successfully deleted, false if not found
  /// Throws [VehicleException] if operation fails
  Future<bool> deleteVehicle(String vehicleId);

  /// Checks if a license plate already exists for a user
  /// Returns true if license plate exists, false otherwise
  /// Throws [VehicleException] if operation fails
  Future<bool> licensePlateExists(String licensePlate, String userId,
      {String? excludeVehicleId});

  /// Searches vehicles by license plate, model, or brand
  /// Returns filtered list of vehicles
  /// Throws [VehicleException] if operation fails
  Future<List<Vehicle>> searchVehicles(String userId, String query);

  /// Updates the last known status of a vehicle
  /// Returns the updated vehicle
  /// Throws [VehicleException] if vehicle not found or operation fails
  Future<Vehicle> updateVehicleStatus(String vehicleId, String status);

  /// Toggles the active status of a vehicle
  /// Returns the updated vehicle
  /// Throws [VehicleException] if vehicle not found or operation fails
  Future<Vehicle> toggleVehicleActive(String vehicleId);

  /// Gets the count of vehicles for a user
  /// Returns the total count of vehicles
  /// Throws [VehicleException] if operation fails
  Future<int> getVehicleCount(String userId);

  /// Gets the count of active vehicles for a user
  /// Returns the count of active vehicles
  /// Throws [VehicleException] if operation fails
  Future<int> getActiveVehicleCount(String userId);
}
