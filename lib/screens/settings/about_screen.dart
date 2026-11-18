import 'package:flutter/material.dart';

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
      body: MediaQuery.of(context).size.width < 600
        ? _buildMobileLayout(context)
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              children: [
                // ✅ CARD 1: IDENTIDADE DO APP
                Container(
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
                  child: Column(
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: Color(0xFF0D9488),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '4UPet',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Versão 1.0.0',
                          style: TextStyle(
                            color: Color(0xFF0D9488),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cuidando de quem você ama! 🐾',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ CARD 2: SOBRE
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
                            Icons.info_outline,
                            color: const Color(0xFF0D9488),
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
                ),
                const SizedBox(height: 20),

                // ✅ CARD 3: FUNCIONALIDADES
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
                            Icons.star_outline,
                            color: const Color(0xFF0D9488),
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
                      _featureItem(
                        icon: Icons.pets,
                        text: 'Cadastro de múltiplos pets',
                      ),
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
                ),
                const SizedBox(height: 20),

                // ✅ CARD 4: EQUIPE
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
                            Icons.people_outline,
                            color: const Color(0xFF0D9488),
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
                      _teamMember(
                        name: 'Julio Lucas',
                        role: 'Desenvolvedor Full Stack',
                      ),
                      const Divider(height: 1, indent: 36),
                      _teamMember(name: 'Sangu', role: 'Backend Node.js'),
                      const Divider(height: 1, indent: 36),
                      _teamMember(name: 'Juju', role: 'Frontend Flutter'),
                      const Divider(height: 1, indent: 36),
                      _teamMember(name: 'Zé Esfiha', role: 'Mobile Flutter'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ CARD 5: LINKS
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
                            Icons.link,
                            color: const Color(0xFF0D9488),
                            size: 22,
                          ),
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
                      _linkItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Política de privacidade',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Em desenvolvimento'),
                              backgroundColor: Color(0xFF0D9488),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 36),
                      _linkItem(
                        icon: Icons.description_outlined,
                        title: 'Termos de uso',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Em desenvolvimento'),
                              backgroundColor: Color(0xFF0D9488),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ COPYRIGHT
                Text(
                  '© 2026 4UPet. Todos os direitos reservados.',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Feito com 💚 para tutores de pets',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        MediaQuery.of(context).padding.bottom + 28,
      ),
      child: Column(
        children: [
          // CARD 1: IDENTIDADE DO APP
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: _mobileCardDecoration(),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: Color(0xFF0D9488),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  '4UPet',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Versão 1.0.0',
                    style: TextStyle(
                      color: Color(0xFF0D9488),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cuidando de quem você ama! 🐾',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // CARD 2: SOBRE O APLICATIVO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: _mobileCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mobileSectionTitle(
                  Icons.info_outline,
                  'Sobre o 4UPet',
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
          ),

          const SizedBox(height: 14),

          // CARD 3: FUNCIONALIDADES
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: _mobileCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mobileSectionTitle(
                  Icons.star_outline,
                  'Funcionalidades',
                ),
                const SizedBox(height: 12),
                _featureItem(
                  icon: Icons.pets,
                  text: 'Cadastro de múltiplos pets',
                ),
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
          ),

          const SizedBox(height: 14),

          // CARD 4: EQUIPE DE DESENVOLVIMENTO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: _mobileCardDecoration(),
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
                    const Expanded(
                      child: Text(
                        'Equipe de desenvolvimento',
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _teamMember(
                  name: 'Julio Lucas',
                  role: 'Desenvolvedor Full Stack',
                ),
                const Divider(height: 1, indent: 48),
                _teamMember(
                  name: 'Sangu',
                  role: 'Backend Node.js',
                ),
                const Divider(height: 1, indent: 48),
                _teamMember(
                  name: 'Juju',
                  role: 'Frontend Flutter',
                ),
                const Divider(height: 1, indent: 48),
                _teamMember(
                  name: 'Zé Esfiha',
                  role: 'Mobile Flutter',
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // CARD 5: LINKS ÚTEIS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: _mobileCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mobileSectionTitle(
                  Icons.link,
                  'Links úteis',
                ),
                const SizedBox(height: 12),
                _linkItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Política de privacidade',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Em desenvolvimento'),
                        backgroundColor: Color(0xFF0D9488),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 36),
                _linkItem(
                  icon: Icons.description_outlined,
                  title: 'Termos de uso',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Em desenvolvimento'),
                        backgroundColor: Color(0xFF0D9488),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // RODAPÉ
          Text(
            '© 2026 4UPet. Todos os direitos reservados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Feito com 💚 para tutores de pets',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _mobileCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _mobileSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF0D9488),
          size: 22,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
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
