import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Resultado devolvido pela tela de edição de perfil. Email e telefone só
/// mudam de verdade pela tela de Segurança (com confirmação) — aqui eles
/// só aparecem travados, de referência.
class PerfilAtualizado {
  final String apelido;
  final File? foto;

  const PerfilAtualizado({
    required this.apelido,
    this.foto,
  });
}

/// Tela "Editar perfil" — permite trocar apelido e foto. E-mail e telefone
/// ficam bloqueados aqui por segurança; a alteração deles é feita em
/// Menu > Segurança, com confirmação do valor atual.
class EditProfileScreen extends StatefulWidget {
  final String apelidoAtual;
  final String emailAtual;
  final String? telefoneAtual;
  final String? fotoAtualPath;

  const EditProfileScreen({
    super.key,
    required this.apelidoAtual,
    required this.emailAtual,
    this.telefoneAtual,
    this.fotoAtualPath,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const roxo = Color(0xFF8A2BE2);

  final _formKey = GlobalKey<FormState>();
  late final _apelidoController = TextEditingController(text: widget.apelidoAtual);
  File? _fotoNova;
  bool _salvando = false;

  @override
  void dispose() {
    _apelidoController.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto() async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (imagem == null) return;
    setState(() => _fotoNova = File(imagem.path));
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    // TODO: enviar os dados pro back-end quando o Luís tiver o endpoint
    // pronto (ex: PUT /perfil).
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() => _salvando = false);

    Navigator.of(context).pop(
      PerfilAtualizado(
        apelido: _apelidoController.text.trim(),
        foto: _fotoNova,
      ),
    );
  }

  ImageProvider? get _imagemAtual {
    if (_fotoNova != null) return FileImage(_fotoNova!);
    if (widget.fotoAtualPath != null) return FileImage(File(widget.fotoAtualPath!));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _escolherFoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: const Color(0xFF1A1A1A),
                          backgroundImage: _imagemAtual,
                          child: _imagemAtual == null
                              ? const Icon(Icons.person, size: 40, color: Colors.white38)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: roxo,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _escolherFoto,
                    child: const Text('Trocar foto'),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _apelidoController,
                  decoration: const InputDecoration(
                    labelText: 'Apelido',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe um apelido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // E-mail — travado. Alteração só em Menu > Segurança.
                TextFormField(
                  initialValue: widget.emailAtual,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                    suffixIcon: Icon(Icons.lock_outline, size: 18),
                    border: OutlineInputBorder(),
                    helperText: 'Para alterar, vá em Menu > Segurança',
                  ),
                ),
                const SizedBox(height: 16),

                // Telefone — travado. Alteração só em Menu > Segurança.
                TextFormField(
                  initialValue: widget.telefoneAtual ?? '',
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    prefixIcon: Icon(Icons.phone_outlined),
                    suffixIcon: Icon(Icons.lock_outline, size: 18),
                    border: OutlineInputBorder(),
                    helperText: 'Para alterar, vá em Menu > Segurança',
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _salvando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar alterações'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}