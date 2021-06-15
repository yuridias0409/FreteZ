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
    bool isMotorist = dados["isMotorist"];
    String email = dados["email"];
    String name = dados["name"];

    Usuario usuario = Usuario();
    usuario.userid = idUsuario;
    usuario.isMotorista = isMotorist;
    usuario.email = email;
    usuario.name = name;

    return usuario;
  }

}