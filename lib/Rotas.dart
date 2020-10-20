import 'package:flutter/material.dart';
import 'package:fretez/Views/Login/Login.dart';
import 'package:fretez/Views/Register/RegisterStep1.dart';
import 'package:fretez/Views/Register/RegisterStep2.dart';
import 'package:fretez/Views/Register/RegisterStep4.dart';


class Rotas {
  static Route<dynamic> gerarRotas(RouteSettings settings){
    switch( settings.name ){
      case "/":
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      case "/registerstep1":
        return MaterialPageRoute(
            builder: (_) => RegisterStep1()
        );
      case "/registerstep2":
        return MaterialPageRoute(
            builder: (_) => RegisterStep2()
        );
      case "/registerstep4":
        return MaterialPageRoute(
            builder: (_) => RegisterStep4()
        );
    }
  }

}