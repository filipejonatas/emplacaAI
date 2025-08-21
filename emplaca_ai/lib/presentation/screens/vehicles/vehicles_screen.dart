// lib/presentation/screens/vehicles/vehicles_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/vehicle/vehicle_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../core/constants/route_constants.dart';

/// Main screen for displaying and managing vehicles
/// Shows list of vehicles with search, filter, and CRUD operations
class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final TextEditingController _searchController = TextEditingController();
  late String _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initializeScreen() {
    final authProvider = context.read<AuthProvider>();
    _userId = authProvider.currentUser?.id ?? '';

    if (_userId.isNotEmpty) {
      context.read<VehicleProvider>().loadVehicles(_userId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildVehicleStats(),
          Expanded(child: _buildVehicleList()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Veículos'),
      elevation: 0,
      actions: [
        Consumer<VehicleProvider>(
          builder: (context, provider, child) {
            return IconButton(
              icon: Icon(
                provider.showActiveOnly
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () => provider.toggleShowActiveOnly(),
              tooltip: provider.showActiveOnly
                  ? 'Mostrar todos'
                  : 'Mostrar apenas ativos',
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshVehicles,
          tooltip: 'Atualizar',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToAddVehicle,
      tooltip: 'Adicionar Veículo',
      child: const Icon(Icons.add),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por placa, modelo ou marca...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildVehicleStats() {
    return Consumer<VehicleProvider>(
      builder: (context, provider, child) {
        if (provider.vehicles.isEmpty && !provider.isLoading) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildStatChip(
                'Total: ${provider.vehicleCount}',
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                'Ativos: ${provider.activeVehicleCount}',
                Colors.green,
              ),
              const Spacer(),
              if (provider.searchQuery.isNotEmpty) _buildSearchChip(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: _getTextColor(color),
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: _getBackgroundColor(color),
    );
  }

  Widget _buildSearchChip(VehicleProvider provider) {
    return Chip(
      label: Text('Filtrado: ${provider.vehicles.length}'),
      backgroundColor: Colors.orange.shade100,
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: _clearSearch,
    );
  }

  Widget _buildVehicleList() {
    return Consumer<VehicleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingWidget(message: 'Carregando veículos...');
        }

        if (provider.error != null) {
          return CustomErrorWidget(
            message: provider.error!,
            onRetry: () => provider.loadVehicles(_userId),
          );
        }

        if (provider.vehicles.isEmpty) {
          return _buildEmptyState(provider);
        }

        return _buildVehicleListView(provider);
      },
    );
  }

  Widget _buildEmptyState(VehicleProvider provider) {
    // Check if it's empty due to search or genuinely no vehicles
    if (provider.searchQuery.isNotEmpty) {
      return EmptyStateWidget(
        title: 'Nenhum veículo encontrado',
        subtitle: 'Tente ajustar os termos de busca',
        icon: Icons.search_off,
        action: ElevatedButton.icon(
          onPressed: _clearSearch,
          icon: const Icon(Icons.clear),
          label: const Text('Limpar Busca'),
        ),
      );
    }

    return EmptyStateWidget(
      title: 'Nenhum veículo cadastrado',
      subtitle: 'Adicione seu primeiro veículo para começar',
      icon: Icons.directions_car_outlined,
      action: ElevatedButton.icon(
        onPressed: _navigateToAddVehicle,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Veículo'),
      ),
    );
  }

  Widget _buildVehicleListView(VehicleProvider provider) {
    return RefreshIndicator(
      onRefresh: _refreshVehicles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: provider.vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = provider.vehicles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: VehicleCard(
              vehicle: vehicle,
              onTap: () => _navigateToEditVehicle(vehicle.id),
              onToggleActive: () => _toggleVehicleActive(vehicle.id),
              onDelete: () => _showDeleteConfirmation(vehicle),
            ),
          );
        },
      ),
    );
  }

  // Event handlers
  void _onSearchChanged(String query) {
    context.read<VehicleProvider>().searchVehicles(_userId, query);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<VehicleProvider>().clearSearch();
  }

  Future<void> _refreshVehicles() async {
    await context.read<VehicleProvider>().refresh(_userId);
  }

  void _navigateToAddVehicle() {
    Navigator.of(context).pushNamed(RouteConstants.addVehicle);
  }

  void _navigateToEditVehicle(String vehicleId) {
    Navigator.of(context).pushNamed(
      RouteConstants.editVehicle,
      arguments: vehicleId,
    );
  }

  Future<void> _toggleVehicleActive(String vehicleId) async {
    final provider = context.read<VehicleProvider>();
    final success = await provider.toggleVehicleActive(vehicleId);

    if (!success && provider.error != null) {
      _showErrorMessage(provider.error!);
    }
  }

  void _showDeleteConfirmation(dynamic vehicle) {
    ErrorDialog.show(
      context,
      title: 'Confirmar Exclusão',
      message:
          'Tem certeza que deseja excluir o veículo ${vehicle.displayName}?\n\n'
          'Esta ação não pode ser desfeita.',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      onConfirm: () => _deleteVehicle(vehicle.id),
    );
  }

  Future<void> _deleteVehicle(String vehicleId) async {
    final provider = context.read<VehicleProvider>();
    final success = await provider.deleteVehicle(vehicleId);

    if (success) {
      _showSuccessMessage('Veículo excluído com sucesso');
    } else if (provider.error != null) {
      _showErrorMessage(provider.error!);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Helper methods for colors
  Color _getTextColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }

  Color _getBackgroundColor(Color color) {
    // Use alpha instead of withOpacity for better future compatibility
    return color.withAlpha((color.alpha * 0.1).round());
  }
}
