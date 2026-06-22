import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/perfil_models.dart';
import '../data/perfil_repository.dart';

part 'perfil_provider.g.dart';

@riverpod
Future<UserProfile> perfilData(PerfilDataRef ref) =>
    ref.watch(perfilRepositoryProvider).getProfile();

@riverpod
Future<Offerings?> offerings(OfferingsRef ref) async {
  try {
    return await Purchases.getOfferings();
  } catch (_) {
    return null;
  }
}
