import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/train_rides_provider.dart';
import '../../../data/models/train_ride.dart' as model;
import '../../../core/utils/date_utils.dart' as date_utils;

class AddRideScreen extends ConsumerStatefulWidget {
  final model.TrainRide? ride;

  const AddRideScreen({super.key, this.ride});

  @override
  ConsumerState<AddRideScreen> createState() => _AddRideScreenState();
}

class _AddRideScreenState extends ConsumerState<AddRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _priceController = TextEditingController();
  final _detailsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedType;
  bool _isLoading = false;
  List<String> _cachedTypes = const [];

  List<String> get _typeOptions => _cachedTypes;

  @override
  void initState() {
    super.initState();
    if (widget.ride != null) {
      _fromController.text = widget.ride!.from;
      _toController.text = widget.ride!.to;
      _priceController.text = widget.ride!.price.toStringAsFixed(2);
      _detailsController.text = widget.ride!.details ?? '';
      _selectedDate = widget.ride!.date;
      _selectedType = null;
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _priceController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveRide() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final priceText = _priceController.text.trim();
      final parsedPrice = double.parse(priceText);

      final ride = model.TrainRide(
        id: widget.ride?.id,
        from: _fromController.text.trim(),
        to: _toController.text.trim(),
        price: parsedPrice,
        typeId: null,
        date: _selectedDate,
        details: _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
        createdAt: widget.ride?.createdAt ?? now,
      );

      if (widget.ride == null) {
        await ref.read(trainRidesNotifierProvider.notifier).addTrainRide(ride);
      } else {
        await ref
            .read(trainRidesNotifierProvider.notifier)
            .updateTrainRide(ride);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.ride == null ? 'Train ride added' : 'Train ride updated',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadTypes();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ride == null ? 'Add Train Ride' : 'Edit Train Ride'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRide,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _fromController,
              decoration: const InputDecoration(
                labelText: 'From',
                hintText: 'Enter departure station',
                prefixIcon: Icon(Icons.departure_board),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter departure station';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'To',
                hintText: 'Enter arrival station',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter arrival station';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        date_utils.DateUtils.formatForDisplay(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      prefixIcon: Icon(Icons.train),
                    ),
                    items: _typeOptions.map<DropdownMenuItem<String>>((title) {
                      return DropdownMenuItem<String>(
                        value: title,
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a type';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                hintText: 'Enter price in EUR',
                prefixIcon: Icon(Icons.euro),
                suffixText: 'EUR',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter price';
                }
                final price = double.tryParse(value.trim());
                if (price == null || price < 0) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _detailsController,
              decoration: const InputDecoration(
                labelText: 'Details (optional)',
                hintText: 'Additional notes about the ride',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  void _loadTypes() {
    final rideTypesAsync = ref.watch(rideTypesNotifierProvider);
    final titles = rideTypesAsync.when(
      data: (types) => types
          .map((e) => (e['title'] as String?) ?? '')
          .where((s) => s.isNotEmpty)
          .toList()
          ..sort(),
      loading: () => const <String>[],
      error: (_, __) => const <String>[],
    );
    
    if (_cachedTypes.length != titles.length || 
        !_cachedTypes.every((element) => titles.contains(element))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _cachedTypes = List<String>.from(titles);
            if (_selectedType == null && _cachedTypes.isNotEmpty) {
              _selectedType = _cachedTypes.first;
            }
          });
        }
      });
    }
  }
}
