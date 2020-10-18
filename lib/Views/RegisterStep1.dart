import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterStep1 extends StatefulWidget {
  @override
  _RegisterStep1State createState() => _RegisterStep1State();
}

class _RegisterStep1State extends State<RegisterStep1> {
  TextEditingController _controllerCPF = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var widthScreen = size.width;
    var heightScreen = size.height;
    var maskFormatterCpf = new MaskTextInputFormatter(mask: '###.###.###-##', filter: { "#": RegExp(r'[0-9]') });
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
                    "Erro",
                    style: TextStyle(color: Colors.red, fontSize: 22),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: TextField(
                      controller: _controllerCPF,
                      inputFormatters: [maskFormatterCpf],
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "CPF",
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
                        Navigator.pushNamed(context, "/registerstep2");
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
