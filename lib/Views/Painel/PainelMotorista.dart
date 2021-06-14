import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:fretez/Widgets/SideMenu.dart';

void main() => runApp(PainelMotorista());

class PainelMotorista extends StatefulWidget {
  //const ClientArea({Key key}) : super(key: key);

  @override
  _PainelMotoristaState createState() => _PainelMotoristaState();
}

class _PainelMotoristaState extends State<PainelMotorista> {

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

  _openMenu() { // to-do: open delivery options menu
    return Container(
      child: Padding(
        padding: EdgeInsets.all(10),
      ),
    );
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
      body: Container(
        child: Text("Alo Motorista"),
      ),
    );
  }
}
