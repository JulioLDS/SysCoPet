  import 'dart:async';

  import 'package:flutter/material.dart';
  import 'package:google_sign_in/google_sign_in.dart';
  import 'package:google_sign_in_web/web_only.dart' as web;
  import 'package:provider/provider.dart';

  import '../../providers/auth_provider.dart';

  class GoogleLoginWebButton extends StatefulWidget {
    final VoidCallback onSuccess;
    final void Function(String erro) onError;

    const GoogleLoginWebButton({
      super.key,
      required this.onSuccess,
      required this.onError,
    });

    @override
    State<GoogleLoginWebButton> createState() => _GoogleLoginWebButtonState();
  }

  class _GoogleLoginWebButtonState extends State<GoogleLoginWebButton> {
    StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;

    @override
    void initState() {
      super.initState();
      _iniciarListenerGoogle();
    }

    Future<void> _iniciarListenerGoogle() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.inicializarGoogle();

      _subscription = GoogleSignIn.instance.authenticationEvents.listen(
        (event) async {
          print('EVENTO GOOGLE RECEBIDO: $event');
          if (event is GoogleSignInAuthenticationEventSignIn) {
            print('USUARIO GOOGLE RECEBIDO');
            final idToken = event.user.authentication.idToken;
            print('ID TOKEN EXISTE? ${idToken != null}');

            if (idToken == null) {
              widget.onError('Falha ao obter ID Token do Google.');
              return;
            }

            print(idToken.runtimeType);

            final erro = await authProvider.loginComGoogleIdToken(idToken);

            if (!mounted) return;

            if (erro != null) {
              print('ERRO AO LOGAR NO BACKEND: $erro');
              widget.onError(erro);
              return;
            }

            print('LOGIN GOOGLE FINALIZADO COM SUCESSO');
            widget.onSuccess();
          }
        },
        onError: (error) {
          print('ERRO NO EVENTO GOOGLE: $error');
          widget.onError('Erro no login com Google: $error');
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        height: 50,
        child: OverflowBox(
          maxHeight: 70,
          maxWidth: double.infinity,
          child: web.renderButton(),
        ),
      );
    }
  }
