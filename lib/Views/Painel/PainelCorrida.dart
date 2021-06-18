import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretez/Model/Marcador.dart';
import 'package:fretez/Model/Usuario.dart';
import 'package:fretez/Utils/StatusRequisicao.dart';
import 'package:flutter/cupertino.dart';
import 'package:fretez/Utils/UsuarioFirebase.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fretez/Widgets/SideMenu.dart';
import 'package:intl/intl.dart';

class PainelCorrida extends StatefulWidget {
  String idRequisicao;

  PainelCorrida(this.idRequisicao);

  @override
  _PainelCorridaState createState() => _PainelCorridaState();
}

class _PainelCorridaState extends State<PainelCorrida> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition = CameraPosition(target: LatLng(-23.563999, -46.653256));
  String _idRequisicao;
  Position _localMotorista;
  String _statusRequisicao = StatusRequisicao.AGUARDANDO;

  Map<String, dynamic> _dadosRequisicao;

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

  _getLastKnownLocation() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    if (position != null) {
      //Atualiza em tempo real
    }
  }

  _addLocationListener() {
    var geolocator = Geolocator();
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    geolocator.getPositionStream(locationOptions).listen((Position position) {
      if( _idRequisicao != null && _idRequisicao.isNotEmpty ){
        if(_statusRequisicao != StatusRequisicao.AGUARDANDO){
          UsuarioFirebase.atualizarDadosLocalizacao(
              _idRequisicao,
              position.latitude,
              position.longitude,
              "motorista"
          );
        } else{
          setState(() {
            _localMotorista = position;
          });
          _statusAguardando();
        }
      }
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
    await db.collection("requisicoes")
        .doc( _idRequisicao ).snapshots().listen((snapshot){

      if( snapshot.data != null ){

        _dadosRequisicao = snapshot.data();

        Map<String, dynamic> dados = snapshot.data();
        _statusRequisicao = dados["status"];

        switch( _statusRequisicao ){
          case StatusRequisicao.AGUARDANDO :
            _statusAguardando();
            break;
          case StatusRequisicao.A_CAMINHO :
            _statusACaminho();
            break;
          case StatusRequisicao.VIAGEM :
            _statusEmViagem();
            break;
          case StatusRequisicao.FINALIZADA :
            _statusFinalizada();
            break;
          case StatusRequisicao.CONFIRMADA :
            _statusConfirmado();
            break;
        }
      }
    });
  }


  _exibirMarcador(Position local, String icone, String infoWindow) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        icone)
        .then((BitmapDescriptor bitmapDescriptor) {
      Marker marcador = Marker(
          markerId: MarkerId(icone),
          position: LatLng(local.latitude, local.longitude),
          infoWindow: InfoWindow(title: infoWindow),
          icon: bitmapDescriptor);

      setState(() {
        _marcadores.add(marcador);
      });
    });
  }

  _statusConfirmado(){
    Navigator.pushReplacementNamed(context, "/painelMotorista");
  }

  _statusFinalizada() async{
    double latitudeDestino = _dadosRequisicao["destino"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destino"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["origem"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["origem"]["longitude"];

    double distanciaEmMetros = await Geolocator().distanceBetween(latitudeOrigem, longitudeOrigem, latitudeDestino, longitudeDestino);

    //Converte para KM
    double distanciaKm = distanciaEmMetros / 1000;

    //Dados sobre combustivel
    double precoCombustivel = 4.17;
    double mediaConsumo = 11.1;

    //Lucro de R$2.05 KM rodados
    double lucro = distanciaKm * 2.05;

    double valorViagem = ((precoCombustivel / mediaConsumo) * distanciaKm) + lucro;

    //Formatar preço
    var f = NumberFormat('#,##0.00', 'pt_BR');
    var valorViagemFormatado = f.format(valorViagem);

    _alterarBotaoPrincipal(
        "Confirmar - R\$ $valorViagemFormatado",
        Color(0xff87d19b),
            (){
          _confirmaCorrida();
        }
    );

    _marcadores = {};

    Position position = Position(
      latitude: latitudeDestino,
      longitude: longitudeDestino,
    );

    _exibirMarcador(position, "images/localentrega.png", "Destino");

    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 19);

    _movimentarCamera(cameraPosition);
  }

  _confirmaCorrida(){

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes")
        .doc(_idRequisicao)
        .update({
          "status": StatusRequisicao.CONFIRMADA
        });

    String idRequisitante = _dadosRequisicao["requisitante"]["userid"];
    db.collection("requisicao_ativa")
        .doc(idRequisitante)
        .delete();

    String idMotorista = _dadosRequisicao["motorista"]["userid"];
    db.collection("requisicao_ativa_motorista")
        .doc(idMotorista)
        .delete();

  }

  _statusAguardando(){
    _alterarBotaoPrincipal("Aceitar Corrida", Color(0xff6df893), (){ _aceitarCorrida(); });

    if(_localMotorista != null){
      double motoristaLat = _localMotorista.latitude;
      double motoristaLon = _localMotorista.longitude;

      Position position = Position(
        latitude: motoristaLat,
        longitude: motoristaLon,
      );

      _exibirMarcador(position, "images/motorista.png", "Motorista");

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 19);

      _movimentarCamera(cameraPosition);
    }
  }

  _statusACaminho(){
    _alterarBotaoPrincipal(
        "Iniciar corrida",
        Color(0xff87d19b),
            (){
          _iniciarCorrida();
        }
    );

    double latitudeRequisitante = _dadosRequisicao["requisitante"]["latitude"];
    double longitudeRequisitante = _dadosRequisicao["requisitante"]["longitude"];

    double latitudeMotorista = _dadosRequisicao["motorista"]["latitude"];
    double longitudeMotorista = _dadosRequisicao["motorista"]["longitude"];

    Marcador marcadorOrigem = Marcador(LatLng(latitudeRequisitante, longitudeRequisitante), "images/requisitante.png", "Local Requisitante");
    Marcador marcadorDestino = Marcador(LatLng(latitudeMotorista, longitudeMotorista), "images/motorista.png", "Local Motorista");

    _exibirCentralizarDoisMarcadores(marcadorOrigem, marcadorDestino);
  }

  _finalizarCorrida(){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes")
      .doc(_idRequisicao)
      .update({
        "status": StatusRequisicao.FINALIZADA
      });

    String idRequisitante = _dadosRequisicao["requisitante"]["userid"];
    db.collection("requisicao_ativa")
        .doc(idRequisitante)
        .update({"status": StatusRequisicao.FINALIZADA});

    String idMotorista = _dadosRequisicao["motorista"]["userid"];
    db.collection("requisicao_ativa_motorista")
        .doc(idMotorista)
        .update({"status": StatusRequisicao.FINALIZADA});
  }

  _statusEmViagem(){
    _alterarBotaoPrincipal(
        "Finalizar Corrida",
        Color(0xff87d19b),
            (){
          _finalizarCorrida();
        }
    );

    double latitudeDestino = _dadosRequisicao["destino"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destino"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["motorista"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["motorista"]["longitude"];

    Marcador marcadorOrigem = Marcador(LatLng(latitudeOrigem, longitudeOrigem), "images/motorista.png", "Local Motorista");
    Marcador marcadorDestino = Marcador(LatLng(latitudeDestino, longitudeDestino), "images/localentrega.png", "Local Destino");

    _exibirCentralizarDoisMarcadores(marcadorOrigem, marcadorDestino);

  }

  _exibirCentralizarDoisMarcadores(Marcador marcadorOrigem, Marcador marcadorDestino ){
    double latitudeOrigem = marcadorOrigem.local.latitude;
    double longitudeOrigem = marcadorOrigem.local.longitude;
    double latitudeDestino = marcadorDestino.local.latitude;
    double longitudeDestino = marcadorDestino.local.longitude;

    //Exibir dois marcadores
    _exibirDoisMarcadores(
        marcadorOrigem,
        marcadorDestino
    );

    var nLat, nLon, sLat, sLon;

    if( latitudeOrigem <=  latitudeDestino ){
      sLat = latitudeOrigem;
      nLat = latitudeDestino;
    }else{
      sLat = latitudeDestino;
      nLat = latitudeOrigem;
    }

    if( longitudeOrigem <=  longitudeDestino ){
      sLon = longitudeOrigem;
      nLon = longitudeDestino;
    }else{
      sLon = longitudeDestino;
      nLon = longitudeOrigem;
    }

    _movimentarCameraBounds(
        LatLngBounds(
            northeast: LatLng(nLat, nLon), //nordeste
            southwest: LatLng(sLat, sLon) //sudoeste
        )
    );
  }


  _movimentarCameraBounds(LatLngBounds latLngBounds) async {

    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(
        CameraUpdate.newLatLngBounds(
            latLngBounds,
            100
        )
    );

  }

  _iniciarCorrida(){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes")
      .doc(_idRequisicao)
      .update({
        "origem":{
          "latitude": _dadosRequisicao["motorista"]["latitude"],
          "longitude": _dadosRequisicao["motorista"]["longitude"]
        },
        "status": StatusRequisicao.VIAGEM
      });

    String idRequisitante = _dadosRequisicao["requisitante"]["userid"];
    db.collection("requisicao_ativa")
      .doc(idRequisitante)
      .update({"status": StatusRequisicao.VIAGEM});

    String idMotorista = _dadosRequisicao["motorista"]["userid"];
    db.collection("requisicao_ativa_motorista")
        .doc(idMotorista)
        .update({"status": StatusRequisicao.VIAGEM});
  }

  _exibirDoisMarcadores(Marcador marcadorOrigem, Marcador marcadorDestino){

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    LatLng latLngOrigem = marcadorOrigem.local;
    LatLng latLngDestino = marcadorDestino.local;

    Set<Marker> _listaMarcadores = {};
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        marcadorOrigem.caminhoImagem)
        .then((BitmapDescriptor icone) {
      Marker mOrigem = Marker(
          markerId: MarkerId(marcadorOrigem.caminhoImagem),
          position: LatLng(latLngOrigem.latitude, latLngOrigem.longitude),
          infoWindow: InfoWindow(title: marcadorOrigem.titulo),
          icon: icone);
      _listaMarcadores.add( mOrigem );
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        marcadorDestino.caminhoImagem)
        .then((BitmapDescriptor icone) {
      Marker mDestino = Marker(
          markerId: MarkerId(marcadorDestino.caminhoImagem),
          position: LatLng(latLngDestino.latitude, latLngDestino.longitude),
          infoWindow: InfoWindow(title: marcadorDestino.titulo),
          icon: icone);
      _listaMarcadores.add( mDestino );
    });

    setState(() {
      _marcadores = _listaMarcadores;
    });

  }

  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
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
        String idRequisitante = _dadosRequisicao["requisitante"]["userid"];
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

    _idRequisicao = widget.idRequisicao;
    //Mudanças de requisicao
    // ignore: unnecessary_statements
    _adicionarListennerRequisicao();

    //_getLastKnownLocation();
    _addLocationListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Painel Corrida"),
        ),
        endDrawer: SideMenu(),
        body: Container(
            child: Stack(children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _cameraPosition,
            onMapCreated: _onMapCreated,
            //myLocationEnabled: true,
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
