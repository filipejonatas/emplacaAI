// lib/domain/usecases/vehicle/toggle_vehicle_active.dart

import 'package:emplaca_ai/core/errors/exceptions.dart';
import 'package:emplaca_ai/domain/entities/vehicle.dart';
import 'package:emplaca_ai/domain/repositories/vehicle_repository.dart';

/// Use case for toggling vehicle active status
class ToggleVehicleActive {
  final VehicleRepository _repository;

  ToggleVehicleActive(this._repository);

  /// Toggles the active status of a vehicle
  Future<Vehicle> call(String vehicleId) async {
    if (vehicleId.trim().isEmpty) {
      throw const ValidationException('ID do veículo é obrigatório');
    }

    return await _repository.toggleVehicleActive(vehicleId);
  }
}
