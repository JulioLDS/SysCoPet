import 'package:flutter/foundation.dart';

import '../models/chat_message_model.dart';
import '../providers/auth_provider.dart';
import '../services/chat_history_service.dart';
import '../services/chatbot_service.dart';

/// Uma única conversa visual por usuário. Sem IDs de conversa ou memória da IA.
class ChatSessionController extends ChangeNotifier {
  ChatSessionController({
    required AuthProvider authProvider,
    ChatbotService? chatbotService,
    ChatHistoryService? historyService,
    this.mensagemErro = 'Não foi possível consultar o assistente no momento.',
  }) : _auth = authProvider,
       _chatbot = chatbotService ?? ChatbotService(),
       _history = historyService ?? ChatHistoryService(),
       _idUsuario = authProvider.currentUser?.id {
    _auth.addListener(_onAuthChanged);
  }

  final String mensagemErro;
  final AuthProvider _auth;
  final ChatbotService _chatbot;
  final ChatHistoryService _history;
  final List<ChatMessageModel> _messages = [];
  int? _idUsuario;
  int _session = 0;
  int _tasks = 0;
  bool _disposed = false;
  bool _released = false;
  bool _loading = false;
  bool _sending = false;
  bool _clearing = false;
  Future<void> _saveTail = Future.value();

  List<ChatMessageModel> get mensagens => List.unmodifiable(_messages);
  int? get idUsuario => _idUsuario;
  int get versaoSessao => _session;
  bool get carregandoHistorico => _loading;
  bool get enviandoMensagem => _sending;
  bool get limpandoHistorico => _clearing;
  bool get ocupado => _loading || _sending || _clearing;
  String? erroHistorico;
  String? erroSalvamento;

  bool _sameSession(int session) => session == _session;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _onAuthChanged() {
    final id = _auth.currentUser?.id;
    if (id == _idUsuario) return;
    _session++;
    _idUsuario = id;
    _messages.clear();
    _loading = false;
    _sending = false;
    _clearing = false;
    _saveTail = Future.value();
    erroHistorico = null;
    erroSalvamento = null;
    _notify();
    if (!_disposed && id != null) carregarHistorico();
  }

  Future<void> carregarHistorico() async {
    final user = _idUsuario;
    if (_disposed || user == null || ocupado) return;
    final session = _session;
    _tasks++;
    _loading = true;
    erroHistorico = null;
    _notify();
    try {
      final messages = await _history.buscarHistorico(user);
      if (_sameSession(session) && !_disposed) {
        _messages
          ..clear()
          ..addAll(messages);
      }
    } catch (_) {
      if (_sameSession(session)) {
        erroHistorico = 'Não foi possível carregar o histórico.';
        debugPrint(
          'Histórico indisponível; o assistente continua funcionando.',
        );
      }
    } finally {
      if (_sameSession(session)) {
        _loading = false;
        _notify();
      }
      _finishTask();
    }
  }

  Future<void> enviarMensagem(String mensagem) async {
    final text = mensagem.trim();
    if (_disposed || ocupado || text.isEmpty) return;
    final session = _session;
    final user = _idUsuario;
    _tasks++;
    _sending = true;
    _messages.add(ChatMessageModel(texto: text, usuario: true));
    _notify();
    try {
      final answer = await _chatbot.enviarMensagem(text);
      if (!_sameSession(session)) return;
      if (!_disposed) {
        _messages.add(
          ChatMessageModel(
            texto: answer.resposta,
            usuario: false,
            fontes: List.unmodifiable(answer.fontes),
            ehErro: !answer.contextoSuficiente,
          ),
        );
      }
      // Mostrar a resposta e liberar o envio antes de aguardar a Node.
      _sending = false;
      if (user != null) _enqueueSave(session, user, text, answer.resposta);
      _notify();
    } catch (_) {
      if (_sameSession(session) && !_disposed) {
        _messages.add(
          ChatMessageModel(texto: mensagemErro, usuario: false, ehErro: true),
        );
      }
    } finally {
      if (_sameSession(session)) {
        _sending = false;
        _notify();
      }
      _finishTask();
    }
  }

  void _enqueueSave(int session, int user, String question, String answer) {
    _tasks++;
    // Serializar gravações para manter a ordem e limpar somente depois delas.
    _saveTail = _saveTail
        .then((_) async {
          if (!_sameSession(session)) return;
          try {
            await _history.salvarMensagens(
              idUsuario: user,
              pergunta: question,
              resposta: answer,
            );
            if (_sameSession(session)) erroSalvamento = null;
          } catch (_) {
            if (_sameSession(session)) {
              erroSalvamento = 'Não foi possível salvar o histórico.';
              debugPrint('Não foi possível salvar o histórico do chat.');
            }
          }
        })
        .whenComplete(_finishTask);
  }

  Future<void> aguardarSalvamentos() => _saveTail;

  Future<void> limparHistorico() async {
    final user = _idUsuario;
    if (_disposed || user == null || ocupado) return;
    final session = _session;
    _tasks++;
    _clearing = true;
    _notify();
    try {
      await _saveTail;
      if (!_sameSession(session)) return;
      await _history.limparHistorico(user);
      if (_sameSession(session) && !_disposed) {
        _messages.clear();
        erroHistorico = null;
        erroSalvamento = null;
      }
    } finally {
      if (_sameSession(session)) {
        _clearing = false;
        _notify();
      }
      _finishTask();
    }
  }

  void _finishTask() {
    _tasks--;
    _releaseIfFinished();
  }

  void _releaseIfFinished() {
    if (!_disposed || _tasks != 0 || _released) return;
    _released = true;
    _auth.removeListener(_onAuthChanged);
    _chatbot.dispose();
    _history.dispose();
  }

  @override
  void dispose() {
    // Uma resposta em andamento ainda pode ser salva ao fechar o painel.
    _disposed = true;
    _releaseIfFinished();
    super.dispose();
  }
}
