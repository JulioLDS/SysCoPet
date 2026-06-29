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
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  bool _isAnimating = false;
  bool _isForgotPasswordPreloaded = false;

  @override
  void initState() {
    super.initState();
    // ✅ NÃO chamar precacheImage aqui - move para didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Pré-carregar assets DEPOIS que o contexto está pronto
    _preloadAllAssets();
  }

  Future<void> _preloadAllAssets() async {
    await Future.wait([
      precacheImage(const AssetImage('assets/images/background2.png'), context),
      precacheImage(const AssetImage('assets/images/pets.png'), context),
      precacheImage(
        const AssetImage('assets/images/background_mobile.png'),
        context,
      ),
      precacheImage(const AssetImage('assets/icons/google.png'), context),
      precacheImage(const AssetImage('assets/icons/Logo_PI.png'), context),
    ]);

    if (mounted) {
      setState(() {
        _isForgotPasswordPreloaded = true;
      });
    }
  }

  void _changeTab(int newIndex) {
    // ✅ Bloqueio imediato
    if (_isAnimating || _selectedIndex == newIndex) {
      return;
    }

    setState(() {
      _isAnimating = true;
      _selectedIndex = newIndex;
    });

    // ✅ Verifica se o PageController está attached antes de animar
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    // ✅ Desbloqueia após 1 segundo (1000ms)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isAnimating = false);
      }
    });
  }

  void _goToForgotPassword() {
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0D9488)),
        ),
      );

      _preloadAllAssets().then((_) {
        if (mounted) {
          Navigator.pop(context);
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
      resizeToAvoidBottomInset: false,
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
                              child: Image.asset(
                                'assets/icons/Logo_PI.png',
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
        Positioned(
          bottom: -190,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/pets.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 70),
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Image.asset(
                              'assets/icons/Logo_PI.png',
                              height: 200,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildAnimatedTabs(),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 650,
                      child: PageView(
                        onPageChanged: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          LoginScreen(
                            onForgotPassword: _goToForgotPassword,
                            onGoToRegister: () => _changeTab(1),
                          ),
                          RegisterScreen(onGoToLogin: () => _changeTab(0)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
