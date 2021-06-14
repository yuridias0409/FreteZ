import 'package:crypto/crypto.dart';
import 'dart:convert';

class Usuario {
  int userid;
  String name;
  String date_of_birth;
  String cpf;
  String email;
  String password;
  bool isMotorista;

  Usuario();

  String hashPassword(password){
    return md5.convert(utf8.encode(password)).toString();
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "name": this.name,
      "email": this.email,
      "dateOfBirth": this.date_of_birth,
      "isMotorist": this.isMotorista,
      "cpf": this.cpf
    };
    return map;
  }
}