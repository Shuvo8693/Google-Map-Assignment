import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'google_map.dart';


void main(){
  runApp(const PolylineMap());
}
class PolylineMap extends StatelessWidget {
  const PolylineMap({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home:GoogleMapScreen()
    );
  }
}
