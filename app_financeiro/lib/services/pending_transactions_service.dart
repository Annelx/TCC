import 'package:shared_preferences/shared_preferences.dart';

/// Guarda temporariamente o que o usuário digitou direto na notificação
/// (sem abrir o app), pra ser lido e transformado em transação de verdade
/// na próxima vez que o app abrir. Usa SharedPreferences porque precisa
/// funcionar mesmo com o app totalmente fechado (o toque na notificação
/// roda num isolate separado, sem acesso à memória do app rodando).
class PendingTransactionsService {
  static const _chave = 'transacoes_pendentes';

  static Future<void> adicionar(String textoDigitado) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_chave) ?? [];
    lista.add(textoDigitado);
    await prefs.setStringList(_chave, lista);
  }

  /// Lê tudo que foi adicionado via atalho e já limpa a fila.
  static Future<List<String>> pegarERemoverTodas() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_chave) ?? [];
    await prefs.remove(_chave);
    return lista;
  }
}