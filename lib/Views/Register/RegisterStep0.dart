import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretez/Model/Usuario.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'RegisterStep1.dart';

class RegisterStep0 extends StatefulWidget {
  @override
  _RegisterStep0State createState() => _RegisterStep0State();
}

class _RegisterStep0State extends State<RegisterStep0> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerIdade = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  //valida campos
  String _mensagemErro = "";
  _validarCampos(){
    if(_controllerNome.text.isNotEmpty && _controllerIdade.text.isNotEmpty && _controllerEmail.text.isNotEmpty){
      Usuario _usuario = new Usuario();
      _usuario.name = _controllerNome.text;
      _usuario.date_of_birth = _controllerIdade.text;
      _usuario.email = _controllerEmail.text;

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return RegisterStep1(usuario: _usuario);
      }));

    } else{
      if(_controllerIdade.text.isEmpty){
        setState(() {
          _mensagemErro = "Digite sua data de nascimento";
        });
      } else if(_controllerNome.text.isEmpty){
        _mensagemErro = "Digite seu nome completo";
      }
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
                      controller: _controllerNome,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Qual é o seu nome completo?",
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                      ),
                    )
                ),
                TextField(
                  controller: _controllerIdade,
                  inputFormatters: [maskFormatterData],
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: "Quando você nasceu?",
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 30)),
                TextField(
                  controller: _controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: "Qual é seu email?",
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
