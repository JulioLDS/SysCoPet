import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/user_model.dart';

/// Mostra a prévia local, a foto da conta ou as iniciais, nessa ordem.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.bytes,
    this.radius = 24,
    this.fontSize = 16,
    this.backgroundColor = const Color(0xFFECFDF5),
    this.foregroundColor = const Color(0xFF0D9488),
  });

  final UserModel? user;
  final Uint8List? bytes;
  final double radius;
  final double fontSize;
  final Color backgroundColor;
  final Color foregroundColor;

  Widget _buildInitials() {
    final nome = user?.nome.trim() ?? '';
    final iniciais = nome.isEmpty
        ? 'U'
        : nome.characters.take(2).toString().toUpperCase();

    return Center(
      child: Text(
        iniciais,
        style: TextStyle(
          color: foregroundColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final urlFoto = user?.urlFoto?.trim();
    Widget image;

    if (bytes != null) {
      image = Image.memory(
        bytes!,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildInitials(),
      );
    } else if (urlFoto != null && urlFoto.isNotEmpty) {
      image = Image.network(
        urlFoto,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _buildInitials(),
        errorBuilder: (context, error, stackTrace) => _buildInitials(),
      );
    } else {
      image = _buildInitials();
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: ClipOval(
        child: SizedBox(width: diameter, height: diameter, child: image),
      ),
    );
  }
}
