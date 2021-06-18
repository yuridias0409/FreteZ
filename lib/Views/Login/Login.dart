import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fretez/Model/Usuario.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();

  //valida campos
  String _mensagemErro = "";
  _validarCampos(){
    if(_controllerEmail.text.isNotEmpty && _controllerSenha.text.isNotEmpty){
      _logarUsuario();
    } else{
      _mensagemErro = "Preencha todos os campos!";
    }
  }
  //fim valida campos

  _redirecionaPorTipoDeUsuario(String idUsuario) async{
    FirebaseFirestore db = FirebaseFirestore.instance;

    DocumentSnapshot snapshot = await db.collection("usuarios")
      .doc(idUsuario)
      .get();

    Map<String, dynamic> dados = snapshot.data();
    bool tipoUsuario = dados["isMotorista"];

    if(tipoUsuario){
      Navigator.pushReplacementNamed(context, "/painelMotorista");
    } else{
      Navigator.pushReplacementNamed(context, "/painelRequisitante");
    }
  }

  _logarUsuario(){
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
        email: _controllerEmail.text, 
        password: Usuario().hashPassword(_controllerSenha.text)
    ).then((firebaseUser){
      _redirecionaPorTipoDeUsuario(firebaseUser.user.uid);
    }).catchError((error){
      _mensagemErro = "Erro ao autenticar usuário";
    });
  }

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
                  padding: EdgeInsets.only(bottom: 2),
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
                  padding: EdgeInsets.only(bottom: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SignInButton(
                        Buttons.Facebook,
                        mini: true,
                        text: "Facebook",
                        onPressed: () {},
                      ),
                      SignInButton(
                        Buttons.Twitter,
                        mini: true,
                        text: "Twitter",
                        onPressed: () {},
                      ),
                      Padding(padding: EdgeInsets.only(right: 5)),
                      SignInButton(
                        Buttons.GoogleDark,
                        text: "Logar com Google",
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.white,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 30, top: 15),
                  child: TextField(
                    controller: _controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                  ),
                ),
                TextField(
                  controller: _controllerSenha,
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.white,
                  obscureText: true,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                      hintText: "Senha",
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 10),
                    child: Row(
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            "Esqueceu a Senha?",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                          shape: CircleBorder(
                              side: BorderSide(color: Colors.transparent)),
                          onPressed: () {},
                        ),
                        Padding(padding: EdgeInsets.only(right: 50)),
                        RaisedButton(
                          color: Color(0xff6DF893),
                          child: Text(
                            "Logar",
                            style: TextStyle(fontSize: 25),
                          ),
                          padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32)),
                          onPressed: () {
                            _validarCampos();
                          },
                        ),
                      ],
                    )),
                Padding(padding: EdgeInsets.only(top: 15)),
                Divider(
                  color: Colors.white,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10, top: 15),
                  child: FlatButton(
                    child: Text(
                      "Ainda não tem conta? Registre-se",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    shape: CircleBorder(
                        side: BorderSide(color: Colors.transparent)),
                    onPressed: () {
                      Navigator.pushNamed(context, "/registerstep0");
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
