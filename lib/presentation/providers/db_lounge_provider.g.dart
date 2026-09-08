// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_lounge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dbLoungeVisitCountHash() =>
    r'6750803180f408ed09821537e9bab2391a965da3';

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

/// See also [dbLoungeVisitCount].
@ProviderFor(dbLoungeVisitCount)
const dbLoungeVisitCountProvider = DbLoungeVisitCountFamily();

/// See also [dbLoungeVisitCount].
class DbLoungeVisitCountFamily extends Family<AsyncValue<int>> {
  /// See also [dbLoungeVisitCount].
  const DbLoungeVisitCountFamily();

  /// See also [dbLoungeVisitCount].
  DbLoungeVisitCountProvider call(int loungeId) {
    return DbLoungeVisitCountProvider(loungeId);
  }

  @override
  DbLoungeVisitCountProvider getProviderOverride(
    covariant DbLoungeVisitCountProvider provider,
  ) {
    return call(provider.loungeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dbLoungeVisitCountProvider';
}

/// See also [dbLoungeVisitCount].
class DbLoungeVisitCountProvider extends AutoDisposeFutureProvider<int> {
  /// See also [dbLoungeVisitCount].
  DbLoungeVisitCountProvider(int loungeId)
    : this._internal(
        (ref) => dbLoungeVisitCount(ref as DbLoungeVisitCountRef, loungeId),
        from: dbLoungeVisitCountProvider,
        name: r'dbLoungeVisitCountProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$dbLoungeVisitCountHash,
        dependencies: DbLoungeVisitCountFamily._dependencies,
        allTransitiveDependencies:
            DbLoungeVisitCountFamily._allTransitiveDependencies,
        loungeId: loungeId,
      );

  DbLoungeVisitCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.loungeId,
  }) : super.internal();

  final int loungeId;

  @override
  Override overrideWith(
    FutureOr<int> Function(DbLoungeVisitCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DbLoungeVisitCountProvider._internal(
        (ref) => create(ref as DbLoungeVisitCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        loungeId: loungeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _DbLoungeVisitCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DbLoungeVisitCountProvider && other.loungeId == loungeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, loungeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DbLoungeVisitCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `loungeId` of this provider.
  int get loungeId;
}

class _DbLoungeVisitCountProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with DbLoungeVisitCountRef {
  _DbLoungeVisitCountProviderElement(super.provider);

  @override
  int get loungeId => (origin as DbLoungeVisitCountProvider).loungeId;
}

String _$dbLoungeVisitCountsHash() =>
    r'00aa17001fea198eedfa523410059d9625693557';

/// See also [dbLoungeVisitCounts].
@ProviderFor(dbLoungeVisitCounts)
final dbLoungeVisitCountsProvider =
    AutoDisposeFutureProvider<Map<int, int>>.internal(
      dbLoungeVisitCounts,
      name: r'dbLoungeVisitCountsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dbLoungeVisitCountsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DbLoungeVisitCountsRef = AutoDisposeFutureProviderRef<Map<int, int>>;
String _$dbLoungesNotifierHash() => r'bb63dccb1780f5826064806433d54bdf36e2e917';

/// See also [DbLoungesNotifier].
@ProviderFor(DbLoungesNotifier)
final dbLoungesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      DbLoungesNotifier,
      List<DbLounge>
    >.internal(
      DbLoungesNotifier.new,
      name: r'dbLoungesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dbLoungesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DbLoungesNotifier = AutoDisposeAsyncNotifier<List<DbLounge>>;
String _$dbLoungeVisitsNotifierHash() =>
    r'3a8f2a0ba0d4f904c90c2badef2b3027a743896b';

/// See also [DbLoungeVisitsNotifier].
@ProviderFor(DbLoungeVisitsNotifier)
final dbLoungeVisitsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      DbLoungeVisitsNotifier,
      List<DbLoungeVisit>
    >.internal(
      DbLoungeVisitsNotifier.new,
      name: r'dbLoungeVisitsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dbLoungeVisitsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DbLoungeVisitsNotifier =
    AutoDisposeAsyncNotifier<List<DbLoungeVisit>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
