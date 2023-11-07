import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:efreigrp2/controller/my_firestore_helper.dart';
import 'package:efreigrp2/globale.dart';
import 'package:efreigrp2/model/my_user.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMap extends StatefulWidget {
  Position position;
  MyMap({required this.position, super.key});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  //variable
  late CameraPosition myPositionMaps;
  Completer<GoogleMapController> control = Completer();
  Set<Marker>allMarkers = Set();

  @override
  void initState() {
    // TODO: implement initState
    myPositionMaps = CameraPosition(target: LatLng(widget.position.latitude,widget.position.longitude),zoom: 14);
    Map<String,dynamic> data = {
      "GPS":GeoPoint(widget.position.latitude,widget.position.longitude)
    };
    MyFirestoreHelper().updateUser(moi.uid, data);
    //récuperer les élements dans la base de donneé
    MyFirestoreHelper().cloudUsers.snapshots().listen((event) {
      setState(() {
        List documents = event.docs;
        for(int i= 0;i<documents.length;i++){
          MyUser lesautres = MyUser.dataBase(documents[i]);
          if(moi.uid != lesautres.uid) {
            if(GeoPoint(0,0)!= lesautres.gps!) {
              Marker marker = Marker(
                  markerId: MarkerId(lesautres.uid),
                  position: LatLng(
                      lesautres.gps!.latitude, lesautres.gps!.longitude),
                  infoWindow: InfoWindow(
                    title: lesautres.fullName,
                  ),




              );
              allMarkers.add(marker);
            }
          }

        }
      });

    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: allMarkers,
      initialCameraPosition: myPositionMaps,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) async {
        String newStyle = await DefaultAssetBundle.of(context).loadString("lib/styleMaps.json");
        controller.setMapStyle(newStyle);
        control.complete(controller);

      },
    );
  }
}
