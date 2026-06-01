import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final List<TextSpan> content;

  const LegalScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 850;

          return Stack(
            children: [
              // 1. BACKGROUND (Mesmo da Auth Screen)
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 2. CONTEÚDO CENTRALIZADO
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 700 : double.infinity,
                    maxHeight: constraints.maxHeight * 0.85,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(40),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Conteúdo (RichText para permitir spans clicáveis ou estilizados)
                      Expanded(
                        child: SingleChildScrollView(
                          child: RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                height: 1.6,
                                fontFamily: 'Roboto', // ou sua fonte padrão
                              ),
                              children: content,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botão Fechar
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFF0D9488)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Entendi e fechar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
