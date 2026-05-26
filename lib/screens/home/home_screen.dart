import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: Column(
        children: [
          // 1. HEADER FIXO
          Container(
            color: const Color(0xFF0D9488),
            // Padding ajustado para 15 conforme seu pedido
            padding: const EdgeInsets.only(
              top: 15,
              left: 20,
              right: 20,
              bottom: 15,
            ),
            child: Row(
              children: [
                // AVATAR: Fundo verde, borda branca, texto branco
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF0D9488,
                    ), // Fundo verde (mesma cor do header)
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ), // Borda branca
                  ),
                  child: Center(
                    child: Text(
                      user?.nome?.substring(0, 2).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white, // Texto branco
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
                        user?.nome ?? 'Usuário',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // ENGRENAGEM COM MENU DE OPÇÕES
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                  offset: const Offset(0, 40), // Posição do menu
                  onSelected: (value) {
                    if (value == 'logout') {
                      _logout(context, authProvider);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Sair da conta'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. CONTEÚDO COM ROLAGEM
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saudação
                  Text(
                    'Olá, ${user?.nome?.split(' ').first ?? 'Usuário'}! 👋',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Que bom te ver por aqui! Veja como estão os cuidados dos seus pets hoje.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Título da Seção
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Meus Pets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Ver todos',
                          style: TextStyle(
                            color: Color(0xFF0D9488),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Lista Horizontal de Pets
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildAddPetCard(),
                        const SizedBox(width: 15),
                        _buildPetCard(
                          name: 'Mel',
                          breed: 'Golden Retriever',
                          age: '3 anos',
                          color: const Color(0xFFD4A373),
                        ),
                        const SizedBox(width: 15),
                        _buildPetCard(
                          name: 'Luna',
                          breed: 'Siamês',
                          age: '2 anos',
                          color: const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 15),
                        _buildPetCard(
                          name: 'Thor',
                          breed: 'Shih Tzu',
                          age: '4 anos',
                          color: const Color(0xFFE2E8F0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Ações Rápidas
                  const Text(
                    'Ações rápidas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickActionCard(
                        title: 'Vacinas',
                        subtitle: 'Ver e agendar',
                        icon: Icons.vaccines_outlined,
                        color: const Color(0xFFD1FAE5),
                        iconColor: const Color(0xFF059669),
                      ),
                      _buildQuickActionCard(
                        title: 'Consultas',
                        subtitle: 'Agendar visita',
                        icon: Icons.calendar_month_outlined,
                        color: const Color(0xFFDBEAFE),
                        iconColor: const Color(0xFF2563EB),
                      ),
                      _buildQuickActionCard(
                        title: 'Lembretes',
                        subtitle: 'Ver lembretes',
                        icon: Icons.notifications_outlined,
                        color: const Color(0xFFFFEDD5),
                        iconColor: const Color(0xFFEA580C),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Próximos Lembretes
                  const Text(
                    'Próximos lembretes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildReminderItem(
                          icon: Icons.vaccines_outlined,
                          iconBg: const Color(0xFFD1FAE5),
                          iconColor: const Color(0xFF059669),
                          title: 'Vacina V8',
                          pet: 'Mel',
                          date: '24/05/2025',
                          time: 'Sábado, 10:00',
                        ),
                        Divider(height: 1, color: Colors.grey[200]),
                        _buildReminderItem(
                          icon: Icons.calendar_today_outlined,
                          iconBg: const Color(0xFFDBEAFE),
                          iconColor: const Color(0xFF2563EB),
                          title: 'Consulta veterinária',
                          pet: 'Luna',
                          date: '02/06/2025',
                          time: 'Segunda, 14:30',
                        ),
                        Divider(height: 1, color: Colors.grey[200]),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.list_alt_outlined,
                            color: Color(0xFF0D9488),
                          ),
                          label: const Text(
                            'Ver todos os lembretes',
                            style: TextStyle(
                              color: Color(0xFF0D9488),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. BOTTOM NAVIGATION BAR (COM BORDAS ARREDONDADAS)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // LINHA INDICADORA - Versão Simplificada
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _selectedIndex == 0 ? 3 : 0,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D9488),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                    ),
                    curve: Curves.easeInOut,
                  ),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _selectedIndex == 1 ? 3 : 0,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D9488),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                    ),
                    curve: Curves.easeInOut,
                  ),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _selectedIndex == 2 ? 3 : 0,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D9488),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                    ),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
            // BARRA DE NAVEGAÇÃO
            BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF0D9488),
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.transparent,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  label: 'Agenda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Perfil',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Função de Logout
  void _logout(BuildContext context, AuthProvider authProvider) {
    authProvider.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LoginScreen(onToggleRegister: () {}, onForgotPassword: () {}),
      ),
      (route) => false,
    );
  }

  // ===== WIDGETS AUXILIARES =====

  Widget _buildAddPetCard() {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0D9488),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0D9488), width: 1),
                ),
                child: const Icon(
                  Icons.add,
                  color: Color(0xFF0D9488),
                  size: 30,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Adicionar\nnovo pet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0D9488),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard({
    required String name,
    required String breed,
    required String age,
    required Color color,
  }) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.pets, size: 35, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(breed, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              age,
              style: const TextStyle(
                color: Color(0xFF059669),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: iconColor.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String pet,
    required String date,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  pet,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
              ),
              Text(
                time,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
