import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:fretez/Views/Register/RegisterStep3.dart';
import 'file:///D:/AndroidStudioProjects/fretez/lib/Views/Login.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterStep4 extends StatefulWidget {
  @override
  _RegisterStep4State createState() => _RegisterStep4State();
}

class _RegisterStep4State extends State<RegisterStep4> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerDataNascimento = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  TextEditingController _controllerConfirmarSenha = TextEditingController();

  //valida campos
  String _mensagemErro = "";
  //fim valida campos

  //checkbox
  bool _cbTermosDeUso = false;
  void _cbTermosDeUsoChanged(bool value) => setState(() => _cbTermosDeUso = value);
  //fim checkbox

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
                  padding: EdgeInsets.only(bottom: 20, top: 20),
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
                Padding(padding: EdgeInsets.only(bottom: 20, top: 5)),
                TextField(
                  controller: _controllerConfirmarSenha,
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.white,
                  obscureText: true,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                      hintText: "Confirmar Senha",
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: new Center(
                    child: new Column(
                      children: <Widget>[
                        new CheckboxListTile(
                          value: _cbTermosDeUso,
                          onChanged: _cbTermosDeUsoChanged,
                          title: new Text('Confirmo que li e aceito os termos de uso', style: TextStyle(color: Colors.white, fontSize: 12),),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Color(0xff6DF893),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 45, bottom: 30),
                  child: Center(
                    child: RaisedButton(
                      color: Color(0xff6DF893),
                      child: Text(
                        "Criar Conta",
                        style: TextStyle(fontSize: 25),
                      ),
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {},
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
