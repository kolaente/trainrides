import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/train_rides_provider.dart';
import '../../providers/theme_provider.dart' as theme_provider;
import '../add_ride/add_ride_screen.dart';
import '../ride_details/ride_details_screen.dart';
import '../../../data/models/train_ride.dart' as model;
import '../../../core/utils/date_utils.dart' as date_utils;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Data is automatically loaded when the provider is first accessed
  }

  @override
  Widget build(BuildContext context) {
    final trainRidesAsync = ref.watch(trainRidesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Train Rides'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'theme':
                  await _showThemeDialog(context);
                  break;
                case 'refresh':
                  await ref.read(trainRidesNotifierProvider.notifier).refresh();
                  break;
                case 'logout':
                  await ref.read(authNotifierProvider.notifier).logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'theme',
                child: ListTile(
                  leading: Icon(Icons.palette),
                  title: Text('Theme'),
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: trainRidesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(trainRidesNotifierProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (trainRides) {
          if (trainRides.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.train, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No train rides yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first train ride using the + button',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(trainRidesNotifierProvider.notifier).refresh();
            },
            child: ListView.builder(
              itemCount: trainRides.length,
              itemBuilder: (context, index) {
                final ride = trainRides[index];
                return TrainRideListItem(
                  ride: ride,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            RideDetailsScreen(rideId: ride.id!),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddRideScreen()),
          );
        },
        tooltip: 'Add Train Ride',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    final currentTheme = await ref.read(
      theme_provider.themeNotifierProvider.future,
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: theme_provider.ThemeMode.values
              .map(
                (mode) => RadioListTile<theme_provider.ThemeMode>(
                  title: Text(mode.displayName),
                  value: mode,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(theme_provider.themeNotifierProvider.notifier)
                          .setTheme(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class TrainRideListItem extends StatelessWidget {
  final model.TrainRide ride;
  final VoidCallback onTap;

  const TrainRideListItem({super.key, required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            ride.type.isEmpty ? '?' : ride.type.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          ride.displayTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date_utils.DateUtils.formatForDisplay(ride.date)),
            Text(
              '${ride.type} • ${ride.displayPrice}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ride.displayPrice,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
