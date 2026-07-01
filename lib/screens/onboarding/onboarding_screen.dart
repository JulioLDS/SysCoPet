import 'package:flutter/material.dart';
import 'dart:math';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideUpAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideUpAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 850;
          double screenHeight = constraints.maxHeight;
          double screenWidth = constraints.maxWidth;

          if (isDesktop) {
            return _buildDesktopLayout(screenWidth, screenHeight);
          } else {
            return _buildMobileLayout(screenWidth, screenHeight);
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(double screenWidth, double screenHeight) {
    // ✅ Fator de escala proporcional
    double scaleFactor = screenHeight / 900;

    // ✅ Tamanhos proporcionais
    double logoHeight = 400 * scaleFactor;
    double titleFontSize = 50 * scaleFactor;
    double subtitleFontSize = 22 * scaleFactor;
    double buttonFontSize = 18 * scaleFactor;
    double cardWidth = 450 * scaleFactor;
    double cardHeight = 120 * scaleFactor;
    double petsHeight = screenHeight * 0.90;

    // ✅ VARIÁVEIS DE POSICIONAMENTO (igual auth_screen)
    double logoOffsetX = 100 * scaleFactor;
    double logoOffsetY = -100 * scaleFactor;

    double titleOffsetX = 0 * scaleFactor;
    double titleOffsetY = -175 * scaleFactor;

    double descriptionOffsetX = 0 * scaleFactor;
    double descriptionOffsetY = -150 * scaleFactor;

    double cardsOffsetX = -285 * scaleFactor;
    double cardsOffsetY = 125 * scaleFactor;
    double cardSpacing = 20 * scaleFactor;

    // ✅ Botão
    double buttonWidth = 300 * scaleFactor;

    return Stack(
      children: [
        // ✅ Background PNG
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background2.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // ✅ CONTEÚDO PRINCIPAL
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 60 * scaleFactor),
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: SlideTransition(
              position: _slideUpAnimation,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ COLUNA 1: Logo e Textos (igual auth_screen)
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 80 * scaleFactor,
                          left: 200,
                          right: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo
                              Transform.translate(
                                offset: Offset(logoOffsetX, logoOffsetY),
                                child: Transform.rotate(
                                  angle: pi / 2,
                                  child: Image.asset(
                                    'assets/icons/Logo_PI.png',
                                    height: logoHeight,
                                  ),
                                ),
                              ),

                              // Título
                              Transform.translate(
                                offset: Offset(titleOffsetX, titleOffsetY),
                                child: SizedBox(
                                  width: 400 * scaleFactor,
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Mais cuidado,\n',
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E293B),
                                        height: 1.2,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'mais amor,\n',
                                          style: TextStyle(
                                            fontSize: titleFontSize,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0D9488),
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'mais conexão.',
                                          style: TextStyle(
                                            fontSize: titleFontSize,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Descrição
                              Transform.translate(
                                offset: Offset(
                                  descriptionOffsetX,
                                  descriptionOffsetY,
                                ),
                                child: SizedBox(
                                  width: 450 * scaleFactor,
                                  child: Text(
                                    'A plataforma completa para gerenciar a saúde, bem-estar e rotina do seu pet.',
                                    style: TextStyle(
                                      fontSize: subtitleFontSize,
                                      color: Colors.grey[600],
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ COLUNA 2: Cards (mesma lógica)
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 80 * scaleFactor,
                          left: 0,
                          right: 0,
                          child: Transform.translate(
                            offset: Offset(cardsOffsetX, cardsOffsetY),
                            child: Column(
                              children: [
                                _buildFeatureCard(
                                  icon: Icons.vaccines_outlined,
                                  iconColor: const Color(0xFF059669),
                                  iconBg: const Color(0xFFD1FAE5),
                                  title: 'Organize tudo',
                                  subtitle:
                                      'Vacinas, consultas, exames e muito mais em um só lugar.',
                                  scaleFactor: scaleFactor,
                                  cardWidth: cardWidth,
                                  cardHeight: cardHeight,
                                ),

                                SizedBox(height: cardSpacing),

                                _buildFeatureCard(
                                  icon: Icons.calendar_month_outlined,
                                  iconColor: const Color(0xFF2563EB),
                                  iconBg: const Color(0xFFDBEAFE),
                                  title: 'Não perca nada',
                                  subtitle:
                                      'Receba lembretes de compromissos e cuide sempre em dia.',
                                  scaleFactor: scaleFactor,
                                  cardWidth: cardWidth,
                                  cardHeight: cardHeight,
                                ),

                                SizedBox(height: cardSpacing),

                                _buildFeatureCard(
                                  icon: Icons.favorite_outline,
                                  iconColor: const Color(0xFFEA580C),
                                  iconBg: const Color(0xFFFFEDD5),
                                  title: 'Cuidado que conecta',
                                  subtitle:
                                      'Informações do seu pet sempre com você, onde estiver.',
                                  scaleFactor: scaleFactor,
                                  cardWidth: cardWidth,
                                  cardHeight: cardHeight,
                                ),
                              ],
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

        // ✅ PETS - CANTO INFERIOR DIREITO
        Positioned(
          bottom: -80,
          right: 0,
          child: Container(
            height: petsHeight,
            width: screenWidth * 0.50,
            child: Image.asset(
              'assets/images/pets_lado_esquerdo.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
            ),
          ),
        ),

        // ✅ BOTÃO - ELEMENTO INDEPENDENTE
        Positioned(
          bottom: screenHeight * 0.15,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              height: 60 * scaleFactor,
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/auth');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: const Color(0xFF0D9488).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16 * scaleFactor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 24 * scaleFactor),
                    SizedBox(width: 12 * scaleFactor),
                    Text(
                      'Vamos começar',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required double scaleFactor,
    required double cardWidth,
    required double cardHeight,
  }) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: EdgeInsets.all(20 * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone
          Container(
            width: 50 * scaleFactor,
            height: 50 * scaleFactor,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12 * scaleFactor),
            ),
            child: Icon(icon, color: iconColor, size: 26 * scaleFactor),
          ),
          SizedBox(width: 16 * scaleFactor),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16 * scaleFactor,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4 * scaleFactor),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13 * scaleFactor,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(double screenWidth, double screenHeight) {
    double scaleFactor = screenHeight / 900;

    return Stack(
      children: [
        // ✅ Background PNG mobile
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_mobile.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo
                Center(
                  child: Transform.rotate(
                    angle: pi / 2,
                    child: Image.asset('assets/icons/Logo_PI.png', height: 200),
                  ),
                ),

                const SizedBox(height: 30),

                // Título
                const Text.rich(
                  TextSpan(
                    text: 'Mais cuidado,\n',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: 'mais amor,\n',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                      TextSpan(
                        text: 'mais conexão.',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Descrição
                const Text(
                  'A plataforma completa para gerenciar a saúde, bem-estar e rotina do seu pet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                // Pets
                Image.asset(
                  'assets/images/pets.png',
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 30),

                // Cards de Features
                _buildFeatureCard(
                  icon: Icons.vaccines_outlined,
                  iconColor: const Color(0xFF059669),
                  iconBg: const Color(0xFFD1FAE5),
                  title: 'Organize tudo',
                  subtitle:
                      'Vacinas, consultas, exames e muito mais em um só lugar.',
                  scaleFactor: scaleFactor,
                  cardWidth: double.infinity,
                  cardHeight: 100,
                ),

                const SizedBox(height: 16),

                _buildFeatureCard(
                  icon: Icons.calendar_month_outlined,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFDBEAFE),
                  title: 'Não perca nada',
                  subtitle:
                      'Receba lembretes de compromissos e cuide sempre em dia.',
                  scaleFactor: scaleFactor,
                  cardWidth: double.infinity,
                  cardHeight: 100,
                ),

                const SizedBox(height: 16),

                _buildFeatureCard(
                  icon: Icons.favorite_outline,
                  iconColor: const Color(0xFFEA580C),
                  iconBg: const Color(0xFFFFEDD5),
                  title: 'Cuidado que conecta',
                  subtitle:
                      'Informações do seu pet sempre com você, onde estiver.',
                  scaleFactor: scaleFactor,
                  cardWidth: double.infinity,
                  cardHeight: 100,
                ),

                const SizedBox(height: 30),

                // Botão
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/auth');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: const Color(0xFF0D9488).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Vamos começar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
