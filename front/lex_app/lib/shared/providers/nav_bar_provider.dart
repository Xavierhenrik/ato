import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modo de exibição da barra de navegação:
/// - expanded : pílula completa, centralizada na base (padrão).
/// - compact  : meio-círculo flutuante na borda direita (chat ativo no Tutor).
enum NavBarMode { expanded, compact }

final navBarModeProvider =
    StateProvider<NavBarMode>((ref) => NavBarMode.expanded);

/// Sinaliza se o speed-dial "mais" está aberto.
/// Usado pelo ScaffoldWithNav para exibir o barrier de tela cheia.
final navDialOpenProvider = StateProvider<bool>((ref) => false);
