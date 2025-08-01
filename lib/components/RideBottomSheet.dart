import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/train_ride.dart';
import '../presentation/providers/train_rides_provider.dart';
import '../presentation/screens/add_ride/add_ride_screen.dart';
import '../presentation/widgets/type_label.dart';
import '../core/utils/date_utils.dart' as date_utils;

class RideBottomSheet extends ConsumerStatefulWidget {
  final TrainRide ride;
  final Function? onEdit;
  final Function? onDelete;

  const RideBottomSheet({
    super.key,
    required this.ride,
    this.onEdit,
    this.onDelete,
  });

  @override
  ConsumerState<RideBottomSheet> createState() => _RideBottomSheetState();
}

class _RideBottomSheetState extends ConsumerState<RideBottomSheet> {
  final double propertyPadding = 12.0;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    
    // Watch the current ride from the provider to get real-time updates
    final rideAsync = ref.watch(trainRideByIdProvider(widget.ride.id!));
    final currentRide = rideAsync.when(
      data: (ride) => ride ?? widget.ride,
      loading: () => widget.ride,
      error: (_, __) => widget.ride,
    );
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Title and action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            currentRide.displayTitle,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                final result = await Navigator.push<TrainRide>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddRideScreen(ride: currentRide),
                                  ),
                                );
                                if (result != null) {
                                  widget.onEdit?.call();
                                }
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => _showDeleteDialog(context),
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: propertyPadding),

                    // Date, Type, and Price
                    Row(
                      children: [
                        Text(
                          date_utils.DateUtils.formatForDisplay(
                            currentRide.date,
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 12),
                        const SizedBox.shrink(),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentRide.displayPrice,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (currentRide.details != null &&
                        currentRide.details!.isNotEmpty) ...[
                      SizedBox(height: propertyPadding),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            currentRide.details!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: _buildSystemInfo(
                    context,
                    Icons.access_time,
                    'Created',
                    date_utils.DateUtils.formatDateTimeForDisplay(
                      currentRide.createdAt,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildSystemInfo(
                    context,
                    Icons.update,
                    'Updated',
                    '',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    ThemeData theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemInfo(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
            SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Train Ride'),
        content: Text(
          'Are you sure you want to delete this train ride? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ref
            .read(trainRidesNotifierProvider.notifier)
            .deleteTrainRide(widget.ride.id!);

        if (context.mounted) {
          Navigator.of(context).pop(); // Close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Train ride deleted'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onDelete?.call();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting train ride: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
