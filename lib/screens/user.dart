import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProfileScreen(),
  ));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Cor principal usada nos ícones (Vermelho Escuro)
  final Color darkRed = const Color(0xFF8B0000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo cinza bem claro (quase branco) conforme a imagem
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Botão de Voltar
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: darkRed, size: 30),
                onPressed: () {
                  // Ação de voltar
                },
              ),

              const SizedBox(height: 10),

              // 2. Área do Perfil (Foto + Botões Laterais)
              SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    // Foto e Nome Centralizados
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 90,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "CleitonMaster",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botões Laterais (Direita)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSideButton(Icons.edit, darkRed, Colors.white, () {}),
                          // Botão de Deletar com Ação para abrir o Dialog
                          _buildSideButton(Icons.delete, darkRed, Colors.white, () {
                            _showDeleteDialog(context);
                          }),
                          _buildSideButton(Icons.star, darkRed, Colors.amber, () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 3. Informações do Usuário
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Função:", "Administrador", valueColor: Colors.red[400]),
                    const SizedBox(height: 20),
                    _buildInfoRow("Telefone:", "62 5485-5415"),
                    const SizedBox(height: 20),
                    _buildInfoRow("E-mail:", "Cleiton00sim@gmail.com"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para os botões laterais (Editar, Excluir, Favoritar)
  Widget _buildSideButton(IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }

  // Widget auxiliar para as linhas de texto (Função, Telefone, Email)
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 18, color: Colors.black),
        children: [
          TextSpan(
            text: "$label ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: valueColor ?? Colors.black87, // Se não passar cor, usa preto
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Função para mostrar o Dialog Preto
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black, // Fundo preto
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Certeza que deseja\nexcluir esse perfil?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    // Lógica para Sim
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Sim",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fecha o dialog
                  },
                  child: const Text(
                    "Não",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}