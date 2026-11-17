class UserModel {
  final int id;
  final String nome;
  final String email;
  final String? urlFoto;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    this.urlFoto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id'].toString()),
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      urlFoto: json['url_foto']?.toString(),
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'nome': nome,
      'email': email,
      'url_foto': urlFoto
    };
  }

  UserModel copyWith({
    int? id,
    String? nome,
    String? email,
    String? urlFoto,
    bool removerFoto = false,
       }) {
    return UserModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      urlFoto: removerFoto ? null : urlFoto ?? this.urlFoto,
    );
  }
}