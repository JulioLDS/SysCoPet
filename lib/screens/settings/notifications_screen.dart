import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _lembretesGerais = true;
  bool _vacinas = true;
  bool _consultas = true;
  bool _newsletter = true;
  bool _novidades = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Notificações',
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
            width: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ SEÇÃO: LEMBRETES DO APP
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF0D9488),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Lembretes do app',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card com os lembretes
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      _buildNotificationTile(
                        icon: Icons.calendar_month,
                        title: 'Lembretes gerais',
                        subtitle:
                            'Receba alertas sobre cuidados diários dos seus pets',
                        value: _lembretesGerais,
                        onChanged: (value) =>
                            setState(() => _lembretesGerais = value),
                      ),
                      const Divider(height: 1),
                      _buildNotificationTile(
                        icon: Icons.vaccines,
                        title: 'Vacinas',
                        subtitle: 'Receba lembretes sobre as vacinas em atraso',
                        value: _vacinas,
                        onChanged: (value) => setState(() => _vacinas = value),
                      ),
                      const Divider(height: 1),
                      _buildNotificationTile(
                        icon: Icons.assignment_outlined,
                        title: 'Consultas',
                        subtitle: 'Receba lembretes de consultas agendadas',
                        value: _consultas,
                        onChanged: (value) =>
                            setState(() => _consultas = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ✅ SEÇÃO: COMUNICAÇÕES
                Row(
                  children: [
                    const Icon(
                      Icons.campaign_outlined,
                      color: Color(0xFF0D9488),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Comunicações',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card com as comunicações
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      _buildNotificationTile(
                        icon: Icons.mail_outline,
                        title: 'Newsletter',
                        subtitle:
                            'Receba dicas e novidades sobre cuidados com pets',
                        value: _newsletter,
                        onChanged: (value) =>
                            setState(() => _newsletter = value),
                      ),
                      const Divider(height: 1),
                      _buildNotificationTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notificações de novidades',
                        subtitle: 'Fique por dentro de atualizações do app',
                        value: _novidades,
                        onChanged: (value) =>
                            setState(() => _novidades = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ BARRA DE INFORMAÇÃO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF0D9488),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Você pode alterar essas preferências a qualquer momento.',
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

  // ✅ Widget auxiliar para cada item de notificação
  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Ícone em círculo teal claro
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0D9488), size: 22),
          ),
          const SizedBox(width: 16),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Toggle Switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0D9488),
            activeTrackColor: const Color(0xFF0D9488).withOpacity(0.3),
            inactiveThumbColor: const Color(
              0xFF5F7A77,
            ), // Verde acinzentado escuro
            inactiveTrackColor: const Color(
              0xFFD1E0DC,
            ), // Verde acinzentado claro
          ),
        ],
      ),
    );
  }
}
