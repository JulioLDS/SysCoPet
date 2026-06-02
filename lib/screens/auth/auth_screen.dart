import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _selectedIndex = 0; // 0 = Entrar, 1 = Cadastrar
  bool _isAnimating = false; // Controle de animação

  // Função para trocar de aba com bloqueio durante animação
  void _changeTab(int newIndex) {
    if (_isAnimating || _selectedIndex == newIndex) return;

    setState(() {
      _isAnimating = true;
      _selectedIndex = newIndex;
    });

    // Desbloqueia após a duração da animação
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isAnimating = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 850;
          double screenHeight = constraints.maxHeight;

          if (isDesktop) {
            return _buildDesktopLayout(screenHeight);
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  // ===== LAYOUT DESKTOP =====
  Widget _buildDesktopLayout(double screenHeight) {
    return Stack(
      children: [
        // 1. BACKGROUND (INALTERADO)
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background2.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 2. CONTEÚDO (INALTERADO)
        Row(
          children: [
            // LADO ESQUERDO (TEXTO + PETS) - EXATAMENTE COMO ESTAVA
            Expanded(
              child: Stack(
                children: [
                  // TEXTO
                  Positioned(
                    top: 60,
                    left: 120,
                    right: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ LOGO: Posicionamento independente
                        Transform.translate(
                          offset: const Offset(
                            -120,
                            -100,
                          ), // ← AJUSTE AQUI: x = esquerda/direita, y = cima/baixo
                          child: Center(
                            child: Transform.rotate(
                              angle: pi / 2,
                              child: SvgPicture.asset(
                                'assets/icons/logo.svg',
                                height: 300,
                              ),
                            ),
                          ),
                        ),

                        // ✅ TEXTOS: Todos movidos juntos como um bloco
                        Transform.translate(
                          offset: Offset(
                            50,
                            screenHeight < 800
                                ? -(screenHeight * 0.31)
                                : -(screenHeight * 0.22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 45),
                              Text.rich(
                                TextSpan(
                                  text: 'A saúde do seu pet\n',
                                  style: const TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                    height: 1.2,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'em boas patas ',
                                      style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0D9488),
                                      ),
                                    ),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(
                                        Icons.favorite_border,
                                        color: const Color(0xFF0D9488),
                                        size: 36,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 420,
                                child: Text(
                                  'Gerencie consultas, vacinas, medicamentos e muito mais. Tudo para o bem-estar do seu melhor amigo.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PETS
                  Positioned(
                    top: screenHeight * 0.20,
                    left: 100,
                    right: 0,
                    height: screenHeight * 1.05,
                    child: Image.asset(
                      'assets/images/pets.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ],
              ),
            ),

            // LADO DIREITO (Card com Tabs + Formulário)
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 480,
                    maxHeight: 670,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _buildAnimatedTabs(),
                      ),

                      Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: 580,
                          child: ClipRect(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 1000),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    final bool isLogin =
                                        child.key == const ValueKey('login');
                                    final Offset startOffset = isLogin
                                        ? const Offset(-1.5, 0.0)
                                        : const Offset(1.5, 0.0);

                                    return SlideTransition(
                                      position:
                                          Tween<Offset>(
                                            begin: startOffset,
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeInOutCubic,
                                            ),
                                          ),
                                      child: child,
                                    );
                                  },
                              // Substitua a criação do LoginScreen por:
                              child: _selectedIndex == 0
                                  ? LoginScreen(
                                      key: const ValueKey('login'),
                                      onForgotPassword: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                ) => ForgotPasswordScreen(
                                                  onBackToLogin: () =>
                                                      Navigator.pop(context),
                                                ),
                                            transitionsBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child,
                                                ) {
                                                  const begin = Offset(
                                                    0.0,
                                                    0.1,
                                                  ); // Leve slide de baixo para cima
                                                  const end = Offset.zero;
                                                  const curve =
                                                      Curves.easeOutCubic;

                                                  var tween =
                                                      Tween(
                                                        begin: begin,
                                                        end: end,
                                                      ).chain(
                                                        CurveTween(
                                                          curve: curve,
                                                        ),
                                                      );
                                                  var slideAnimation = animation
                                                      .drive(tween);
                                                  var fadeAnimation =
                                                      CurvedAnimation(
                                                        parent: animation,
                                                        curve: Curves.easeOut,
                                                      );

                                                  return FadeTransition(
                                                    opacity: fadeAnimation,
                                                    child: SlideTransition(
                                                      position: slideAnimation,
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                            transitionDuration: const Duration(
                                              milliseconds: 350,
                                            ), // Duração suave
                                          ),
                                        );
                                      },
                                      onGoToRegister: () => _changeTab(1),
                                    )
                                  : RegisterScreen(
                                      key: const ValueKey('register'),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== TABS ANIMADAS =====
  Widget _buildAnimatedTabs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // 1. Área dos textos com toque EXPANDIDO
            Row(
              children: [
                // Tab "Entrar"
                Expanded(
                  child: MouseRegion(
                    cursor: _isAnimating
                        ? SystemMouseCursors.wait
                        : SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _changeTab(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 8,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _selectedIndex == 0
                                ? const Color(0xFF0D9488)
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Tab "Cadastrar"
                Expanded(
                  child: MouseRegion(
                    cursor: _isAnimating
                        ? SystemMouseCursors.wait
                        : SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _changeTab(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 8,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cadastrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _selectedIndex == 1
                                ? const Color(0xFF0D9488)
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 2. Linhas Indicadoras
            SizedBox(
              height: 3,
              child: Stack(
                children: [
                  // Linha de fundo (Cinza claro)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(height: 2, color: const Color(0xFFE2E8F0)),
                  ),
                  // Linha verde animada
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _selectedIndex == 0 ? 0 : null,
                    right: _selectedIndex == 1 ? 0 : null,
                    width: constraints.maxWidth / 2,
                    height: 2,
                    bottom: 0,
                    child: Container(color: const Color(0xFF0D9488)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ===== LAYOUT MOBILE =====
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_mobile.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Icon(
                          Icons.pets,
                          color: const Color(0xFF0D9488),
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'PetSaúde',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Tabs Animadas (Mobile)
                    _buildAnimatedTabs(),
                    const SizedBox(height: 16),

                    // Formulário com animação
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _selectedIndex == 0
                          ? LoginScreen(
                              key: const ValueKey('login'),
                              onForgotPassword: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => ForgotPasswordScreen(
                                          onBackToLogin: () =>
                                              Navigator.pop(context),
                                        ),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          const begin = Offset(
                                            0.0,
                                            0.1,
                                          ); // Leve slide de baixo para cima
                                          const end = Offset.zero;
                                          const curve = Curves.easeOutCubic;

                                          var tween = Tween(
                                            begin: begin,
                                            end: end,
                                          ).chain(CurveTween(curve: curve));
                                          var slideAnimation = animation.drive(
                                            tween,
                                          );
                                          var fadeAnimation = CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOut,
                                          );

                                          return FadeTransition(
                                            opacity: fadeAnimation,
                                            child: SlideTransition(
                                              position: slideAnimation,
                                              child: child,
                                            ),
                                          );
                                        },
                                    transitionDuration: const Duration(
                                      milliseconds: 350,
                                    ), // Duração suave
                                  ),
                                );
                              },
                              onGoToRegister: () => _changeTab(1),
                            )
                          : RegisterScreen(key: const ValueKey('register')),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 180,
              child: ClipRect(
                clipBehavior: Clip.none,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: const Offset(0, 30),
                    child: Image.asset(
                      'assets/images/pets.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
