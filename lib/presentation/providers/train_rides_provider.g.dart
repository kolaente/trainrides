// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_rides_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rideTypeTitlesHash() => r'e329eee523dc299e7f7a930ed4f43eab6a786e2c';

/// See also [rideTypeTitles].
@ProviderFor(rideTypeTitles)
final rideTypeTitlesProvider = AutoDisposeProvider<List<String>>.internal(
  rideTypeTitles,
  name: r'rideTypeTitlesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rideTypeTitlesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RideTypeTitlesRef = AutoDisposeProviderRef<List<String>>;
String _$rideTypeByIdHash() => r'a1d4450fd2b7a6598af3c472f5b46a37ee2f8ed1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [rideTypeById].
@ProviderFor(rideTypeById)
const rideTypeByIdProvider = RideTypeByIdFamily();

/// See also [rideTypeById].
class RideTypeByIdFamily extends Family<Map<String, dynamic>?> {
  /// See also [rideTypeById].
  const RideTypeByIdFamily();

  /// See also [rideTypeById].
  RideTypeByIdProvider call(int? typeId) {
    return RideTypeByIdProvider(typeId);
  }

  @override
  RideTypeByIdProvider getProviderOverride(
    covariant RideTypeByIdProvider provider,
  ) {
    return call(provider.typeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'rideTypeByIdProvider';
}

/// See also [rideTypeById].
class RideTypeByIdProvider extends AutoDisposeProvider<Map<String, dynamic>?> {
  /// See also [rideTypeById].
  RideTypeByIdProvider(int? typeId)
    : this._internal(
        (ref) => rideTypeById(ref as RideTypeByIdRef, typeId),
        from: rideTypeByIdProvider,
        name: r'rideTypeByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$rideTypeByIdHash,
        dependencies: RideTypeByIdFamily._dependencies,
        allTransitiveDependencies:
            RideTypeByIdFamily._allTransitiveDependencies,
        typeId: typeId,
      );

  RideTypeByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.typeId,
  }) : super.internal();

  final int? typeId;

  @override
  Override overrideWith(
    Map<String, dynamic>? Function(RideTypeByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RideTypeByIdProvider._internal(
        (ref) => create(ref as RideTypeByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        typeId: typeId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Map<String, dynamic>?> createElement() {
    return _RideTypeByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RideTypeByIdProvider && other.typeId == typeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, typeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RideTypeByIdRef on AutoDisposeProviderRef<Map<String, dynamic>?> {
  /// The parameter `typeId` of this provider.
  int? get typeId;
}

class _RideTypeByIdProviderElement
    extends AutoDisposeProviderElement<Map<String, dynamic>?>
    with RideTypeByIdRef {
  _RideTypeByIdProviderElement(super.provider);

  @override
  int? get typeId => (origin as RideTypeByIdProvider).typeId;
}

String _$trainRidesByDateRangeHash() =>
    r'b16c8170fe27bfdc358b429fcb64a474310e3e75';

/// See also [trainRidesByDateRange].
@ProviderFor(trainRidesByDateRange)
const trainRidesByDateRangeProvider = TrainRidesByDateRangeFamily();

/// See also [trainRidesByDateRange].
class TrainRidesByDateRangeFamily
    extends Family<AsyncValue<List<model.TrainRide>>> {
  /// See also [trainRidesByDateRange].
  const TrainRidesByDateRangeFamily();

  /// See also [trainRidesByDateRange].
  TrainRidesByDateRangeProvider call(DateTime start, DateTime end) {
    return TrainRidesByDateRangeProvider(start, end);
  }

  @override
  TrainRidesByDateRangeProvider getProviderOverride(
    covariant TrainRidesByDateRangeProvider provider,
  ) {
    return call(provider.start, provider.end);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'trainRidesByDateRangeProvider';
}

/// See also [trainRidesByDateRange].
class TrainRidesByDateRangeProvider
    extends AutoDisposeFutureProvider<List<model.TrainRide>> {
  /// See also [trainRidesByDateRange].
  TrainRidesByDateRangeProvider(DateTime start, DateTime end)
    : this._internal(
        (ref) =>
            trainRidesByDateRange(ref as TrainRidesByDateRangeRef, start, end),
        from: trainRidesByDateRangeProvider,
        name: r'trainRidesByDateRangeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainRidesByDateRangeHash,
        dependencies: TrainRidesByDateRangeFamily._dependencies,
        allTransitiveDependencies:
            TrainRidesByDateRangeFamily._allTransitiveDependencies,
        start: start,
        end: end,
      );

  TrainRidesByDateRangeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.start,
    required this.end,
  }) : super.internal();

  final DateTime start;
  final DateTime end;

  @override
  Override overrideWith(
    FutureOr<List<model.TrainRide>> Function(TrainRidesByDateRangeRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TrainRidesByDateRangeProvider._internal(
        (ref) => create(ref as TrainRidesByDateRangeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<model.TrainRide>> createElement() {
    return _TrainRidesByDateRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrainRidesByDateRangeProvider &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TrainRidesByDateRangeRef
    on AutoDisposeFutureProviderRef<List<model.TrainRide>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _TrainRidesByDateRangeProviderElement
    extends AutoDisposeFutureProviderElement<List<model.TrainRide>>
    with TrainRidesByDateRangeRef {
  _TrainRidesByDateRangeProviderElement(super.provider);

  @override
  DateTime get start => (origin as TrainRidesByDateRangeProvider).start;
  @override
  DateTime get end => (origin as TrainRidesByDateRangeProvider).end;
}

String _$trainRideByIdHash() => r'360bf72093d94865cb4798bdb47905756f26ba63';

/// See also [trainRideById].
@ProviderFor(trainRideById)
const trainRideByIdProvider = TrainRideByIdFamily();

/// See also [trainRideById].
class TrainRideByIdFamily extends Family<AsyncValue<model.TrainRide?>> {
  /// See also [trainRideById].
  const TrainRideByIdFamily();

  /// See also [trainRideById].
  TrainRideByIdProvider call(int id) {
    return TrainRideByIdProvider(id);
  }

  @override
  TrainRideByIdProvider getProviderOverride(
    covariant TrainRideByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'trainRideByIdProvider';
}

/// See also [trainRideById].
class TrainRideByIdProvider
    extends AutoDisposeFutureProvider<model.TrainRide?> {
  /// See also [trainRideById].
  TrainRideByIdProvider(int id)
    : this._internal(
        (ref) => trainRideById(ref as TrainRideByIdRef, id),
        from: trainRideByIdProvider,
        name: r'trainRideByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainRideByIdHash,
        dependencies: TrainRideByIdFamily._dependencies,
        allTransitiveDependencies:
            TrainRideByIdFamily._allTransitiveDependencies,
        id: id,
      );

  TrainRideByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<model.TrainRide?> Function(TrainRideByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TrainRideByIdProvider._internal(
        (ref) => create(ref as TrainRideByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<model.TrainRide?> createElement() {
    return _TrainRideByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrainRideByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TrainRideByIdRef on AutoDisposeFutureProviderRef<model.TrainRide?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _TrainRideByIdProviderElement
    extends AutoDisposeFutureProviderElement<model.TrainRide?>
    with TrainRideByIdRef {
  _TrainRideByIdProviderElement(super.provider);

  @override
  int get id => (origin as TrainRideByIdProvider).id;
}

String _$trainRidesNotifierHash() =>
    r'1671c2f89e48b3e67f13dab6f58729f59f5f51c0';

/// See also [TrainRidesNotifier].
@ProviderFor(TrainRidesNotifier)
final trainRidesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      TrainRidesNotifier,
      List<model.TrainRide>
    >.internal(
      TrainRidesNotifier.new,
      name: r'trainRidesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trainRidesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TrainRidesNotifier = AutoDisposeAsyncNotifier<List<model.TrainRide>>;
String _$trainRideSearchNotifierHash() =>
    r'907e81920a4aefb108334b5a7ab36924a1524312';

abstract class _$TrainRideSearchNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<model.TrainRide>> {
  late final String query;

  FutureOr<List<model.TrainRide>> build(String query);
}

/// See also [TrainRideSearchNotifier].
@ProviderFor(TrainRideSearchNotifier)
const trainRideSearchNotifierProvider = TrainRideSearchNotifierFamily();

/// See also [TrainRideSearchNotifier].
class TrainRideSearchNotifierFamily
    extends Family<AsyncValue<List<model.TrainRide>>> {
  /// See also [TrainRideSearchNotifier].
  const TrainRideSearchNotifierFamily();

  /// See also [TrainRideSearchNotifier].
  TrainRideSearchNotifierProvider call(String query) {
    return TrainRideSearchNotifierProvider(query);
  }

  @override
  TrainRideSearchNotifierProvider getProviderOverride(
    covariant TrainRideSearchNotifierProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'trainRideSearchNotifierProvider';
}

/// See also [TrainRideSearchNotifier].
class TrainRideSearchNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          TrainRideSearchNotifier,
          List<model.TrainRide>
        > {
  /// See also [TrainRideSearchNotifier].
  TrainRideSearchNotifierProvider(String query)
    : this._internal(
        () => TrainRideSearchNotifier()..query = query,
        from: trainRideSearchNotifierProvider,
        name: r'trainRideSearchNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainRideSearchNotifierHash,
        dependencies: TrainRideSearchNotifierFamily._dependencies,
        allTransitiveDependencies:
            TrainRideSearchNotifierFamily._allTransitiveDependencies,
        query: query,
      );

  TrainRideSearchNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  FutureOr<List<model.TrainRide>> runNotifierBuild(
    covariant TrainRideSearchNotifier notifier,
  ) {
    return notifier.build(query);
  }

  @override
  Override overrideWith(TrainRideSearchNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TrainRideSearchNotifierProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    TrainRideSearchNotifier,
    List<model.TrainRide>
  >
  createElement() {
    return _TrainRideSearchNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrainRideSearchNotifierProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TrainRideSearchNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<model.TrainRide>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _TrainRideSearchNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          TrainRideSearchNotifier,
          List<model.TrainRide>
        >
    with TrainRideSearchNotifierRef {
  _TrainRideSearchNotifierProviderElement(super.provider);

  @override
  String get query => (origin as TrainRideSearchNotifierProvider).query;
}

String _$rideTypesNotifierHash() => r'fef6ad2579adda6c13f34d20866f00643c0ddc9f';

/// See also [RideTypesNotifier].
@ProviderFor(RideTypesNotifier)
final rideTypesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      RideTypesNotifier,
      List<Map<String, dynamic>>
    >.internal(
      RideTypesNotifier.new,
      name: r'rideTypesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rideTypesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RideTypesNotifier =
    AutoDisposeAsyncNotifier<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
