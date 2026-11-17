import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/legal_screen.dart'; // Ajuste o caminho se estiver em pasta diferente

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Sobre o app',
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
                // ✅ CARD 1: IDENTIDADE DO APP
                _buildIdentityCard(),
                const SizedBox(height: 20),

                // ✅ CARD 2: SOBRE
                _buildAboutCard(),
                const SizedBox(height: 20),

                // ✅ CARD 3: FUNCIONALIDADES
                _buildFeaturesCard(),
                const SizedBox(height: 20),

                // ✅ CARD 4: EQUIPE
                _buildTeamCard(),
                const SizedBox(height: 20),

                // ✅ CARD 5: LINKS (Com integração à sua LegalScreen e Flaticon)
                _buildLinksCard(context),
                const SizedBox(height: 20),

                // ✅ COPYRIGHT
                Text(
                  '© 2026 4UPet. Todos os direitos reservados.',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Desenvolvido visando o melhor para o seu pet',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // WIDGETS DOS CARDS (Mantidos do seu design original)
  // =========================================================================

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: const Column(
        children: [
          Icon(Icons.pets, color: Color(0xFF0D9488), size: 48),
          SizedBox(height: 16),
          Text(
            '4UPet',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D9488),
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'Versão 1.0.0',
              style: TextStyle(
                color: Color(0xFF0D9488),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Cuidando de quem você ama! 🐾',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
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
              const Icon(
                Icons.info_outline,
                color: Color(0xFF0D9488),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sobre o 4UPet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'O 4UPet é um aplicativo completo para gerenciamento da saúde e bem-estar do seu pet. Com lembretes inteligentes, assistente veterinário virtual com IA e controle de vacinas e consultas, cuidamos do seu melhor amigo.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Container(
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
              const Icon(
                Icons.star_outline,
                color: Color(0xFF0D9488),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Funcionalidades',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _featureItem(icon: Icons.pets, text: 'Cadastro de múltiplos pets'),
          const Divider(height: 1, indent: 36),
          _featureItem(
            icon: Icons.notifications_active,
            text: 'Lembretes inteligentes com recorrência',
          ),
          const Divider(height: 1, indent: 36),
          _featureItem(
            icon: Icons.smart_toy,
            text: 'Assistente veterinário com IA (RAG)',
          ),
          const Divider(height: 1, indent: 36),
          _featureItem(
            icon: Icons.calendar_today,
            text: 'Calendário de cuidados mensal',
          ),
          const Divider(height: 1, indent: 36),
          _featureItem(
            icon: Icons.dashboard,
            text: 'Dashboard com gráficos e métricas',
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard() {
    return Container(
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
              const Icon(
                Icons.people_outline,
                color: Color(0xFF0D9488),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Equipe de desenvolvimento',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _teamMember(name: 'Gustavo Pereira', role: ' Backend Flutter'),
          const Divider(height: 1, indent: 36),
          _teamMember(name: 'Augusto Lothar', role: 'Backend Node.js'),
          const Divider(height: 1, indent: 36),
          _teamMember(name: 'Julio Lima', role: 'Frontend Flutter'),
          const Divider(height: 1, indent: 36),
          _teamMember(name: 'Rodrigo Marques', role: 'Mobile Flutter'),
        ],
      ),
    );
  }

  // =========================================================================
  // CARD DE LINKS (INTEGRADO COM SUA LEGAL SCREEN E URL LAUNCHER)
  // =========================================================================

  Widget _buildLinksCard(BuildContext context) {
    return Container(
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
              const Icon(Icons.link, color: Color(0xFF0D9488), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Links úteis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Política de Privacidade
          _linkItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Política de privacidade',
            subtitle: 'Como protegemos seus dados',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LegalScreen(
                    title: 'Política de Privacidade',
                    content: _politicaPrivacidadeContent,
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 36),

          // 2. Termos de Uso
          _linkItem(
            icon: Icons.description_outlined,
            title: 'Termos de uso',
            subtitle: 'Regras de utilização do app',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LegalScreen(
                    title: 'Termos de Uso',
                    content: _termosDeUsoContent,
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 36),

          // 3. Flaticon (Abre no navegador)
          _linkItem(
            icon: Icons.palette_outlined,
            title: 'Ícones por Flaticon',
            subtitle: 'flaticon.com',
            onTap: () async {
              final url = Uri.parse('https://www.flaticon.com');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Não foi possível abrir o link'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // HELPERS DE UI
  // =========================================================================

  Widget _featureItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D9488), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamMember({required String name, required String role}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF0D9488),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF0D9488), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
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

  // Helper para formatar seções de texto em TextSpan
  TextSpan _buildSection(String title, String text) {
    return TextSpan(
      children: [
        TextSpan(
          text: '$title\n',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            fontSize: 16,
          ),
        ),
        TextSpan(
          text: '$text\n\n',
          style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 15),
        ),
      ],
    );
  }

  // =========================================================================
  // CONTEÚDOS FORMATADOS COMO TEXTSPAN (Para sua LegalScreen)
  // =========================================================================

  List<TextSpan> get _termosDeUsoContent => [
    _buildSection(
      '1. Aceitação dos Termos',
      'Ao acessar e utilizar o aplicativo 4UPet, você concorda com estes Termos de Uso. Se não concordar com qualquer parte deles, não utilize o serviço. Estes termos se aplicam a todos os usuários, incluindo tutores de pets e visitantes.',
    ),
    _buildSection(
      '2. Cadastro e Responsabilidade',
      'Você é responsável por fornecer informações verdadeiras ao cadastrar seus pets. Dados incorretos podem afetar lembretes de vacinas, consultas e recomendações do assistente virtual.',
    ),
    _buildSection(
      '3. Uso do Assistente Virtual',
      'O assistente 4UPet fornece informações educativas baseadas em fontes veterinárias confiáveis. As respostas NÃO substituem a avaliação de um médico-veterinário. Em casos de emergência, procure atendimento profissional imediatamente.',
    ),
    _buildSection(
      '4. Lembretes e Agendamentos',
      'O aplicativo oferece lembretes de vacinas, consultas, banhos e medicamentos. O 4UPet não se responsabiliza por falhas de notificação causadas por configurações do dispositivo ou falta de conexão.',
    ),
    _buildSection(
      '5. Propriedade Intelectual',
      'Todos os conteúdos, marcas, logotipos, ícones e códigos do 4UPet são protegidos por direitos autorais. É proibida a reprodução ou uso comercial sem autorização prévia. Ícones utilizados sob licença do Flaticon.',
    ),
    _buildSection(
      '6. Limitação de Responsabilidade',
      'O 4UPet é fornecido "como está". Não garantimos disponibilidade ininterrupta ou ausência de erros. O uso do aplicativo é por sua conta e risco, especialmente em decisões relacionadas à saúde dos pets.',
    ),
    _buildSection(
      '7. Alterações dos Termos',
      'Podemos atualizar estes termos periodicamente. Mudanças significativas serão comunicadas por notificação no aplicativo. O uso continuado após alterações representa aceitação dos novos termos.',
    ),
  ];

  List<TextSpan> get _politicaPrivacidadeContent => [
    _buildSection(
      '1. Coleta de Dados',
      'Coletamos dados fornecidos por você: nome, e-mail, foto de perfil, além de informações dos seus pets (nome, espécie, raça, data de nascimento, peso). Também armazenamos lembretes e histórico de vacinação.',
    ),
    _buildSection(
      '2. Uso das Informações',
      'Seus dados são utilizados exclusivamente para: personalizar lembretes, gerar carteirinha de vacinação em PDF, alimentar o assistente virtual com contexto do seu pet e melhorar a experiência no aplicativo. Não vendemos dados a terceiros.',
    ),
    _buildSection(
      '3. Armazenamento e Segurança',
      'Os dados são armazenados no Supabase, com criptografia em trânsito (HTTPS) e boas práticas de segurança. Fotos dos pets são guardadas em buckets privados. Acesso é restrito a usuários autenticados.',
    ),
    _buildSection(
      '4. Cookies e Rastreamento',
      'O aplicativo web utiliza apenas cookies essenciais para manter sua sessão de login ativa. Não utilizamos cookies de rastreamento de terceiros, analytics invasivos ou publicidade comportamental.',
    ),
    _buildSection(
      '5. Direitos do Usuário (LGPD)',
      'Em conformidade com a Lei Geral de Proteção de Dados (Lei 13.709/2018), você pode solicitar: acesso aos seus dados, correção de informações, exclusão da conta e portabilidade dos dados a qualquer momento.',
    ),
    _buildSection(
      '6. Compartilhamento com Terceiros',
      'Não compartilhamos seus dados com terceiros, exceto: provedores de infraestrutura (Supabase, Render) para funcionamento técnico; quando exigido por lei; ou com seu consentimento explícito.',
    ),
    _buildSection(
      '7. Exclusão de Conta',
      'Ao excluir sua conta, todos os dados pessoais, pets cadastrados, lembretes e histórico de vacinação são permanentemente removidos. A ação é irreversível.',
    ),
    _buildSection(
      '8. Contato',
      'Para dúvidas sobre privacidade, exercer seus direitos ou solicitar exclusão de dados, entre em contato: suporte@4upet.com.br',
    ),
  ];
}
