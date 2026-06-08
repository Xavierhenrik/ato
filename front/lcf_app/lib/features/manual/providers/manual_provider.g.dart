// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$manualTopicsHash() => r'e87ecc7076f2cd3f83ff31bd3adee4e344aa4863';

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

/// See also [manualTopics].
@ProviderFor(manualTopics)
const manualTopicsProvider = ManualTopicsFamily();

/// See also [manualTopics].
class ManualTopicsFamily extends Family<AsyncValue<List<Topic>>> {
  /// See also [manualTopics].
  const ManualTopicsFamily();

  /// See also [manualTopics].
  ManualTopicsProvider call({
    String? lawCode,
  }) {
    return ManualTopicsProvider(
      lawCode: lawCode,
    );
  }

  @override
  ManualTopicsProvider getProviderOverride(
    covariant ManualTopicsProvider provider,
  ) {
    return call(
      lawCode: provider.lawCode,
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
  String? get name => r'manualTopicsProvider';
}

/// See also [manualTopics].
class ManualTopicsProvider extends AutoDisposeFutureProvider<List<Topic>> {
  /// See also [manualTopics].
  ManualTopicsProvider({
    String? lawCode,
  }) : this._internal(
          (ref) => manualTopics(
            ref as ManualTopicsRef,
            lawCode: lawCode,
          ),
          from: manualTopicsProvider,
          name: r'manualTopicsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$manualTopicsHash,
          dependencies: ManualTopicsFamily._dependencies,
          allTransitiveDependencies:
              ManualTopicsFamily._allTransitiveDependencies,
          lawCode: lawCode,
        );

  ManualTopicsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lawCode,
  }) : super.internal();

  final String? lawCode;

  @override
  Override overrideWith(
    FutureOr<List<Topic>> Function(ManualTopicsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ManualTopicsProvider._internal(
        (ref) => create(ref as ManualTopicsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lawCode: lawCode,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Topic>> createElement() {
    return _ManualTopicsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ManualTopicsProvider && other.lawCode == lawCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lawCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ManualTopicsRef on AutoDisposeFutureProviderRef<List<Topic>> {
  /// The parameter `lawCode` of this provider.
  String? get lawCode;
}

class _ManualTopicsProviderElement
    extends AutoDisposeFutureProviderElement<List<Topic>> with ManualTopicsRef {
  _ManualTopicsProviderElement(super.provider);

  @override
  String? get lawCode => (origin as ManualTopicsProvider).lawCode;
}

String _$manualTopicDetailHash() => r'd34bcac684e1d37bceb6b695592fba76d4b1f767';

/// See also [manualTopicDetail].
@ProviderFor(manualTopicDetail)
const manualTopicDetailProvider = ManualTopicDetailFamily();

/// See also [manualTopicDetail].
class ManualTopicDetailFamily extends Family<AsyncValue<TopicDetail>> {
  /// See also [manualTopicDetail].
  const ManualTopicDetailFamily();

  /// See also [manualTopicDetail].
  ManualTopicDetailProvider call(
    String id,
  ) {
    return ManualTopicDetailProvider(
      id,
    );
  }

  @override
  ManualTopicDetailProvider getProviderOverride(
    covariant ManualTopicDetailProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'manualTopicDetailProvider';
}

/// See also [manualTopicDetail].
class ManualTopicDetailProvider extends AutoDisposeFutureProvider<TopicDetail> {
  /// See also [manualTopicDetail].
  ManualTopicDetailProvider(
    String id,
  ) : this._internal(
          (ref) => manualTopicDetail(
            ref as ManualTopicDetailRef,
            id,
          ),
          from: manualTopicDetailProvider,
          name: r'manualTopicDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$manualTopicDetailHash,
          dependencies: ManualTopicDetailFamily._dependencies,
          allTransitiveDependencies:
              ManualTopicDetailFamily._allTransitiveDependencies,
          id: id,
        );

  ManualTopicDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<TopicDetail> Function(ManualTopicDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ManualTopicDetailProvider._internal(
        (ref) => create(ref as ManualTopicDetailRef),
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
  AutoDisposeFutureProviderElement<TopicDetail> createElement() {
    return _ManualTopicDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ManualTopicDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ManualTopicDetailRef on AutoDisposeFutureProviderRef<TopicDetail> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ManualTopicDetailProviderElement
    extends AutoDisposeFutureProviderElement<TopicDetail>
    with ManualTopicDetailRef {
  _ManualTopicDetailProviderElement(super.provider);

  @override
  String get id => (origin as ManualTopicDetailProvider).id;
}

String _$manualSearchHash() => r'df867acf6f62cb478f7f3eacbfb26ffe0a22c84f';

/// See also [manualSearch].
@ProviderFor(manualSearch)
const manualSearchProvider = ManualSearchFamily();

/// See also [manualSearch].
class ManualSearchFamily extends Family<AsyncValue<List<ManualSearchResult>>> {
  /// See also [manualSearch].
  const ManualSearchFamily();

  /// See also [manualSearch].
  ManualSearchProvider call(
    String q,
  ) {
    return ManualSearchProvider(
      q,
    );
  }

  @override
  ManualSearchProvider getProviderOverride(
    covariant ManualSearchProvider provider,
  ) {
    return call(
      provider.q,
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
  String? get name => r'manualSearchProvider';
}

/// See also [manualSearch].
class ManualSearchProvider
    extends AutoDisposeFutureProvider<List<ManualSearchResult>> {
  /// See also [manualSearch].
  ManualSearchProvider(
    String q,
  ) : this._internal(
          (ref) => manualSearch(
            ref as ManualSearchRef,
            q,
          ),
          from: manualSearchProvider,
          name: r'manualSearchProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$manualSearchHash,
          dependencies: ManualSearchFamily._dependencies,
          allTransitiveDependencies:
              ManualSearchFamily._allTransitiveDependencies,
          q: q,
        );

  ManualSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.q,
  }) : super.internal();

  final String q;

  @override
  Override overrideWith(
    FutureOr<List<ManualSearchResult>> Function(ManualSearchRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ManualSearchProvider._internal(
        (ref) => create(ref as ManualSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        q: q,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ManualSearchResult>> createElement() {
    return _ManualSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ManualSearchProvider && other.q == q;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, q.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ManualSearchRef
    on AutoDisposeFutureProviderRef<List<ManualSearchResult>> {
  /// The parameter `q` of this provider.
  String get q;
}

class _ManualSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<ManualSearchResult>>
    with ManualSearchRef {
  _ManualSearchProviderElement(super.provider);

  @override
  String get q => (origin as ManualSearchProvider).q;
}

String _$filteredTopicsHash() => r'13d627fca7e12a1b26d340ce02932c0d9b496710';

/// See also [filteredTopics].
@ProviderFor(filteredTopics)
final filteredTopicsProvider = AutoDisposeFutureProvider<List<Topic>>.internal(
  filteredTopics,
  name: r'filteredTopicsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredTopicsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredTopicsRef = AutoDisposeFutureProviderRef<List<Topic>>;
String _$selectedLawCodeHash() => r'be9ebb770cada7210b1ec4f4e91f459dc3f635d0';

/// See also [SelectedLawCode].
@ProviderFor(SelectedLawCode)
final selectedLawCodeProvider =
    AutoDisposeNotifierProvider<SelectedLawCode, String?>.internal(
  SelectedLawCode.new,
  name: r'selectedLawCodeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedLawCodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedLawCode = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
