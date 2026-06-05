import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../forgot_password/forgot_password_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _selectedIndex = 0;
  bool _isAnimating = false;

  // ✅ Cache para pré-carregar a tela de ForgotPassword
  bool _isForgotPasswordPreloaded = false;

  @override
  void initState() {
    super.initState();
    // ✅ Pré-carregar TODOS os assets críticos na inicialização
    _preloadAllAssets();
  }

  Future<void> _preloadAllAssets() async {
    // Pré-carregar imagens PNG
    await Future.wait([
      precacheImage(const AssetImage('assets/images/background2.png'), context),
      precacheImage(const AssetImage('assets/images/pets.png'), context),
      precacheImage(
        const AssetImage('assets/images/background_mobile.png'),
        context,
      ),
      precacheImage(const AssetImage('assets/icons/google.png'), context),
    ]);

    // ✅ SVGs são automaticamente cacheados pelo flutter_svg
    // Não precisamos pré-carregá-los manualmente

    setState(() {
      _isForgotPasswordPreloaded = true;
    });
  }

  void _changeTab(int newIndex) {
    if (_isAnimating || _selectedIndex == newIndex) return;

    setState(() {
      _isAnimating = true;
      _selectedIndex = newIndex;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isAnimating = false);
      }
    });
  }

  // ✅ Navegação otimizada para ForgotPassword
  void _goToForgotPassword() {
    // Se já estiver pré-carregado, navega instantaneamente
    if (_isForgotPasswordPreloaded) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ForgotPasswordScreen(onBackToLogin: () => Navigator.pop(context)),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      // Mostra loading enquanto carrega
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0D9488)),
        ),
      );

      // Pré-carrega e navega
      _preloadAllAssets().then((_) {
        if (mounted) {
          Navigator.pop(context); // Fecha loading
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ForgotPasswordScreen(
                    onBackToLogin: () => Navigator.pop(context),
                  ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      });
    }
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

  Widget _buildDesktopLayout(double screenHeight) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background2.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: 60,
                    left: 120,
                    right: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: const Offset(-120, -100),
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
                                    const WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(
                                        Icons.favorite_border,
                                        color: Color(0xFF0D9488),
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
                              child: _selectedIndex == 0
                                  ? LoginScreen(
                                      key: const ValueKey('login'),
                                      onForgotPassword: _goToForgotPassword,
                                      onGoToRegister: () => _changeTab(1),
                                    )
                                  : RegisterScreen(
                                      key: const ValueKey('register'),
                                      onGoToLogin: () => _changeTab(0),
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

  Widget _buildAnimatedTabs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              children: [
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
            SizedBox(
              height: 3,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(height: 2, color: const Color(0xFFE2E8F0)),
                  ),
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
                    _buildAnimatedTabs(),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _selectedIndex == 0
                          ? LoginScreen(
                              key: const ValueKey('login'),
                              onForgotPassword: _goToForgotPassword,
                              onGoToRegister: () => _changeTab(1),
                            )
                          : RegisterScreen(
                              key: const ValueKey('register'),
                              onGoToLogin: () => _changeTab(0),
                            ),
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
