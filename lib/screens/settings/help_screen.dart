import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Ajuda e suporte'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle('Perguntas frequentes'),
          const SizedBox(height: 12),
          _buildFAQItem(
            question: 'Como adiciono um novo pet?',
            answer:
                'Na tela inicial, clique no card "Adicionar novo pet" e preencha as informações solicitadas.',
          ),
          _buildFAQItem(
            question: 'Como configuro lembretes?',
            answer:
                'Acesse o perfil do seu pet e clique em "Adicionar lembrete". Escolha o tipo e a data desejada.',
          ),
          _buildFAQItem(
            question: 'O assistente 4UPet é gratuito?',
            answer:
                'Sim! O assistente virtual está disponível gratuitamente para todos os usuários.',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Precisa de ajuda?'),
          const SizedBox(height: 12),
          _buildContactOption(
            icon: Icons.email,
            title: 'Email',
            subtitle: 'suporte@4upet.com.br',
            onTap: () {
              // Abrir app de email
            },
          ),
          _buildContactOption(
            icon: Icons.chat,
            title: 'Chat ao vivo',
            subtitle: 'Fale conosco em tempo real',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat em desenvolvimento')),
              );
            },
          ),
          _buildContactOption(
            icon: Icons.phone,
            title: 'Telefone',
            subtitle: '(11) 4002-8922',
            onTap: () {
              // Abrir discador
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF0D9488), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
