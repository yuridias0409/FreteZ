import 'package:crypto/crypto.dart';
import 'dart:convert';

class Usuario {
  String _userid;
  String _name;
  String _date_of_birth;
  String _cpf;
  String _email;
  String _password;
  bool _isMotorista;

  double _latitude;
  double _longitude;

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  Usuario();


  String get userid => _userid;

  set userid(String value) {
    _userid = value;
  }

  String hashPassword(password){
    return md5.convert(utf8.encode(password)).toString();
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "name": this.name,
      "email": this.email,
      "dateOfBirth": this.date_of_birth,
      "isMotorist": this.isMotorista,
      "cpf": this.cpf,
      "latitude": this.latitude,
      "longitude": this.longitude
    };
    return map;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get date_of_birth => _date_of_birth;

  set date_of_birth(String value) {
    _date_of_birth = value;
  }

  String get cpf => _cpf;

  set cpf(String value) {
    _cpf = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  bool get isMotorista => _isMotorista;

  set isMotorista(bool value) {
    _isMotorista = value;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }
}