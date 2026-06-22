// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authUserStreamHash() => r'61bf7eef905fc0e5b9b6b7f0952387916b56cdfb';

/// See also [authUserStream].
@ProviderFor(authUserStream)
final authUserStreamProvider = AutoDisposeStreamProvider<User?>.internal(
  authUserStream,
  name: r'authUserStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authUserStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthUserStreamRef = AutoDisposeStreamProviderRef<User?>;
String _$onboardingDoneHash() => r'0f6e6ec8cfc509b8334e7d1e9c3b814471087a0b';

/// See also [OnboardingDone].
@ProviderFor(OnboardingDone)
final onboardingDoneProvider = NotifierProvider<OnboardingDone, bool>.internal(
  OnboardingDone.new,
  name: r'onboardingDoneProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingDoneHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OnboardingDone = Notifier<bool>;
String _$authNotifierHash() => r'6f409909ea108a2dfc9dc89dba75a0915a9f843e';

/// Estado: null = idle | data(null) = signed-out | data(User) = signed-in
/// Mutations atualizam `state` para refletir loading/error na UI.
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AsyncValue<User?>>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AutoDisposeNotifier<AsyncValue<User?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
