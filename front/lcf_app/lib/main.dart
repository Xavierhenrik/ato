import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://YOUR_PROJECT.supabase.co',
);

const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'YOUR_ANON_KEY',
);

const _revenueCatAppleKey = String.fromEnvironment(
  'REVENUECAT_APPLE_API_KEY',
  defaultValue: '',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX: intercepta o canal flutter/navigation antes do GoRouter ser criado.
  //
  // Problema raiz: ao voltar do OAuth, o Android dispara onNewIntent com a URI
  // com.lcf.app://auth-callback?code=... O FlutterActivity envia essa URI para
  // o canal 'flutter/navigation' via pushRouteInformation. O GoRouter tenta
  // calcular uri.origin — que lança StateError para esquemas não-http/https —
  // e corrompe _routeInformationProvider._value permanentemente. Todo
  // notifyListeners() subsequente re-entra no parser quebrado e lança de novo,
  // então o redirect nunca dispara mesmo com a sessão estabelecida.
  //
  // Solução: URIs de esquema customizado são silenciadas aqui. O supabase_flutter
  // já recebe o deep link pelo app_links EventChannel (caminho correto).
  // O popRoute (botão voltar do Android) é encaminhado normalmente.
  SystemChannels.navigation.setMethodCallHandler((call) async {
    if (call.method == 'popRoute') {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      return WidgetsBinding.instance.handlePopRoute();
    }
    if (call.method == 'pushRoute' || call.method == 'pushRouteInformation') {
      final String? location = call.method == 'pushRoute'
          ? call.arguments as String?
          : (call.arguments as Map<Object?, Object?>?)
              ?['location'] as String?;
      if (location != null) {
        final uri = Uri.tryParse(location);
        if (uri != null && uri.scheme != 'http' && uri.scheme != 'https') {
          // URI de esquema customizado — tratada pelo supabase_flutter via
          // app_links. Não encaminhar ao GoRouter.
          return null;
        }
      }
    }
    return null;
  });

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  if (_revenueCatAppleKey.isNotEmpty) {
    await Purchases.configure(PurchasesConfiguration(_revenueCatAppleKey));
  }

  runApp(const ProviderScope(child: App()));
}
