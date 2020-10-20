import 'package:flutter/material.dart';
import 'package:fretez/Rotas.dart';
import 'package:fretez/Views/Login/Login.dart';


void main() {
  runApp(MaterialApp(
    title: 'FretZ',
    home: Login(),
    initialRoute: "/",
    onGenerateRoute: Rotas.gerarRotas,
    debugShowCheckedModeBanner: false,
  ));
}

