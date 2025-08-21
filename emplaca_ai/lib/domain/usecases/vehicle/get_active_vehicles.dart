// lib/domain/usecases/vehicle/get_active_vehicles.dart

import 'package:emplaca_ai/core/errors/exceptions.dart';
import 'package:emplaca_ai/domain/entities/vehicle.dart';
import 'package:emplaca_ai/domain/repositories/vehicle_repository.dart';

/// Use case for retrieving active vehicles only
class GetActiveVehicles {
  final VehicleRepository _repository;

  GetActiveVehicles(this._repository);

  /// Gets only active vehicles for a user
  Future<List<Vehicle>> call(String userId) async {
    if (userId.trim().isEmpty) {
      throw const ValidationException('ID do usuário é obrigatório');
    }

    return await _repository.getActiveVehicles(userId);
  }
}
