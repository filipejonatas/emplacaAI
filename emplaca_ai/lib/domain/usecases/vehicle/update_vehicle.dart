// lib/domain/usecases/vehicle/update_vehicle.dart

import 'package:emplaca_ai/core/errors/exceptions.dart';
import 'package:emplaca_ai/core/utils/validators.dart';
import 'package:emplaca_ai/domain/entities/vehicle.dart';
import 'package:emplaca_ai/domain/repositories/vehicle_repository.dart';

/// Use case for updating an existing vehicle
class UpdateVehicle {
  final VehicleRepository _repository;

  UpdateVehicle(this._repository);

  /// Updates a vehicle with validation
  Future<Vehicle> call({
    required String vehicleId,
    required String licensePlate,
    required String model,
    required String brand,
    required String userId,
    bool? isActive,
    String? lastKnownStatus,
  }) async {
    // Validate inputs
    _validateInputs(
      vehicleId: vehicleId,
      licensePlate: licensePlate,
      model: model,
      brand: brand,
      userId: userId,
    );

    // Get existing vehicle
    final existingVehicle = await _repository.getVehicleById(vehicleId);
    if (existingVehicle == null) {
      throw const VehicleException('Veículo não encontrado');
    }

    // Create updated vehicle with current timestamp
    final updatedVehicle = existingVehicle.copyWith(
      licensePlate: licensePlate.toUpperCase().trim(),
      model: model.trim(),
      brand: brand.trim(),
      isActive: isActive,
      lastKnownStatus: lastKnownStatus,
      updatedAt: DateTime.now(),
    );

    return await _repository.updateVehicle(updatedVehicle);
  }

  void _validateInputs({
    required String vehicleId,
    required String licensePlate,
    required String model,
    required String brand,
    required String userId,
  }) {
    final errors = <String>[];

    // Validate vehicle ID
    if (vehicleId.trim().isEmpty) {
      errors.add('ID do veículo é obrigatório');
    }

    // Validate license plate
    if (licensePlate.trim().isEmpty) {
      errors.add('Placa é obrigatória');
    } else if (!Validators.isValidBrazilianLicensePlate(licensePlate.trim())) {
      errors.add('Formato de placa inválido (use ABC1234 ou ABC1D23)');
    }

    // Validate model
    if (model.trim().isEmpty) {
      errors.add('Modelo é obrigatório');
    } else if (model.trim().length < 2) {
      errors.add('Modelo deve ter pelo menos 2 caracteres');
    } else if (model.trim().length > 50) {
      errors.add('Modelo deve ter no máximo 50 caracteres');
    }

    // Validate brand
    if (brand.trim().isEmpty) {
      errors.add('Marca é obrigatória');
    } else if (brand.trim().length < 2) {
      errors.add('Marca deve ter pelo menos 2 caracteres');
    } else if (brand.trim().length > 30) {
      errors.add('Marca deve ter no máximo 30 caracteres');
    }

    // Validate user ID
    if (userId.trim().isEmpty) {
      errors.add('ID do usuário é obrigatório');
    }

    if (errors.isNotEmpty) {
      throw ValidationException(errors.join(', '));
    }
  }
}
