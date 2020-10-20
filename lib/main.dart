import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fretez/Rotas.dart';
import 'package:fretez/Views/Login/Login.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: 'FretZ',
    home: Login(),
    initialRoute: "/",
    onGenerateRoute: Rotas.gerarRotas,
    debugShowCheckedModeBanner: false,
  ));
}

