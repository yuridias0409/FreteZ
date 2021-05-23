import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(ClientArea());

class ClientArea extends StatefulWidget {
  //const ClientArea({Key key}) : super(key: key);

  @override
  _ClientAreaState createState() => _ClientAreaState();
}

class _ClientAreaState extends State<ClientArea> {

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition = CameraPosition(target: LatLng(-23.563999, -46.653256));

  List<String> menuItems = [
    "Configurações", "Deslogar"
  ];

  _logoff() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  _pickMenuItem( String choice ) {
    if(choice == "Deslogar") _logoff();

  }

  _onMapCreated(GoogleMapController controller){
    _controller.complete( controller );
  }

  _moveCamera(CameraPosition position) async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        position
      )
    );
  }

  _getLastKnownLocation() async {
    Position position = await Geolocator().getLastKnownPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    setState(() {
      if(position != null){
        _cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 19
        );

        _moveCamera(_cameraPosition);
      }
    });
  }

  _addLocationListener(){
    var geolocator = Geolocator();
    var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10
    );
    geolocator.getPositionStream( locationOptions ).listen((Position position) {
      _cameraPosition = CameraPosition(
          target: LatLng(-23.563999, -46.653256),
          zoom: 18
      );
      _moveCamera(_cameraPosition);
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
      appBar: AppBar(
        title: Text('Client'),
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
      ),

      body: TextField(
        decoration: (
            InputDecoration(
                icon: Icon(Icons.map),
                labelText: "Ponto de partida",
                suffixIcon: Icon(Icons.error)
            )
        ),
      ),

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
