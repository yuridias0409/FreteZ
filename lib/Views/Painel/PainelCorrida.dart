import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretez/Utils/StatusRequisicao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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

  _getLastKnownLocation() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      if (position != null) {
        _cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 19);

        _moveCamera(_cameraPosition);
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
      _moveCamera(_cameraPosition);
    });
  }

  //Utilizar somente dps da requisição ser feita
  _exibirMarcadorMotorista(Position local) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: pixelRatio),
            "imagens/motorista.png")
        .then((BitmapDescriptor icone) {
      Marker marcadorEntrega = Marker(
          markerId: MarkerId("marcador-motorista"),
          position: LatLng(local.latitude, local.longitude),
          infoWindow: InfoWindow(title: "Meu Local"),
          icon: icone);
      setState(() {
        _marcadores.add(marcadorEntrega);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLastKnownLocation();
    _addLocationListener();
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
