import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/train_rides_provider.dart';

class RideTypesScreen extends ConsumerWidget {
  const RideTypesScreen({super.key});

  Future<void> _addOrEdit(BuildContext context, WidgetRef ref, {Map<String, dynamic>? initial}) async {
    final titleCtrl = TextEditingController(text: initial?['title'] as String? ?? '');
    Color picked = _parseColor(initial?['color'] as String? ?? '#4895ef');

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
                      final res = await showDialog<Color?>(
                        context: ctx,
                        builder: (_) => _ColorPickerDialog(initialColor: picked),
                      );
                      if (res != null) setLocalState(() => picked = res);
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
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (ok != true) return;

    final title = titleCtrl.text.trim();
    if (title.isEmpty) return;

    final colorHex = '#${picked.value.toRadixString(16).padLeft(8, '0').substring(2)}';

    final notifier = ref.read(rideTypesNotifierProvider.notifier);
    
    try {
      if ((initial?['id']) != null) {
        await notifier.updateRideType(initial!['id'] as int, title, colorHex);
      } else {
        await notifier.addRideType(title, colorHex);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, int id) async {
    final notifier = ref.read(rideTypesNotifierProvider.notifier);
    
    try {
      await notifier.deleteRideType(id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete error: $error')),
        );
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
          sortedItems.sort((a, b) => (a['title'] as String? ?? '').compareTo(b['title'] as String? ?? ''));
          
          if (sortedItems.isEmpty) {
            return const Center(child: Text('No ride types yet'));
          }
          
          return ListView.separated(
            itemCount: sortedItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              final color = _parseColor(item['color'] as String?);
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

  Color _parseColor(String? hex) {
    final v = (hex ?? '').replaceAll('#', '');
    if (v.length == 6) {
      return Color(int.parse('FF$v', radix: 16));
    }
    if (v.length == 8) {
      return Color(int.parse(v, radix: 16));
    }
    return const Color(0xFF4895EF);
  }
}

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  const _ColorPickerDialog({required this.initialColor});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late double _r;
  late double _g;
  late double _b;

  @override
  void initState() {
    super.initState();
    _r = widget.initialColor.red.toDouble();
    _g = widget.initialColor.green.toDouble();
    _b = widget.initialColor.blue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color.fromARGB(255, _r.toInt(), _g.toInt(), _b.toInt());
    return AlertDialog(
      title: const Text('Pick a color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(height: 12),
          _slider('R', _r, (v) => setState(() => _r = v), Colors.red),
          _slider('G', _g, (v) => setState(() => _g = v), Colors.green),
          _slider('B', _b, (v) => setState(() => _b = v), Colors.blue),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, color), child: const Text('Use')),
      ],
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged, Color active) {
    return Row(
      children: [
        SizedBox(width: 20, child: Text(label)),
        Expanded(
          child: Slider(
            min: 0,
            max: 255,
            divisions: 255,
            value: value,
            onChanged: onChanged,
            activeColor: active,
          ),
        ),
      ],
    );
  }
}
