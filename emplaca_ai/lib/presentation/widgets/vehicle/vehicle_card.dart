// lib/presentation/widgets/vehicle/vehicle_card.dart

import 'package:flutter/material.dart';
import '../../../domain/entities/vehicle.dart';

/// Reusable card widget for displaying vehicle information
/// Provides actions for edit, toggle active status, and delete
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;
  final VoidCallback? onToggleActive;
  final VoidCallback? onDelete;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
    this.onToggleActive,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: vehicle.isActive
              ? colorScheme.primary.withOpacity(0.2)
              : colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildVehicleInfo(context),
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // License plate with background
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: vehicle.isActive ? colorScheme.primary : colorScheme.outline,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            vehicle.licensePlate,
            style: theme.textTheme.titleMedium?.copyWith(
              color: vehicle.isActive
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Spacer(),
        // Status indicator
        _buildStatusChip(context),
        // More actions button
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: colorScheme.onSurfaceVariant,
          ),
          onSelected: (value) {
            switch (value) {
              case 'toggle':
                onToggleActive?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    vehicle.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(vehicle.isActive ? 'Desativar' : 'Ativar'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Excluir',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: vehicle.isActive
            ? colorScheme.primaryContainer
            : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            vehicle.isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: vehicle.isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 4),
          Text(
            vehicle.statusText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: vehicle.isActive
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onErrorContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand and Model
        Text(
          '${vehicle.brand} ${vehicle.model}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        // Last known status (if available)
        if (vehicle.lastKnownStatus != null)
          Text(
            'Status: ${vehicle.lastKnownStatus}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // Created date
        Icon(
          Icons.calendar_today,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          'Criado em ${_formatDate(vehicle.createdAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        // Edit button
        TextButton.icon(
          onPressed: onTap,
          icon: Icon(
            Icons.edit_outlined,
            size: 16,
            color: colorScheme.primary,
          ),
          label: Text(
            'Editar',
            style: TextStyle(color: colorScheme.primary),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
