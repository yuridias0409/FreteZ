import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretez/Model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterStep3 extends StatefulWidget {
  final Usuario usuario;

  RegisterStep3({Key key, @required this.usuario}) : super(key: key);

  @override
  _RegisterStep3State createState() => _RegisterStep3State();
}

class _RegisterStep3State extends State<RegisterStep3> {
  bool _tipoUsuario = false;
  //valida campos
  String _mensagemErro = "";



  _validarCampos() {
    widget.usuario.isMotorista = _tipoUsuario;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    auth.createUserWithEmailAndPassword(
        email: widget.usuario.email,
        password: widget.usuario.password
    ).then((firebaseUser){
      db.collection("usuarios")
          .doc(firebaseUser.user.uid)
          .set(widget.usuario.toMap());
      switch(_tipoUsuario){
        case true:
          Navigator.pushNamedAndRemoveUntil(context, "/painelMotorista", (_) => false);
          break;
        case false:
          Navigator.pushNamedAndRemoveUntil(context, "/painelPassageiro", (_) => false);
          break;
      }
    }).catchError((error){
      _mensagemErro = "Erro ao cadastrar o usuário";
    });
  }
  //Fim valida campos

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var widthScreen = size.width;
    var heightScreen = size.height;
    return Scaffold(
      body: Container(
        width: widthScreen,
        height: heightScreen,
        decoration: BoxDecoration(color: Color(0xff333333)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child:
                      Image.asset("images/Logo.png", width: 350, height: 200),
                ),
                Center(
                  child: Text(
                    _mensagemErro,
                    style: TextStyle(color: Colors.red, fontSize: 22),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 30, top: 50),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Deseja ser motorista?",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      Switch(
                        value: _tipoUsuario,
                        onChanged: (bool valor) {
                          setState(() {
                            _tipoUsuario = valor;
                          });
                        },
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 30),
                  child: Center(
                    child: RaisedButton(
                      color: Color(0xff6DF893),
                      child: Text(
                        "Cadastrar",
                        style: TextStyle(fontSize: 25),
                      ),
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        _validarCampos();
                      },
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 70)),
                Divider(
                  color: Colors.white,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10, top: 15),
                  child: FlatButton(
                    child: Text(
                      "Já tem conta? Entre",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    shape: CircleBorder(
                        side: BorderSide(color: Colors.transparent)),
                    onPressed: () {
                      Navigator.pushNamed(context, "/");
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
