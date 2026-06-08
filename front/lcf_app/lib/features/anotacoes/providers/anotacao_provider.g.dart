// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anotacao_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$anotacoesHash() => r'dc8dfb64bf4e98ea2d15174552a1ac69d53949e8';

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

/// See also [anotacoes].
@ProviderFor(anotacoes)
const anotacoesProvider = AnotacoesFamily();

/// See also [anotacoes].
class AnotacoesFamily extends Family<AsyncValue<List<Anotacao>>> {
  /// See also [anotacoes].
  const AnotacoesFamily();

  /// See also [anotacoes].
  AnotacoesProvider call({
    String? subject,
    String? q,
  }) {
    return AnotacoesProvider(
      subject: subject,
      q: q,
    );
  }

  @override
  AnotacoesProvider getProviderOverride(
    covariant AnotacoesProvider provider,
  ) {
    return call(
      subject: provider.subject,
      q: provider.q,
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
  String? get name => r'anotacoesProvider';
}

/// See also [anotacoes].
class AnotacoesProvider extends AutoDisposeFutureProvider<List<Anotacao>> {
  /// See also [anotacoes].
  AnotacoesProvider({
    String? subject,
    String? q,
  }) : this._internal(
          (ref) => anotacoes(
            ref as AnotacoesRef,
            subject: subject,
            q: q,
          ),
          from: anotacoesProvider,
          name: r'anotacoesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$anotacoesHash,
          dependencies: AnotacoesFamily._dependencies,
          allTransitiveDependencies: AnotacoesFamily._allTransitiveDependencies,
          subject: subject,
          q: q,
        );

  AnotacoesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subject,
    required this.q,
  }) : super.internal();

  final String? subject;
  final String? q;

  @override
  Override overrideWith(
    FutureOr<List<Anotacao>> Function(AnotacoesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnotacoesProvider._internal(
        (ref) => create(ref as AnotacoesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subject: subject,
        q: q,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Anotacao>> createElement() {
    return _AnotacoesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnotacoesProvider &&
        other.subject == subject &&
        other.q == q;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subject.hashCode);
    hash = _SystemHash.combine(hash, q.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AnotacoesRef on AutoDisposeFutureProviderRef<List<Anotacao>> {
  /// The parameter `subject` of this provider.
  String? get subject;

  /// The parameter `q` of this provider.
  String? get q;
}

class _AnotacoesProviderElement
    extends AutoDisposeFutureProviderElement<List<Anotacao>> with AnotacoesRef {
  _AnotacoesProviderElement(super.provider);

  @override
  String? get subject => (origin as AnotacoesProvider).subject;
  @override
  String? get q => (origin as AnotacoesProvider).q;
}

String _$selectedSubjectFilterHash() =>
    r'f334d4d06f500a75825f36620d164c46278caf95';

/// Currently selected subject for filter chips (null = "Todas").
///
/// Copied from [SelectedSubjectFilter].
@ProviderFor(SelectedSubjectFilter)
final selectedSubjectFilterProvider =
    AutoDisposeNotifierProvider<SelectedSubjectFilter, String?>.internal(
  SelectedSubjectFilter.new,
  name: r'selectedSubjectFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSubjectFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSubjectFilter = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
