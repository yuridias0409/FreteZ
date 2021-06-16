import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretez/Model/Destino.dart';
import 'package:fretez/Model/Requisicao.dart';
import 'package:fretez/Model/Usuario.dart';
import 'package:fretez/Utils/StatusRequisicao.dart';
import 'package:fretez/Utils/UsuarioFirebase.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:fretez/Widgets/SideMenu.dart';

void main() => runApp(PainelPassageiro());

class PainelPassageiro extends StatefulWidget {
  //const ClientArea({Key key}) : super(key: key);

  @override
  _PainelPassageiroState createState() => _PainelPassageiroState();
}

class _PainelPassageiroState extends State<PainelPassageiro> {
  TextEditingController _controllerDestino = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(-23.563999, -46.653256));
  Set<Marker> _marcadores = {};
  String _idRequisicao;

  //Salva local do passageiro
  Position _localRequisitante;

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
        _cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 19);
        _localRequisitante = position;
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
      _localRequisitante = position;
      _moveCamera(_cameraPosition);
    });
  }

  _salvarRequisicao(Destino destino) async {
    Usuario entrega = await UsuarioFirebase.getDadosUsuarioLogado();
    entrega.latitude = _localRequisitante.latitude;
    entrega.longitude = _localRequisitante.longitude;

    Requisicao requisicao = Requisicao();
    requisicao.destino = destino;
    requisicao.entrega = entrega;
    requisicao.status = StatusRequisicao.AGUARDANDO;

    FirebaseFirestore db = FirebaseFirestore.instance;
    //Salvar Aquisição
    db.collection("requisicoes")
        .doc(requisicao.id)
        .set(requisicao.toMap());

    //Salvar requisição ativa
    Map<String, dynamic> dadosRequisicaoAtiva = {};
    dadosRequisicaoAtiva["id_requisicao"] = requisicao.id;
    dadosRequisicaoAtiva["id_usuario"] = entrega.userid;
    dadosRequisicaoAtiva["status"] = StatusRequisicao.AGUARDANDO;

    db.collection("requisicao_ativa")
      .doc(entrega.userid)
      .set(dadosRequisicaoAtiva);
  }

  _openMenu() {
    // to-do: open delivery options menu
    return Container(
      child: Padding(
        padding: EdgeInsets.all(10),
      ),
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

  _statusUberNaoChamado(){
    _exibirCaixaEnderecoDestino = true;
    _alterarBotaoPrincipal("Chamar Entregador", Color(0xff6df893), (){ _chamarEntregador(); });
  }

  _statusAguardando(){
    _exibirCaixaEnderecoDestino = false;
    _alterarBotaoPrincipal("Cancelar", Colors.redAccent, (){ _cancelarEntregador(); });
  }

  _statusACaminho(){
    _exibirCaixaEnderecoDestino = false;
    _alterarBotaoPrincipal("Motorista a Caminho", Colors.grey, null);
  }

  _cancelarEntregador() async {
    User firebaseUser = await UsuarioFirebase.getUsuarioAtual();
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes")
      .doc(_idRequisicao)
      .update({
        "status": StatusRequisicao.CANCELADA
      }).then((_){
        db.collection("requisicao_ativa")
            .doc(firebaseUser.uid)
            .delete();
    });
  }

  _alterarBotaoPrincipal(String texto, Color cor, Function funcao){
    setState(() {
      _textoBotao = texto;
      _corBotao = cor;
      _funcaoBotao = funcao;
    });
  }

  _adicionarListenerRequisicaoAtiva() async {
    User firebaseUser = await UsuarioFirebase.getUsuarioAtual();
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicao_ativa")
      .doc(firebaseUser.uid)
      .snapshots()
      .listen((snapshot) {
        if(snapshot.data() != null){
          Map<String, dynamic> dados = snapshot.data();
          String status = dados["status"];
          _idRequisicao = dados["id_requisicao"];

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
        } else{
          _statusUberNaoChamado();
        }
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLastKnownLocation();
    _addLocationListener();
    _adicionarListenerRequisicaoAtiva();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        /*appBar: AppBar(
        title: Text('Client'),
        backgroundColor: Colors.green,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _pickMenuItem,
            itemBuilder: (context){
              return menuItems.map((item){
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item)
                );
              }).toList();
            },
          )
        ],
      ),*/
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
}
