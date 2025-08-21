// lib/domain/usecases/vehicle/get_vehicles.dart

import '../../entities/vehicle.dart';
import '../../repositories/vehicle_repository.dart';
import '../../../core/errors/exceptions.dart';

/// Use case for retrieving vehicles
class GetVehicles {
  final VehicleRepository _repository;

  GetVehicles(this._repository);

  /// Gets all vehicles for a user
  Future<List<Vehicle>> call(String userId) async {
    if (userId.trim().isEmpty) {
      throw ValidationException('ID do usuário é obrigatório');
    }

    return await _repository.getVehicles(userId);
  }
}
