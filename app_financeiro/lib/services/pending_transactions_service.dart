import 'package:shared_preferences/shared_preferences.dart';

/// Guarda temporariamente o que o usuário digitou direto na notificação
/// (sem abrir o app), pra ser lido e transformado em transação de verdade
/// na próxima vez que o app abrir. Usa SharedPreferences porque precisa
/// funcionar mesmo com o app totalmente fechado (o toque na notificação
/// pode rodar num isolate separado, sem acesso à memória do app rodando).
class PendingTransactionsService {
  static const _chave = 'transacoes_pendentes';
  static const _chaveRascunho = 'transacao_rascunho';

  /// Transação completa (valor + categoria já preenchidos), aguardando
  /// o app abrir pra virar de fato uma transação na lista.
  static Future<void> adicionar(String textoCompleto) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_chave) ?? [];
    lista.add(textoCompleto);
    await prefs.setStringList(_chave, lista);
  }

  /// Lê tudo que foi adicionado via atalho e já limpa a fila.
  static Future<List<String>> pegarERemoverTodas() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_chave) ?? [];
    await prefs.remove(_chave);
    return lista;
  }

  // --- Rascunho de 2 passos: passo 1 salva tipo+valor, passo 2 pede a
  // categoria e só aí a transação vira completa. ---

  static Future<void> salvarRascunho(String tipo, String valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveRascunho, '$tipo|$valor');
  }

  /// Retorna (tipo, valor) do rascunho pendente, ou null se não houver.
  static Future<(String, String)?> pegarRascunho() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getString(_chaveRascunho);
    if (salvo == null) return null;
    final partes = salvo.split('|');
    if (partes.length < 2) return null;
    return (partes[0], partes[1]);
  }

  static Future<void> limparRascunho() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveRascunho);
  }
}