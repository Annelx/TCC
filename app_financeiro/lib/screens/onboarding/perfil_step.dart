import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'onboarding_step_scaffold.dart';

/// Passo 1 do onboarding: "Vamos começar com seu perfil"
class PerfilStep extends StatefulWidget {
  final String apelidoInicial;
  final String emailInicial;
  final VoidCallback? onVoltar;
  final void Function(String apelido, String email, File? foto) onContinuar;

  const PerfilStep({
    super.key,
    this.apelidoInicial = '',
    this.emailInicial = '',
    this.onVoltar,
    required this.onContinuar,
  });

  @override
  State<PerfilStep> createState() => _PerfilStepState();
}

class _PerfilStepState extends State<PerfilStep> {
  final _formKey = GlobalKey<FormState>();
  late final _apelidoController =
      TextEditingController(text: widget.apelidoInicial);
  late final _emailController =
      TextEditingController(text: widget.emailInicial);

  File? _fotoPerfil;

  @override
  void dispose() {
    _apelidoController.dispose();
    _emailController.dispose();
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
    setState(() => _fotoPerfil = File(imagem.path));
  }

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;
    widget.onContinuar(
      _apelidoController.text.trim(),
      _emailController.text.trim(),
      _fotoPerfil,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      icone: Icons.person_outline,
      titulo: 'Vamos começar com seu perfil',
      subtitulo:
          'Essas informações são básicas, mas importantes para personalizar sua experiência.',
      passoAtual: 1,
      totalPassos: 7,
      onVoltar: widget.onVoltar,
      footer: ElevatedButton(
        onPressed: _continuar,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Continuar'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Foto de perfil
            Center(
              child: GestureDetector(
                onTap: _escolherFoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: const Color(0xFF1A1A1A),
                      backgroundImage:
                          _fotoPerfil != null ? FileImage(_fotoPerfil!) : null,
                      child: _fotoPerfil == null
                          ? const Icon(Icons.person,
                              size: 40, color: Colors.white38)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: OnboardingStepScaffold.roxo,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
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
                child: Text(_fotoPerfil == null
                    ? 'Adicionar foto de perfil'
                    : 'Trocar foto'),
              ),
            ),
            const SizedBox(height: 16),

            // Apelido (em vez de nome completo)
            TextFormField(
              controller: _apelidoController,
              keyboardType: TextInputType.name,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Apelido',
                helperText: 'Como você quer ser chamado no app',
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

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe seu e-mail';
                }
                final regexEmail = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
                if (!regexEmail.hasMatch(value)) {
                  return 'E-mail inválido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}