// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulado_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$simuladoHistoryHash() => r'b271798097e23f99fcce695ae2fed0afd87ee5c5';

/// See also [simuladoHistory].
@ProviderFor(simuladoHistory)
final simuladoHistoryProvider =
    AutoDisposeFutureProvider<List<SimuladoHistoryItem>>.internal(
  simuladoHistory,
  name: r'simuladoHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$simuladoHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SimuladoHistoryRef
    = AutoDisposeFutureProviderRef<List<SimuladoHistoryItem>>;
String _$simuladoResultHash() => r'aeda099ec469bc7dc36bdcfd9dc88401569abf81';

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

/// See also [simuladoResult].
@ProviderFor(simuladoResult)
const simuladoResultProvider = SimuladoResultFamily();

/// See also [simuladoResult].
class SimuladoResultFamily extends Family<AsyncValue<SimuladoResult>> {
  /// See also [simuladoResult].
  const SimuladoResultFamily();

  /// See also [simuladoResult].
  SimuladoResultProvider call(
    String simuladoId,
  ) {
    return SimuladoResultProvider(
      simuladoId,
    );
  }

  @override
  SimuladoResultProvider getProviderOverride(
    covariant SimuladoResultProvider provider,
  ) {
    return call(
      provider.simuladoId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'simuladoResultProvider';
}

/// See also [simuladoResult].
class SimuladoResultProvider extends AutoDisposeFutureProvider<SimuladoResult> {
  /// See also [simuladoResult].
  SimuladoResultProvider(
    String simuladoId,
  ) : this._internal(
          (ref) => simuladoResult(
            ref as SimuladoResultRef,
            simuladoId,
          ),
          from: simuladoResultProvider,
          name: r'simuladoResultProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$simuladoResultHash,
          dependencies: SimuladoResultFamily._dependencies,
          allTransitiveDependencies:
              SimuladoResultFamily._allTransitiveDependencies,
          simuladoId: simuladoId,
        );

  SimuladoResultProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.simuladoId,
  }) : super.internal();

  final String simuladoId;

  @override
  Override overrideWith(
    FutureOr<SimuladoResult> Function(SimuladoResultRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SimuladoResultProvider._internal(
        (ref) => create(ref as SimuladoResultRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        simuladoId: simuladoId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SimuladoResult> createElement() {
    return _SimuladoResultProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SimuladoResultProvider && other.simuladoId == simuladoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, simuladoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SimuladoResultRef on AutoDisposeFutureProviderRef<SimuladoResult> {
  /// The parameter `simuladoId` of this provider.
  String get simuladoId;
}

class _SimuladoResultProviderElement
    extends AutoDisposeFutureProviderElement<SimuladoResult>
    with SimuladoResultRef {
  _SimuladoResultProviderElement(super.provider);

  @override
  String get simuladoId => (origin as SimuladoResultProvider).simuladoId;
}

String _$simuladoUserPlanHash() => r'6f4e7b3ebd6fee9d08fc8ad593222a59a43321c9';

/// User plan for gating UI. Falls back to 'free' on error.
///
/// Copied from [simuladoUserPlan].
@ProviderFor(simuladoUserPlan)
final simuladoUserPlanProvider = AutoDisposeFutureProvider<String>.internal(
  simuladoUserPlan,
  name: r'simuladoUserPlanProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$simuladoUserPlanHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SimuladoUserPlanRef = AutoDisposeFutureProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
