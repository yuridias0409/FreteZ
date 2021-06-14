import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:fretez/Model/Usuario.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cpfcnpj/cpfcnpj.dart';

import 'RegisterStep3.dart';

class RegisterStep2 extends StatefulWidget {
  final Usuario usuario;

  RegisterStep2({Key key, @required this.usuario}) : super(key: key);

  @override
  _RegisterStep2State createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  TextEditingController _controllerSenha = TextEditingController();
  TextEditingController _controllerConfirmarSenha = TextEditingController();
  //valida campos
  String _mensagemErro = "";

  _validarCampos(){
    if(_controllerSenha.text.isNotEmpty && _controllerConfirmarSenha.text.isNotEmpty){
      if(_controllerSenha.text == _controllerConfirmarSenha.text){
        widget.usuario.password = widget.usuario.hashPassword(_controllerSenha.text);

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return RegisterStep3(usuario: widget.usuario);
        }));

      } else {
        _mensagemErro = "Senhas não conferem";
      }
    } else{
      _mensagemErro = "Digite as senhas!";
    }
  }
  //Fim valida campos

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var widthScreen = size.width;
    var heightScreen = size.height;
    var maskFormatterData = new MaskTextInputFormatter(mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
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
                    child: TextField(
                      autofocus: true,
                      controller: _controllerSenha,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Digite sua senha",
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
                  autofocus: true,
                  controller: _controllerConfirmarSenha,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: "Confirme sua senha!",
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 30),
                  child: Center(
                    child: RaisedButton(
                      color: Color(0xff6DF893),
                      child: Text(
                        "Próximo",
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
