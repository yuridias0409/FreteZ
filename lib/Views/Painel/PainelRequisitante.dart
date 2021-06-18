import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretez/Model/Destino.dart';
import 'package:fretez/Model/Marcador.dart';
import 'package:fretez/Model/Requisicao.dart';
import 'package:fretez/Model/Usuario.dart';
import 'package:fretez/Utils/StatusRequisicao.dart';
import 'package:fretez/Utils/UsuarioFirebase.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:fretez/Widgets/SideMenu.dart';
import 'package:intl/intl.dart';

void main() => runApp(PainelRequisitante());

class PainelRequisitante extends StatefulWidget {
  //const ClientArea({Key key}) : super(key: key);

  @override
  _PainelRequisitanteState createState() => _PainelRequisitanteState();
}

class _PainelRequisitanteState extends State<PainelRequisitante> {
  TextEditingController _controllerDestino = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(-23.563999, -46.653256));
  Set<Marker> _marcadores = {};
  String _idRequisicao;

  //Salva local do requisitante
  Position _localRequisitante;

  //Dados da requisicao
  Map<String, dynamic> _dadosRequisicao;

  StreamSubscription<DocumentSnapshot> _streamSubscriptionRequisicoes;

  //Controles exibição na tela
  bool _exibirCaixaEnderecoDestino = true;
  String _textoBotao = "Chamar Entregador";
  Color _corBotao = Color(0xff6df893);
  Function _funcaoBotao;

  List<String> menuItems = ["Configurações", "Deslogar"];

  _logoff() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  _pickMenuItem(String choice) {
    if (choice == "Deslogar") _logoff();
  }

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
        _exibirMarcador(position, "images/requisitante.png", "Requisitante");

        _cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 19);
        _localRequisitante = position;
        _moveCamera(_cameraPosition);
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

  _adicionarListenerLocalizacao() {
    var geolocator = Geolocator();
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    geolocator.getPositionStream(locationOptions).listen((Position position) {
      if( _idRequisicao != null && _idRequisicao.isNotEmpty ){
        UsuarioFirebase.atualizarDadosLocalizacao(
            _idRequisicao,
            position.latitude,
            position.longitude,
            "requisitante"
        );
      } else {
        setState(() {
          _localRequisitante = position;
        });
        _statusEntregadorNaoChamado();
      }
    });
  }

  _salvarRequisicao(Destino destino) async {
    Usuario requisitante = await UsuarioFirebase.getDadosUsuarioLogado();
    requisitante.latitude = _localRequisitante.latitude;
    requisitante.longitude = _localRequisitante.longitude;

    Requisicao requisicao = Requisicao();
    requisicao.destino = destino;
    requisicao.requisitante = requisitante;
    requisicao.status = StatusRequisicao.AGUARDANDO;

    FirebaseFirestore db = FirebaseFirestore.instance;
    //Salvar Aquisição
    db.collection("requisicoes")
        .doc(requisicao.id)
        .set(requisicao.toMap());

    //Salvar requisição ativa
    Map<String, dynamic> dadosRequisicaoAtiva = {};
    dadosRequisicaoAtiva["id_requisicao"] = requisicao.id;
    dadosRequisicaoAtiva["id_usuario"] = requisitante.userid;
    dadosRequisicaoAtiva["status"] = StatusRequisicao.AGUARDANDO;

    db.collection("requisicao_ativa")
      .doc(requisitante.userid)
      .set(dadosRequisicaoAtiva);

    //adicionar um listenner
    if(_streamSubscriptionRequisicoes == null){
      _adicionarListennerRequisicao(requisicao.id);
    }
  }

  _openMenu() {
    // to-do: open delivery options menu
    return Container(
      child: Padding(
        padding: EdgeInsets.all(10),
      ),
    );
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

  _chamarEntregador() async {
    String enderecoDestino = _controllerDestino.text;

    if (enderecoDestino.isNotEmpty) {
      List<Placemark> listaEnderecos =
          await Geolocator().placemarkFromAddress(enderecoDestino);
      if (listaEnderecos != null && listaEnderecos.length > 0) {
        Placemark endereco = listaEnderecos[0];
        Destino destino = Destino();
        destino.cidade = endereco.subAdministrativeArea;
        destino.cep = endereco.postalCode;
        destino.bairro = endereco.subLocality;
        destino.rua = endereco.thoroughfare;
        destino.numero = endereco.subThoroughfare;
        destino.latitude = endereco.position.latitude;
        destino.longitude = endereco.position.longitude;

        String enderecoConfirmacao;
        enderecoConfirmacao = "\n Cidade: " + destino.cidade;
        enderecoConfirmacao += "\n Rua: " + destino.rua + ", " + destino.numero;
        enderecoConfirmacao += "\n Bairro: " + destino.bairro;

        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Confirmação de endereço"),
                content: Text(enderecoConfirmacao),
                contentPadding: EdgeInsets.all(16),
                actions: <Widget>[
                  FlatButton(
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => Navigator.pop(context)),
                  FlatButton(
                      child: Text(
                        "Confirmar",
                        style: TextStyle(color: Colors.green),
                      ),
                      onPressed: () {
                        _salvarRequisicao(destino);
                        Navigator.pop(context);
                      })
                ],
              );
            });
      }
    }
  }

  _statusEntregadorNaoChamado(){
    _exibirCaixaEnderecoDestino = true;

    _alterarBotaoPrincipal("Chamar Entregador", Color(0xff6df893), (){ _chamarEntregador(); });

    if(_localRequisitante != null){
      //Exibindo Marcador
      Position position = Position(latitude: _localRequisitante.latitude, longitude: _localRequisitante.longitude);

      _exibirMarcador(position, "images/requisitante.png", "Requisitante");

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 19);
      _moveCamera(cameraPosition);
    }

  }

  _statusAguardando(){
    _exibirCaixaEnderecoDestino = false;
    _alterarBotaoPrincipal("Cancelar", Colors.redAccent, (){ _cancelarEntregador(); });

    double requisitanteLat = _dadosRequisicao["requisitante"]["latitude"];
    double requisitanteLon = _dadosRequisicao["requisitante"]["longitude"];
    Position position = Position(
        latitude: requisitanteLat,
        longitude: requisitanteLon
    );

    _exibirMarcador(position, "images/requisitante.png", "Requisitante");

    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 19);
    _moveCamera( cameraPosition );
  }

  _statusACaminho(){
    _exibirCaixaEnderecoDestino = false;
    _alterarBotaoPrincipal("Motorista a Caminho", Colors.grey, null);

    double latitudeRequisitante = _dadosRequisicao["requisitante"]["latitude"];
    double longitudeRequisitante = _dadosRequisicao["requisitante"]["longitude"];

    double latitudeMotorista = _dadosRequisicao["motorista"]["latitude"];
    double longitudeMotorista = _dadosRequisicao["motorista"]["longitude"];

    Marcador marcadorOrigem = Marcador(LatLng(latitudeRequisitante, longitudeRequisitante), "images/requisitante.png", "Local Requisitante");
    Marcador marcadorDestino = Marcador(LatLng(latitudeMotorista, longitudeMotorista), "images/motorista.png", "Local Motorista");

    _exibirCentralizarDoisMarcadores(marcadorOrigem, marcadorDestino);
  }

  _finalizarCorrida(){

  }

  _statusEmViagem(){
    _exibirCaixaEnderecoDestino = false;

    _alterarBotaoPrincipal(
        "Em Viagem",
        Colors.grey,
        null
    );

    double latitudeDestino = _dadosRequisicao["destino"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destino"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["motorista"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["motorista"]["longitude"];

    Marcador marcadorOrigem = Marcador(LatLng(latitudeOrigem, longitudeOrigem), "images/motorista.png", "Local Motorista");
    Marcador marcadorDestino = Marcador(LatLng(latitudeDestino, longitudeDestino), "images/localentrega.png", "Local Destino");

    _exibirCentralizarDoisMarcadores(marcadorOrigem, marcadorDestino);

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

    //Lucro de R$1.2 KM rodados
    double lucro = distanciaKm * 1.2;

    double valorViagem = ((precoCombustivel / mediaConsumo) * distanciaKm) + lucro;

    //Formatar preço
    var f = NumberFormat('#,##0.00', 'pt_BR');
    var valorViagemFormatado = f.format(valorViagem);

    _alterarBotaoPrincipal(
        "Total - R\$ $valorViagemFormatado",
        Color(0xff87d19b), (){}
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

  _statusConfirmada(){
    if(_streamSubscriptionRequisicoes != null){
      _streamSubscriptionRequisicoes.cancel();
      _streamSubscriptionRequisicoes = null;
    }

    _exibirCaixaEnderecoDestino = true;

    _alterarBotaoPrincipal("Chamar Entregador", Color(0xff6df893), (){ _chamarEntregador(); });

    //Exibe localização do requisitante
    double requisitanteLat = _dadosRequisicao["requisitante"]["latitude"];
    double requisitanteLon = _dadosRequisicao["requisitante"]["longitude"];
    Position position = Position(
        latitude: requisitanteLat,
        longitude: requisitanteLon
    );

    _exibirMarcador(position, "images/requisitante.png", "Requisitante");

    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 19);
    _moveCamera( cameraPosition );

    _dadosRequisicao = {};
  }

  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
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

  _cancelarEntregador() async {
    User firebaseUser = await UsuarioFirebase.getUsuarioAtual();
    FirebaseFirestore db = FirebaseFirestore.instance;
    print("idReq:" + _idRequisicao);
    db.collection("requisicoes")
      .doc(_idRequisicao)
      .update({
        "status": StatusRequisicao.CANCELADA
      }).then((_){
        db.collection("requisicao_ativa")
            .doc(firebaseUser.uid)
            .delete();

        _statusEntregadorNaoChamado();

        if(_streamSubscriptionRequisicoes != null){
          _streamSubscriptionRequisicoes.cancel();
          _streamSubscriptionRequisicoes = null;
        }
    });
  }

  _alterarBotaoPrincipal(String texto, Color cor, Function funcao){
    setState(() {
      _textoBotao = texto;
      _corBotao = cor;
      _funcaoBotao = funcao;
    });
  }

  _recuperarRequisicaoAtiva() async {
    User firebaseUser = await UsuarioFirebase.getUsuarioAtual();
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot documentSnapshot = await db.collection("requisicao_ativa")
      .doc(firebaseUser.uid)
      .get();

    if(documentSnapshot.data() != null){
      Map<String, dynamic> dados = documentSnapshot.data();
      _idRequisicao = dados["id_requisicao"];
      _adicionarListennerRequisicao(_idRequisicao);
    } else{
      _statusEntregadorNaoChamado();
    }
  }

  _adicionarListennerRequisicao(String idRequisicao) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    _streamSubscriptionRequisicoes = await db.collection("requisicoes")
        .doc(idRequisicao)
        .snapshots()
        .listen((snapshot) {
          if(snapshot.data() != null){
            Map<String, dynamic> dados = snapshot.data();
            _dadosRequisicao = dados;
            String status = dados["status"];
            _idRequisicao = dados["id"];

            switch(status){
              case StatusRequisicao.AGUARDANDO:
                _statusAguardando();
                break;
              case StatusRequisicao.A_CAMINHO:
                _statusACaminho();
                break;
              case StatusRequisicao.VIAGEM:
                _statusEmViagem();
                break;
              case StatusRequisicao.FINALIZADA:
                _statusFinalizada();
                break;
              case StatusRequisicao.CONFIRMADA:
                _statusConfirmada();
                break;
            }
          }
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _recuperarRequisicaoAtiva();

    //_getLastKnownLocation();
    _adicionarListenerLocalizacao();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Painel Requisitante"),
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
          Visibility(
            visible: _exibirCaixaEnderecoDestino,
            child: Stack(
              children: <Widget>[
                Positioned(
                    //
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 4),
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white),
                        child: TextField(
                          decoration: (InputDecoration(
                              icon: Icon(Icons.location_pin),
                              labelText: "Ponto de partida",
                              suffixIcon: Icon(Icons.keyboard_voice))),
                        ),
                      ),
                    )),
                Positioned(
                    top: 110,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 4),
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white),
                        child: TextField(
                          controller: _controllerDestino,
                          decoration: (InputDecoration(
                              icon: Icon(Icons.map),
                              labelText: "Destino",
                              suffixIcon: Icon(Icons.keyboard_voice))),
                        ),
                      ),
                    ))
              ],
            ),
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
        ]))

        /*TextField(
        decoration: (
            InputDecoration(
                icon: Icon(Icons.map),
                labelText: "Ponto de partida",
                suffixIcon: Icon(Icons.error)
            )
        ),
      ),*/

        /*Container(
        child: GoogleMap(
          mapType: MapType.normal,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
        ),
      ),*/
        );
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscriptionRequisicoes.cancel();
    _streamSubscriptionRequisicoes = null;
  }
}
