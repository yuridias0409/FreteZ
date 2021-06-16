import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretez/Utils/StatusRequisicao.dart';
import 'package:fretez/Widgets/SideMenu.dart';

void main() => runApp(PainelMotorista());

class PainelMotorista extends StatefulWidget {
  //const ClientArea({Key key}) : super(key: key);

  @override
  _PainelMotoristaState createState() => _PainelMotoristaState();
}

class _PainelMotoristaState extends State<PainelMotorista> {

  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;

  _logoff() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  _pickMenuItem( String choice ) {
    if(choice == "Deslogar") _logoff();

  }

  _openMenu() { // to-do: open delivery options menu
    return Container(
      child: Padding(
        padding: EdgeInsets.all(10),
      ),
    );
  }

  Stream<QuerySnapshot> _adicionarListenerRequisicoes(){
    final stream = db.collection("requisicoes")
        .where("status", isEqualTo: StatusRequisicao.AGUARDANDO)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _adicionarListenerRequisicoes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mensagemCarregando = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando requisições"),
          CircularProgressIndicator()
        ],
      ),
    );
    var mensagemNaoTemDados = Center(
      child: Text(
        "Você não tem nenhuma requisição :(",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      )
    );
    return Scaffold(
      endDrawer: SideMenu(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return mensagemCarregando;
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if(snapshot.hasError){
                return Text("Erro ao carregar dados!");
              } else{
                QuerySnapshot querySnapshot = snapshot.data;
                if(querySnapshot.docs.length == 0){
                  return mensagemNaoTemDados;
                } else{
                  return ListView.separated(
                      itemCount: querySnapshot.docs.length,
                      separatorBuilder: (context, indice) => Divider(
                        height: 2,
                        color: Color(0xff6df893),
                      ),
                      itemBuilder: (context, indice){
                        List<DocumentSnapshot> requisicoes = querySnapshot.docs.toList();

                        DocumentSnapshot item = requisicoes[indice];
                        String idRequisicao = item["id"];
                        String nomeRequisitante = item["entrega"]["name"];
                        String rua = item["destino"]["rua"];
                        String numero = item["destino"]["numero"];

                        return ListTile(
                          title: Text(nomeRequisitante ?? ''),
                          subtitle: Text("Destino: " + rua + ", " + numero),
                          onTap: (){
                            Navigator.pushNamed(context, "/painelCorrida", arguments: idRequisicao);
                          },
                        );
                      },
                  );
                }
              }
              break;
          }
        }
      ),
    );
  }
}
