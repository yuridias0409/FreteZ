import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fretez/Model/Destino.dart';
import 'Usuario.dart';

class Requisicao {
  String _id;
  String _status;
  Usuario _entrega;
  Usuario _motorista;
  Destino _destino;

  Requisicao(){
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference ref = db.collection("requisicoes").doc();
    this.id = ref.id;
  }


  Map<String, dynamic> toMap(){
    Map<String, dynamic> dadosRequisitante = {
      "userid": this.requisitante.userid,
      "name": this.requisitante.name,
      "email": this.requisitante.email,
      "isMotorista": this.requisitante.isMotorista,
      "longitude": this.requisitante.longitude,
      "latitude": this.requisitante.latitude,
    };

    Map<String, dynamic> dadosDestino = {
      "rua": this.destino.rua,
      "numero": this.destino.numero,
      "bairro": this.destino.bairro,
      "cep": this.destino.cep,
      "latitude": this.destino.latitude,
      "longitude": this.destino.longitude,
    };

    Map<String, dynamic> dadosRequisicao = {
      "id": this.id,
      "status": this.status,
      "requisitante": dadosRequisitante,
      "motorista": null,
      "destino": dadosDestino,
    };
    return dadosRequisicao;
  }

  Destino get destino => _destino;

  set destino(Destino value) {
    _destino = value;
  }

  Usuario get motorista => _motorista;

  set motorista(Usuario value) {
    _motorista = value;
  }

  Usuario get requisitante => _entrega;

  set requisitante(Usuario value) {
    _entrega = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
}