import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/train_rides_provider.dart';
import '../../providers/theme_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainRidesAsync = ref.watch(trainRidesNotifierProvider);
    final rideTypesAsync = ref.watch(rideTypesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref.read(trainRidesNotifierProvider.notifier).refresh();
              await ref.read(rideTypesNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: trainRidesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(trainRidesNotifierProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        data: (trainRides) {
          if (trainRides.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.bar_chart,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Statistics Yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add some train rides to see statistics',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return rideTypesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Error loading ride types: $error')),
            data: (rideTypes) {
              // Calculate statistics by category
              final Map<String, CategoryStats> categoryStats = {};
              double totalPrice = 0.0;
              int totalCount = trainRides.length;

              // First pass: collect all rides and calculate totals
              for (final ride in trainRides) {
                totalPrice += ride.price;

                // Find the type name
                String typeName = 'Uncategorized';
                Color? typeColor;

                if (ride.typeId != null) {
                  final type = rideTypes.firstWhere(
                    (t) => t['id'] == ride.typeId,
                    orElse: () => <String, dynamic>{},
                  );
                  if (type.isNotEmpty) {
                    typeName =
                        (type['title'] as String?) ??
                        (type['value'] as String?) ??
                        'Uncategorized';
                    final colorHex = type['color'] as String?;
                    if (colorHex != null) {
                      typeColor = AppTheme.parseColor(colorHex);
                    }
                  }
                }

                if (!categoryStats.containsKey(typeName)) {
                  categoryStats[typeName] = CategoryStats(
                    name: typeName,
                    color: typeColor,
                    totalPrice: 0.0,
                    count: 0,
                  );
                }

                categoryStats[typeName] = categoryStats[typeName]!.copyWith(
                  totalPrice: categoryStats[typeName]!.totalPrice + ride.price,
                  count: categoryStats[typeName]!.count + 1,
                );
              }

              // Sort by total price descending
              final sortedCategories = categoryStats.values.toList()
                ..sort((a, b) => b.totalPrice.compareTo(a.totalPrice));

              return RefreshIndicator(
                onRefresh: () async {
                  await ref.read(trainRidesNotifierProvider.notifier).refresh();
                  await ref.read(rideTypesNotifierProvider.notifier).refresh();
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Overall Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                totalCount.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                'Total Rides',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer.withOpacity(0.3),
                          ),
                          Column(
                            children: [
                              Text(
                                '${totalPrice.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Section Header
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'Breakdown by Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Category Statistics
                    ...sortedCategories.map(
                      (category) => _CategoryCard(
                        category: category,
                        totalPrice: totalPrice,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryStats category;
  final double totalPrice;

  const _CategoryCard({required this.category, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    final percentage = (category.totalPrice / totalPrice * 100);
    final averagePrice = category.totalPrice / category.count;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color:
                        category.color ?? Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: 'Total',
                    value: '${category.totalPrice.toStringAsFixed(2)} €',
                    icon: Icons.payments_outlined,
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'Average',
                    value: '${averagePrice.toStringAsFixed(2)} €',
                    icon: Icons.show_chart,
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'Count',
                    value: category.count.toString(),
                    icon: Icons.tag,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class CategoryStats {
  final String name;
  final Color? color;
  final double totalPrice;
  final int count;

  const CategoryStats({
    required this.name,
    this.color,
    required this.totalPrice,
    required this.count,
  });

  CategoryStats copyWith({
    String? name,
    Color? color,
    double? totalPrice,
    int? count,
  }) {
    return CategoryStats(
      name: name ?? this.name,
      color: color ?? this.color,
      totalPrice: totalPrice ?? this.totalPrice,
      count: count ?? this.count,
    );
  }
}
