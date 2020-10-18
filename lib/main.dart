import 'package:flutter/material.dart';
import 'file:///D:/AndroidStudioProjects/fretez/lib/Views/Login.dart';
import 'package:fretez/Rotas.dart';


void main() {
  runApp(MaterialApp(
    title: 'FretZ',
    home: Login(),
    initialRoute: "/",
    onGenerateRoute: Rotas.gerarRotas,
    debugShowCheckedModeBanner: false,
  ));
}

