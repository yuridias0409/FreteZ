import 'package:flutter/material.dart';
import 'file:///D:/AndroidStudioProjects/fretez/lib/Views/Login.dart';
import 'file:///D:/AndroidStudioProjects/fretez/lib/Views/RegisterStep1.dart';
import 'file:///D:/AndroidStudioProjects/fretez/lib/Views/RegisterStep2.dart';

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
    }
  }

}