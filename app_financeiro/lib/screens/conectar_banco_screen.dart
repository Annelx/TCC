import 'package:flutter/material.dart';
import '../models/conta_bancaria_model.dart';

/// Tela "Conectar novo banco" — simula o fluxo do Pluggy Connect.
///
/// QUANDO INTEGRAR DE VERDADE (anotações pro Luís):
/// A Pluggy não tem SDK Flutter oficial — a integração real é feita
/// carregando a URL do "Pluggy Connect" dentro de um WebView
/// (pacote `webview_flutter`). O fluxo passa a ser:
///   1. O back-end gera um "connect token" (chamada à API da Pluggy)
///   2. O app abre um WebView com a URL do Pluggy Connect + esse token
///   3. O usuário escolhe o banco e faz login DENTRO do widget deles
///      (o app nunca vê a senha do banco)
///   4. Ao concluir, a Pluggy chama um callback/redirect que o WebView
///      detecta, e o back-end busca as contas/transações via API
/// Essa tela abaixo simula esses passos 3 e 4 com uma lista fixa de bancos
/// e um "login" fake, só pra manter a experiência de usuário pronta.
class ConectarBancoScreen extends StatefulWidget {
  const ConectarBancoScreen({super.key});

  @override
  State<ConectarBancoScreen> createState() => _ConectarBancoScreenState();
}

class _ConectarBancoScreenState extends State<ConectarBancoScreen> {
  static const roxo = Color(0xFF8A2BE2);

  static const _bancos = [
    ('Nubank', Icons.credit_card),
    ('Banco do Brasil', Icons.account_balance),
    ('Itaú', Icons.account_balance),
    ('Bradesco', Icons.account_balance),
    ('Caixa Econômica', Icons.account_balance),
    ('Inter', Icons.account_balance_wallet_outlined),
  ];

  String? _bancoConectando;

  Future<void> _conectar(String banco) async {
    setState(() => _bancoConectando = banco);

    // TODO: aqui entra a abertura do WebView com o Pluggy Connect de verdade
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.of(context).pop(
      ContaBancaria(
        nomeBanco: banco,
        tipoConta: 'Conta corrente',
        saldo: 0,
        ultimaSincronizacao: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conectando = _bancoConectando != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Conectar banco')),
      body: SafeArea(
        child: conectando
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: roxo),
                    const SizedBox(height: 20),
                    Text(
                      'Conectando ao $_bancoConectando...',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Isso normalmente abriria o login oficial do banco',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: roxo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.security, color: roxo, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Seus dados bancários são protegidos e você pode desconectar a qualquer momento.',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Selecione seu banco',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ..._bancos.map((banco) {
                    final (nome, icone) = banco;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () => _conectar(nome),
                        leading: Icon(icone, color: roxo),
                        title: Text(nome, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}