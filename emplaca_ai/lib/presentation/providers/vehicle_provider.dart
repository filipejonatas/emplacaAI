// lib/presentation/providers/vehicle_provider.dart

import 'package:flutter/foundation.dart';

import '../../domain/entities/vehicle.dart';
import '../../domain/usecases/vehicle/add_vehicle.dart';
import '../../domain/usecases/vehicle/get_vehicles.dart';
import '../../domain/usecases/vehicle/update_vehicle.dart';
import '../../domain/usecases/vehicle/delete_vehicle.dart';
import '../../domain/usecases/vehicle/search_vehicles.dart';
import '../../domain/usecases/vehicle/toggle_vehicle_active.dart';
import '../../domain/usecases/vehicle/get_vehicle_by_id.dart';
import '../../core/errors/exceptions.dart';

/// Provider for managing vehicle state and operations
/// Handles all vehicle-related business logic and UI state
class VehicleProvider extends ChangeNotifier {
  final AddVehicle _addVehicle;
  final GetVehicles _getVehicles;
  final UpdateVehicle _updateVehicle;
  final DeleteVehicle _deleteVehicle;
  final SearchVehicles _searchVehicles;
  final ToggleVehicleActive _toggleVehicleActive;
  final GetVehicleById _getVehicleById;

  VehicleProvider({
    required AddVehicle addVehicle,
    required GetVehicles getVehicles,
    required UpdateVehicle updateVehicle,
    required DeleteVehicle deleteVehicle,
    required SearchVehicles searchVehicles,
    required ToggleVehicleActive toggleVehicleActive,
    required GetVehicleById getVehicleById,
  })  : _addVehicle = addVehicle,
        _getVehicles = getVehicles,
        _updateVehicle = updateVehicle,
        _deleteVehicle = deleteVehicle,
        _searchVehicles = searchVehicles,
        _toggleVehicleActive = toggleVehicleActive,
        _getVehicleById = getVehicleById;

  // State variables
  List<Vehicle> _vehicles = [];
  List<Vehicle> _filteredVehicles = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  bool _showActiveOnly = false;

  // Getters
  List<Vehicle> get vehicles => _filteredVehicles;
  List<Vehicle> get allVehicles => _vehicles;
  List<Vehicle> get activeVehicles =>
      _vehicles.where((v) => v.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get showActiveOnly => _showActiveOnly;
  bool get hasVehicles => _vehicles.isNotEmpty;
  int get vehicleCount => _vehicles.length;
  int get activeVehicleCount => activeVehicles.length;

  /// Loads all vehicles for a user
  Future<void> loadVehicles(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _vehicles = await _getVehicles(userId);
      _applyFilters();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new vehicle
  Future<bool> addVehicle({
    required String licensePlate,
    required String model,
    required String brand,
    required String userId,
    bool isActive = true,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final newVehicle = await _addVehicle(
        licensePlate: licensePlate,
        model: model,
        brand: brand,
        userId: userId,
        isActive: isActive,
      );

      _vehicles.insert(0, newVehicle);
      _applyFilters();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing vehicle
  Future<bool> updateVehicle({
    required String vehicleId,
    required String licensePlate,
    required String model,
    required String brand,
    required String userId,
    bool? isActive,
    String? lastKnownStatus,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedVehicle = await _updateVehicle(
        vehicleId: vehicleId,
        licensePlate: licensePlate,
        model: model,
        brand: brand,
        userId: userId,
        isActive: isActive,
        lastKnownStatus: lastKnownStatus,
      );

      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
        _applyFilters();
      }
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a vehicle
  Future<bool> deleteVehicle(String vehicleId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _deleteVehicle(vehicleId);
      if (success) {
        _vehicles.removeWhere((v) => v.id == vehicleId);
        _applyFilters();
      }
      return success;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggles vehicle active status
  Future<bool> toggleVehicleActive(String vehicleId) async {
    _clearError();

    try {
      final updatedVehicle = await _toggleVehicleActive(vehicleId);

      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
        _applyFilters();
      }
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  /// Gets a specific vehicle by ID
  Future<Vehicle?> getVehicleById(String vehicleId) async {
    try {
      return await _getVehicleById(vehicleId);
    } catch (e) {
      _setError(_getErrorMessage(e));
      return null;
    }
  }

  /// Searches vehicles by query
  Future<void> searchVehicles(String userId, String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _applyFilters();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final searchResults = await _searchVehicles(
        userId: userId,
        query: query,
      );

      _filteredVehicles = searchResults;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Clears search and shows all vehicles
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  /// Toggles showing only active vehicles
  void toggleShowActiveOnly() {
    _showActiveOnly = !_showActiveOnly;
    _applyFilters();
  }

  /// Refreshes the vehicle list
  Future<void> refresh(String userId) async {
    await loadVehicles(userId);
  }

  /// Clears all state
  void clear() {
    _vehicles.clear();
    _filteredVehicles.clear();
    _searchQuery = '';
    _showActiveOnly = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Clears error state
  void clearError() {
    _clearError();
  }

  // Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _applyFilters() {
    var filtered = List<Vehicle>.from(_vehicles);

    // Apply active filter
    if (_showActiveOnly) {
      filtered = filtered.where((v) => v.isActive).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((vehicle) {
        return vehicle.licensePlate.toLowerCase().contains(query) ||
            vehicle.model.toLowerCase().contains(query) ||
            vehicle.brand.toLowerCase().contains(query);
      }).toList();
    }

    _filteredVehicles = filtered;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is VehicleException) {
      return error.message;
    } else if (error is ValidationException) {
      return error.message;
    } else {
      return 'Erro inesperado: $error';
    }
  }
}
