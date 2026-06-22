// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tutorHistoryNotifierHash() =>
    r'89a32c95da8046933d290ec45c18d6d1fb31e702';

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

abstract class _$TutorHistoryNotifier
    extends BuildlessAutoDisposeAsyncNotifier<TutorHistoryState> {
  late final String mode;

  FutureOr<TutorHistoryState> build(
    String mode,
  );
}

/// Provider da lista de histórico. Recebe o [mode] como parâmetro ('direct' | 'reading').
/// Usa paginação por cursor. Suporta carga incremental e delete otimista.
///
/// Copied from [TutorHistoryNotifier].
@ProviderFor(TutorHistoryNotifier)
const tutorHistoryNotifierProvider = TutorHistoryNotifierFamily();

/// Provider da lista de histórico. Recebe o [mode] como parâmetro ('direct' | 'reading').
/// Usa paginação por cursor. Suporta carga incremental e delete otimista.
///
/// Copied from [TutorHistoryNotifier].
class TutorHistoryNotifierFamily extends Family<AsyncValue<TutorHistoryState>> {
  /// Provider da lista de histórico. Recebe o [mode] como parâmetro ('direct' | 'reading').
  /// Usa paginação por cursor. Suporta carga incremental e delete otimista.
  ///
  /// Copied from [TutorHistoryNotifier].
  const TutorHistoryNotifierFamily();

  /// Provider da lista de histórico. Recebe o [mode] como parâmetro ('direct' | 'reading').
  /// Usa paginação por cursor. Suporta carga incremental e delete otimista.
  ///
  /// Copied from [TutorHistoryNotifier].
  TutorHistoryNotifierProvider call(
    String mode,
  ) {
    return TutorHistoryNotifierProvider(
      mode,
    );
  }

  @override
  TutorHistoryNotifierProvider getProviderOverride(
    covariant TutorHistoryNotifierProvider provider,
  ) {
    return call(
      provider.mode,
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
  String? get name => r'tutorHistoryNotifierProvider';
}

/// Provider da lista de histórico. Recebe o [mode] como parâmetro ('direct' | 'reading').
/// Usa paginação por cursor. Suporta carga incremental e delete otimista.
///
/// Copied from [TutorHistoryNotifier].
class TutorHistoryNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    TutorHistoryNotifier, TutorHistoryState> {
  /// Provider da lista de histórico. Recebe o [mode] como parâmetro ('direct' | 'reading').
  /// Usa paginação por cursor. Suporta carga incremental e delete otimista.
  ///
  /// Copied from [TutorHistoryNotifier].
  TutorHistoryNotifierProvider(
    String mode,
  ) : this._internal(
          () => TutorHistoryNotifier()..mode = mode,
          from: tutorHistoryNotifierProvider,
          name: r'tutorHistoryNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tutorHistoryNotifierHash,
          dependencies: TutorHistoryNotifierFamily._dependencies,
          allTransitiveDependencies:
              TutorHistoryNotifierFamily._allTransitiveDependencies,
          mode: mode,
        );

  TutorHistoryNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mode,
  }) : super.internal();

  final String mode;

  @override
  FutureOr<TutorHistoryState> runNotifierBuild(
    covariant TutorHistoryNotifier notifier,
  ) {
    return notifier.build(
      mode,
    );
  }

  @override
  Override overrideWith(TutorHistoryNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TutorHistoryNotifierProvider._internal(
        () => create()..mode = mode,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mode: mode,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<TutorHistoryNotifier,
      TutorHistoryState> createElement() {
    return _TutorHistoryNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TutorHistoryNotifierProvider && other.mode == mode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TutorHistoryNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<TutorHistoryState> {
  /// The parameter `mode` of this provider.
  String get mode;
}

class _TutorHistoryNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TutorHistoryNotifier,
        TutorHistoryState> with TutorHistoryNotifierRef {
  _TutorHistoryNotifierProviderElement(super.provider);

  @override
  String get mode => (origin as TutorHistoryNotifierProvider).mode;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
