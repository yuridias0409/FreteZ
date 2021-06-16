import 'package:flutter/material.dart';
import 'package:fretez/Views/Login/Login.dart';
import 'package:fretez/Views/Painel/PainelCorrida.dart';
import 'package:fretez/Views/Register/RegisterStep0.dart';
import 'package:fretez/Views/Register/RegisterStep1.dart';
import 'package:fretez/Views/Register/RegisterStep2.dart';
import 'package:fretez/Views/Register/RegisterStep3.dart';
import 'package:fretez/Views/Painel/PainelPassageiro.dart';
import 'package:fretez/Views/Painel/PainelMotorista.dart';

class Rotas {
  static Route<dynamic> gerarRotas(RouteSettings settings){
    final args = settings.arguments;

    switch( settings.name ){
      case "/":
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      case "/registerstep0":
        return MaterialPageRoute(
            builder: (_) => RegisterStep0()
        );
      case "/registerstep1":
        return MaterialPageRoute(
            builder: (_) => RegisterStep1()
        );
      case "/registerstep2":
        return MaterialPageRoute(
            builder: (_) => RegisterStep2()
        );
      case "/registerstep3":
        return MaterialPageRoute(
            builder: (_) => RegisterStep3()
        );
      case "/painelPassageiro":
        return MaterialPageRoute(
            builder: (_) => PainelPassageiro()
        );
      case "/painelMotorista":
        return MaterialPageRoute(
            builder: (_) => PainelMotorista()
        );
      case "/painelCorrida":
        return MaterialPageRoute(
            builder: (_) => PainelCorrida(args)
        );
    }
  }

}