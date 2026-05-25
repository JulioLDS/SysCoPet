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
    print(
      'DEBUG: HomeScreen renderizado. User: ${authProvider.currentUser?.nome}',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // AppBar com usuário
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D9488),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                user?.nome?.isNotEmpty == true
                    ? user!.nome![0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.nome ?? 'Usuário',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Abrir configurações
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
          ),
        ],
      ),

      // Corpo da tela
      body: _buildBody(context, user),

      // Bottom Navigation (Mobile)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF0D9488),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saudação
          Text(
            'Olá, ${user?.nome?.split(' ').first ?? 'Usuário'}! 👋',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gerencie seus pets e acompanhe a saúde deles.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Seção Meus Pets
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
                onPressed: () {
                  // TODO: Adicionar pet
                },
                child: const Text('+ Adicionar'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cards de Pets (Horizontal)
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildAddPetCard(),
                const SizedBox(width: 12),
                _buildPetCard(name: 'Rex', breed: 'Golden', image: '🐕'),
                const SizedBox(width: 12),
                _buildPetCard(name: 'Luna', breed: 'Persa', image: '🐈'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ações Rápidas
          const Text(
            'Ações Rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),

          // Grid simples (evita conflito com ScrollView)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionChip(
                icon: Icons.medical_services,
                label: 'Vacinas',
                color: const Color(0xFF10B981),
              ),
              _buildActionChip(
                icon: Icons.calendar_today,
                label: 'Consultas',
                color: const Color(0xFF3B82F6),
              ),
              _buildActionChip(
                icon: Icons.notifications,
                label: 'Lembretes',
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== WIDGETS AUXILIARES =====

  Widget _buildPetCard({
    required String name,
    required String breed,
    required String image,
  }) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(image, style: const TextStyle(fontSize: 50)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  breed,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetCard() {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0D9488), width: 2),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'Adicionar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D9488),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 100,
      height: 90,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
