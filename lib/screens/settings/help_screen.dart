import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _faqAberto = -1; // índice da FAQ aberta (-1 = nenhuma)

  final List<Map<String, String>> _faqs = [
    {
      'pergunta': 'Como adiciono um novo pet?',
      'resposta':
          'Na tela inicial, clique no card "Adicionar novo pet" com borda tracejada e preencha as informações solicitadas como nome, espécie, raça e data de nascimento.',
    },
    {
      'pergunta': 'Como configuro lembretes?',
      'resposta':
          'Acesse o perfil do seu pet e clique em "Adicionar lembrete". Escolha o tipo (vacina, banho, consulta, etc.), a data e a frequência de repetição desejada.',
    },
    {
      'pergunta': 'O assistente 4UPet é gratuito?',
      'resposta':
          'Sim! O assistente virtual está disponível gratuitamente para todos os usuários. Ele responde dúvidas sobre saúde animal usando uma base de conhecimento veterinária confiável.',
    },
    {
      'pergunta': 'Como uso o calendário de Agenda?',
      'resposta':
          'Na aba "Agenda", você vê um calendário mensal com os dias marcados em teal quando há lembretes. Clique em um dia para ver os detalhes dos lembretes.',
    },
    {
      'pergunta': 'Meus dados estão seguros?',
      'resposta':
          'Sim. Utilizamos o Supabase com criptografia e boas práticas de segurança. Suas informações pessoais e dos seus pets são armazenadas de forma protegida.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Ajuda e suporte',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              children: [
                // ✅ SEÇÃO 1: FAQ
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: const Color(0xFF0D9488),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Perguntas frequentes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_faqs.length, (index) {
                        final faq = _faqs[index];
                        final aberto = _faqAberto == index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _faqCard(
                            pergunta: faq['pergunta']!,
                            resposta: faq['resposta']!,
                            aberto: aberto,
                            onTap: () {
                              setState(() {
                                _faqAberto = aberto ? -1 : index;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ SEÇÃO 2: PRECISA DE AJUDA? (apenas email e chat)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.support_agent,
                            color: const Color(0xFF0D9488),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Precisa de ajuda?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _contactOption(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: 'suporte@4upet.com.br',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Abrindo email...'),
                              backgroundColor: Color(0xFF0D9488),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _contactOption(
                        icon: Icons.chat_bubble_outline,
                        title: 'Chat conosco',
                        subtitle: 'Fale com nossa equipe em tempo real',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chat em desenvolvimento'),
                              backgroundColor: Color(0xFF0D9488),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ SEÇÃO 3: DICA
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: const Color(0xFF0D9488),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Dica: Use o assistente 4UPet para tirar dúvidas rápidas sobre saúde animal sem sair do app!',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Card de FAQ com ícone de interrogação + resposta com background
  Widget _faqCard({
    required String pergunta,
    required String resposta,
    required bool aberto,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ✅ Background teal claro quando aberto
            color: aberto ? const Color(0xFFECFDF5) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: aberto
                  ? const Color(0xFF0D9488).withOpacity(0.3)
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha da pergunta
              Row(
                children: [
                  // ✅ Ícone de interrogação em círculo teal
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0D9488).withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Color(0xFF0D9488),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pergunta,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: aberto
                            ? const Color(0xFF0D9488)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ✅ Ícone de expandir/recolher
                  AnimatedRotation(
                    turns: aberto ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: aberto
                          ? const Color(0xFF0D9488)
                          : Colors.grey.shade500,
                      size: 22,
                    ),
                  ),
                ],
              ),
              // ✅ Resposta com animação
              if (aberto) ...[
                const SizedBox(height: 12),
                const Divider(
                  height: 1,
                  color: Color(0xFF0D9488),
                  thickness: 1,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 44), // alinha com o texto da pergunta
                    Expanded(
                      child: Text(
                        resposta,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Opção de contato
  Widget _contactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF0D9488), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
