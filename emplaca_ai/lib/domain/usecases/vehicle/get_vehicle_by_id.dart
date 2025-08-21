// lib/domain/usecases/vehicle/get_vehicle_by_id.dart

import 'package:emplaca_ai/core/errors/exceptions.dart';
import 'package:emplaca_ai/domain/entities/vehicle.dart';
import 'package:emplaca_ai/domain/repositories/vehicle_repository.dart';

/// Use case for getting a specific vehicle by ID
class GetVehicleById {
  final VehicleRepository _repository;

  GetVehicleById(this._repository);

  /// Gets a vehicle by its ID
  /// Returns null if vehicle not found
  Future<Vehicle?> call(String vehicleId) async {
    if (vehicleId.trim().isEmpty) {
      throw const ValidationException('ID do veículo é obrigatório');
    }

    return await _repository.getVehicleById(vehicleId);
  }
}
