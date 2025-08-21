// lib/presentation/widgets/common/error_widget.dart

import 'package:flutter/material.dart';

/// Custom error widget with retry functionality and consistent styling
/// Used throughout the app for error states
class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;
  final TextStyle? messageStyle;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText,
    this.icon,
    this.showIcon = true,
    this.padding,
    this.messageStyle,
  });

  /// Compact error widget for inline use
  const CustomErrorWidget.compact({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText,
    this.icon,
    this.messageStyle,
  })  : showIcon = false,
        padding = const EdgeInsets.all(8.0);

  /// Network error with specific styling and icon
  const CustomErrorWidget.network({
    super.key,
    this.message = 'Erro de conexão. Verifique sua internet.',
    this.onRetry,
    this.retryText = 'Tentar Novamente',
    this.showIcon = true,
    this.padding,
    this.messageStyle,
  }) : icon = Icons.wifi_off;

  /// Server error with specific styling and icon
  const CustomErrorWidget.server({
    super.key,
    this.message = 'Erro no servidor. Tente novamente mais tarde.',
    this.onRetry,
    this.retryText = 'Tentar Novamente',
    this.showIcon = true,
    this.padding,
    this.messageStyle,
  }) : icon = Icons.error_outline;

  /// Not found error with specific styling and icon
  const CustomErrorWidget.notFound({
    super.key,
    this.message = 'Nenhum item encontrado.',
    this.onRetry,
    this.retryText,
    this.showIcon = true,
    this.padding,
    this.messageStyle,
  }) : icon = Icons.search_off;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = padding ?? const EdgeInsets.all(16.0);
    final effectiveIcon = icon ?? Icons.error_outline;
    final effectiveRetryText = retryText ?? 'Tentar Novamente';

    return Container(
      padding: effectivePadding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Icon(
                effectiveIcon,
                size: 64,
                color: theme.colorScheme.error.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: messageStyle ??
                  theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(effectiveRetryText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error banner that can be shown at the top of screens
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onRetry,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.errorContainer;
    final effectiveTextColor = textColor ?? theme.colorScheme.onErrorContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: effectiveTextColor,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: effectiveTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: effectiveTextColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Tentar'),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              color: effectiveTextColor,
              iconSize: 20,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error dialog for critical errors
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool barrierDismissible;

  const ErrorDialog({
    super.key,
    this.title = 'Erro',
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.barrierDismissible = true,
  });

  static Future<bool?> show(
    BuildContext context, {
    String title = 'Erro',
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        if (cancelText != null || onCancel != null)
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(false),
            child: Text(cancelText ?? 'Cancelar'),
          ),
        ElevatedButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: Text(confirmText ?? 'OK'),
        ),
      ],
    );
  }
}

/// Inline error message for form fields
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.padding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = padding ?? const EdgeInsets.only(top: 4);

    return Container(
      padding: effectivePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message,
              style: textStyle ??
                  theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state for empty lists
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = padding ?? const EdgeInsets.all(32);

    return Container(
      padding: effectivePadding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 80,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
