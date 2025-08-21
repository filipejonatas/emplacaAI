// lib/domain/usecases/vehicle/search_vehicles.dart

import 'package:emplaca_ai/core/errors/exceptions.dart';
import 'package:emplaca_ai/domain/entities/vehicle.dart';
import 'package:emplaca_ai/domain/repositories/vehicle_repository.dart';

/// Use case for searching vehicles
class SearchVehicles {
  final VehicleRepository _repository;

  SearchVehicles(this._repository);

  /// Searches vehicles by license plate, model, or brand
  Future<List<Vehicle>> call({
    required String userId,
    required String query,
  }) async {
    if (userId.trim().isEmpty) {
      throw const ValidationException('ID do usuário é obrigatório');
    }

    if (query.trim().isEmpty) {
      // Return all vehicles if query is empty
      return await _repository.getVehicles(userId);
    }

    return await _repository.searchVehicles(userId, query.trim());
  }
}
