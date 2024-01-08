import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {

  Location location=Location();
  LocationData? currentLocationData;
  late GoogleMapController googleMapController;
  Set<Marker>markers={};
 late StreamSubscription subscription;
  LatLng? previousLocation;
 List<LatLng>polylineCoordinate=[];
  PermissionStatus? permissionStatus;


@override
  void initState() {
    super.initState();
    myCurrentLocation(zoom: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: const Text('Google Map'),
       ),
      body: currentLocationData==null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(initialCameraPosition: buildCameraPosition(),
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller){
            googleMapController=controller;
            setState(() {});
          },
          mapType: MapType.normal,
          markers: markers,
          polylines: {
            Polyline(
                polylineId: const PolylineId('Location A'),
                points:polylineCoordinate,
                color: Colors.orange
            )
          }
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(onPressed: (){
        myCurrentLocation(zoom: 20);

      }, child: const Icon(Icons.location_on),),
    );
  }

  CameraPosition buildCameraPosition() {
    return CameraPosition(
        zoom: 2,
        tilt: 50,
        bearing: 10,
        target: LatLng(currentLocationData?.latitude??0,currentLocationData?.longitude??0));
  }

  Future<void>myCurrentLocation({required double zoom})async{
  await location.requestPermission().then((permission) {
  if(permission==PermissionStatus.granted) {
    subscription = location.onLocationChanged.listen((currentData) {
      setState(() { // eta currentLocationData Update korce every 7 second e, ty marker location movement beshi hoy
        currentLocationData = currentData;
        markers.clear(); // Clear the multiple marker when re-build the myCurrentLocation Function
        updatePolyline(); // every 7 second e resume hocce
        addMarker();
      });

      googleMapController.animateCamera( // every 7 second e resume hocce
          CameraUpdate.newCameraPosition(CameraPosition(
              target: LatLng(currentLocationData?.latitude ?? 0,
                  currentLocationData?.longitude ?? 0),
              zoom: zoom, tilt: 45)));
      setState(() {});
    });
    // subscription er method na holeo update hobe ,onLocationChanged update/location changed kore
    //subscription er modde jei function gulo ache segulo every 7 secenod por por update hobe
    // ei code e read hola subdcription ti pause hobe but vitorer function ti 7 second por resume kore debe
    subscription.pause(
        Future.delayed(const Duration(seconds: 7)).then((value) =>
            subscription.resume()));
    setState(() {});
  }else{
    if(permission==PermissionStatus.denied || permission==PermissionStatus.deniedForever){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location Access Denied!! , Please Allow Permission'),backgroundColor: Colors.deepOrange,));
    }
   }
  });
 }

 updatePolyline(){
  if(polylineCoordinate.isNotEmpty) { // first time empty thake ty else method e location new add hoy then ei method read hoy
    previousLocation = polylineCoordinate.last;
    log('previousLocation: $previousLocation');
    LatLng currentLatLng = LatLng(currentLocationData?.latitude ?? 0, currentLocationData?.longitude ?? 0);

    if (previousLocation != currentLatLng) {
      polylineCoordinate.add(currentLatLng);
      setState(() {});
    }
  }else{
   polylineCoordinate.add( LatLng(currentLocationData?.latitude??0, currentLocationData?.longitude??0));
    setState(() {});
 }
  }
   addMarker(){
   markers.add(
        Marker(
        markerId:  const MarkerId('marker 1'),
       position: LatLng(currentLocationData?.latitude??0, currentLocationData?.longitude??0),
        infoWindow:  InfoWindow(
          title: 'My Location',
          snippet: '${currentLocationData?.latitude??0}, ${currentLocationData?.longitude??0}'
        ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      draggable: true,
    )
  );

   setState(() {});
}
@override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
