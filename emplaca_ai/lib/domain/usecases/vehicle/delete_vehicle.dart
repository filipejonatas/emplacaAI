// lib/domain/usecases/vehicle/delete_vehicle.dart

import 'package:emplaca_ai/core/errors/exceptions.dart';
import 'package:emplaca_ai/domain/repositories/vehicle_repository.dart';

/// Use case for deleting a vehicle
class DeleteVehicle {
  final VehicleRepository _repository;

  DeleteVehicle(this._repository);

  /// Deletes a vehicle by ID
  /// Returns true if deleted successfully, false if not found
  Future<bool> call(String vehicleId) async {
    if (vehicleId.trim().isEmpty) {
      throw const ValidationException('ID do veículo é obrigatório');
    }

    return await _repository.deleteVehicle(vehicleId);
  }
}
