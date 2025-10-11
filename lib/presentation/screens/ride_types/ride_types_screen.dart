import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../providers/train_rides_provider.dart';
import '../../providers/theme_provider.dart';

class RideTypesScreen extends ConsumerWidget {
  const RideTypesScreen({super.key});

  Future<void> _addOrEdit(
    BuildContext context,
    WidgetRef ref, {
    Map<String, dynamic>? initial,
  }) async {
    final titleCtrl = TextEditingController(
      text: initial?['title'] as String? ?? '',
    );
    Color picked = AppTheme.parseColor(
      initial?['color'] as String? ?? '#4895ef',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: Text(initial == null ? 'Add ride type' : 'Edit ride type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Color'),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      final res = await showColorPickerDialog(
                        ctx,
                        picked,
                        title: Text('Pick a color'),
                        width: 40,
                        height: 40,
                        borderRadius: 4,
                        pickersEnabled: const <ColorPickerType, bool>{
                          ColorPickerType.both: true,
                          ColorPickerType.primary: false,
                          ColorPickerType.accent: false,
                          ColorPickerType.bw: false,
                          ColorPickerType.custom: false,
                          ColorPickerType.wheel: true,
                        },
                        enableShadesSelection: true,
                        enableTonalPalette: true,
                        showColorCode: true,
                        colorCodeHasColor: true,
                        showColorName: false,
                        showRecentColors: true,
                        maxRecentColors: 16,
                      );
                      if (res != picked) setLocalState(() => picked = res);
                    },
                    child: Container(
                      width: 36,
                      height: 24,
                      decoration: BoxDecoration(
                        color: picked,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    final title = titleCtrl.text.trim();
    if (title.isEmpty) return;

    final colorHex =
        '#${picked.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

    final notifier = ref.read(rideTypesNotifierProvider.notifier);

    try {
      if ((initial?['id']) != null) {
        await notifier.updateRideType(initial!['id'] as int, title, colorHex);
      } else {
        await notifier.addRideType(title, colorHex);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, int id) async {
    final notifier = ref.read(rideTypesNotifierProvider.notifier);

    try {
      await notifier.deleteRideType(id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete error: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideTypesAsync = ref.watch(rideTypesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ride types')),
      body: rideTypesAsync.when(
        data: (items) {
          // Sort items alphabetically by title
          final sortedItems = List<Map<String, dynamic>>.from(items);
          sortedItems.sort(
            (a, b) => (a['title'] as String? ?? '').compareTo(
              b['title'] as String? ?? '',
            ),
          );

          if (sortedItems.isEmpty) {
            return const Center(child: Text('No ride types yet'));
          }

          return ListView.separated(
            itemCount: sortedItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              final color = AppTheme.parseColor(item['color'] as String?);
              return ListTile(
                leading: CircleAvatar(backgroundColor: color),
                title: Text(item['title']?.toString() ?? ''),
                subtitle: Text('#${item['id']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _addOrEdit(context, ref, initial: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(context, ref, item['id'] as int),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(rideTypesNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
