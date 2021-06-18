import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:fretez/Model/Usuario.dart';

class UsuarioFirebase {
  static Future<User> getUsuarioAtual() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return await auth.currentUser;
  }

  static Future<Usuario> getDadosUsuarioLogado() async {
    User user = await getUsuarioAtual();
    String idUsuario = user.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await db.collection("usuarios")
      .doc(idUsuario)
      .get();

    Map<String, dynamic> dados = snapshot.data();
    bool isMotorista = dados["isMotorista"];
    String email = dados["email"];
    String name = dados["name"];

    Usuario usuario = Usuario();
    usuario.userid = idUsuario;
    usuario.isMotorista = isMotorista;
    usuario.email = email;
    usuario.name = name;

    return usuario;
  }

  static atualizarDadosLocalizacao(String idRequisicao, double lat, double long, String tipo) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    Usuario usuario = await getDadosUsuarioLogado();
    usuario.longitude = long;
    usuario.latitude = lat;

    db.collection("requisicoes")
      .doc(idRequisicao)
      .update({
        "$tipo": usuario.toMap()
      });
  }

}