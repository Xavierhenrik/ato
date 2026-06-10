import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
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

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Fallback: processa deep links OAuth explicitamente caso supabase_flutter
  // não capture via seu listener interno (problema conhecido em Android com
  // Chrome Custom Tabs + singleTop).
  AppLinks().uriLinkStream.listen((uri) async {
    final hasCode = uri.queryParameters.containsKey('code');
    final hasToken = uri.fragment.contains('access_token');
    if (hasCode || hasToken) {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      } catch (_) {
        // Silencia: código já trocado pelo handler interno ou estado inválido.
      }
    }
  });

  if (_revenueCatAppleKey.isNotEmpty) {
    await Purchases.configure(PurchasesConfiguration(_revenueCatAppleKey));
  }

  runApp(const ProviderScope(child: App()));
}
