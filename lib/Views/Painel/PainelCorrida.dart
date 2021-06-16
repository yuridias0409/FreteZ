import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretez/Model/Usuario.dart';
import 'package:fretez/Utils/StatusRequisicao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fretez/Utils/UsuarioFirebase.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fretez/Widgets/SideMenu.dart';

class PainelCorrida extends StatefulWidget {
  String idRequisicao;

  PainelCorrida(this.idRequisicao);

  @override
  _PainelCorridaState createState() => _PainelCorridaState();
}

class _PainelCorridaState extends State<PainelCorrida> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition = CameraPosition(target: LatLng(-23.563999, -46.653256));

  Map<String, dynamic> _dadosRequisicao;

  Position _localMotorista;

  //Controles exibição na tela
  String _textoBotao = "Aceitar Corrida";
  Color _corBotao = Color(0xff6df893);
  Function _funcaoBotao;

  _alterarBotaoPrincipal(String texto, Color cor, Function funcao){
    setState(() {
      _textoBotao = texto;
      _corBotao = cor;
      _funcaoBotao = funcao;
    });
  }

  Set<Marker> _marcadores = {};
  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _moveCamera(CameraPosition position) async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  _moveCameraBounds(LatLngBounds latLngBounds) async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          latLngBounds,
          100
      )
    );
  }

  _getLastKnownLocation() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      if (position != null) {
        _cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 19);

        //_moveCamera(_cameraPosition);
        _localMotorista = position;
      }
    });
  }

  _addLocationListener() {
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    geolocator.getPositionStream(locationOptions).listen((Position position) {
      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 19);
      //_moveCamera(_cameraPosition);
      setState(() {
        _localMotorista = position;
      });
    });
  }

  _recuperarRequisicao() async {
    String idRequisicao = widget.idRequisicao;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot documentSnapshot = await db
        .collection("requisicoes")
        .doc(idRequisicao)
        .get();

    _dadosRequisicao = documentSnapshot.data();
    _adicionarListennerRequisicao();
  }

  _adicionarListennerRequisicao() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String idRequisicao = _dadosRequisicao["id"];
    await db.collection("requisicoes")
      .doc(idRequisicao)
    .snapshots().listen((snapshot) {
      if(snapshot.data() != null){
        Map<String, dynamic> dados = snapshot.data();
        String status = dados["status"];
        switch(status){
          case StatusRequisicao.AGUARDANDO:
            _statusAguardando();
            break;
          case StatusRequisicao.A_CAMINHO:
            _statusACaminho();
            break;
          case StatusRequisicao.VIAGEM:
            break;
          case StatusRequisicao.FINALIZADA:
            break;
        }
      }
    });
  }

  _statusAguardando(){
    _alterarBotaoPrincipal("Aceitar Corrida", Color(0xff6df893), (){ _aceitarCorrida(); });
  }

  _statusACaminho(){
    _alterarBotaoPrincipal("A caminho do passageiro", Colors.grey, null);

    double latitudeRequisitante = _dadosRequisicao["entrega"]["latitude"];
    double longitudeRequisitante = _dadosRequisicao["entrega"]["longitude"];

    double latitudeMotorista = _dadosRequisicao["motorista"]["latitude"];
    double longitudeMotorista = _dadosRequisicao["motorista"]["longitude"];

    _exibirMarcadorRequisitante(LatLng(latitudeRequisitante, longitudeRequisitante));

    //Ajuda a camera para mostrar os dois
    var nLat, nLon, sLat, sLon;

    if(latitudeMotorista <= latitudeRequisitante){
      sLat = latitudeMotorista;
      nLat = latitudeRequisitante;
    } else{
      sLat = latitudeRequisitante;
      nLat = latitudeMotorista;
    }

    if(longitudeMotorista <= longitudeRequisitante){
      sLon = longitudeMotorista;
      nLon = longitudeRequisitante;
    } else{
      sLon = longitudeRequisitante;
      nLon = longitudeMotorista;
    }

    _moveCameraBounds(
        LatLngBounds(
            northeast: LatLng(nLat, nLon),
            southwest: LatLng(sLat, sLon)
        )
    );
  }

  _exibirMarcadorRequisitante(LatLng latLngRequisitante){
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    Set<Marker> _listaMarcadores = {}; 

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "images/entrega.png")
        .then((BitmapDescriptor icone) {
      Marker marcador = Marker(
          markerId: MarkerId("marcador-entrega"),
          position: LatLng(latLngRequisitante.latitude, latLngRequisitante.longitude),
          infoWindow: InfoWindow(title: "Local Requisitante"),
          icon: icone);
      _listaMarcadores.add(marcador);
    });

    setState(() {
      _marcadores = _listaMarcadores;
    });

  }
  
  _aceitarCorrida() async {
    Usuario motorista = await UsuarioFirebase.getDadosUsuarioLogado();
    motorista.latitude = _localMotorista.latitude;
    motorista.longitude = _localMotorista.longitude;

    FirebaseFirestore db = FirebaseFirestore.instance;
    String idRequisicao = _dadosRequisicao["id"];
    
    db.collection("requisicoes")
      .doc(idRequisicao)
      .update({
         "motorista": motorista.toMap(),
         "status": StatusRequisicao.A_CAMINHO
      }).then((_){
        String idRequisitante = _dadosRequisicao["entrega"]["userid"];
        db.collection("requisicao_ativa").doc(idRequisitante).update({
          "status": StatusRequisicao.A_CAMINHO
        });

        String idMotorista = motorista.userid;
        db.collection("requisicao_ativa_motorista").doc(idMotorista).set({
          "id_requisicao": idRequisicao,
          "id_usuario": idMotorista,
          "status": StatusRequisicao.A_CAMINHO
        });
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLastKnownLocation();
    _addLocationListener();
    _recuperarRequisicao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        endDrawer: SideMenu(),
        body: Container(
            child: Stack(children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _cameraPosition,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _marcadores,
          ),
          Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: RaisedButton(
                    child: Text(
                      _textoBotao,
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    color: _corBotao,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: _funcaoBotao),
              ))
        ])));
  }
}
