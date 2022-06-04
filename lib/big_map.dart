import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BigMap extends StatefulWidget {
  const BigMap({Key key}) : super(key: key);

  @override
  _BigMapState createState() => _BigMapState();
}

Future<Position> _deter() async {
  Position position = await Geolocator.getCurrentPosition();
  return position;
}

class _BigMapState extends State<BigMap> {
  Position position;
  String selectedAddress;
  List<Marker> myMarker = [];
  final Completer<GoogleMapController> _controller = Completer();
  LatLng selectedLocation;
  setup() async {
    position = await _deter();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _selectLocation(LatLng loc) async {
    setState(() {
      myMarker = [];
      selectedLocation = loc;
      myMarker.add(Marker(
        markerId: MarkerId(loc.toString()),
        position: loc,
      ));
    });
  }

  static const CameraPosition _user = CameraPosition(
    target: LatLng(37.2791, 127.9043),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Choose from map'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: selectedLocation == null
                  ? null
                  : () => Navigator.of(context).pop({
                        'latitude': selectedLocation.latitude,
                        'longitude': selectedLocation.longitude,
                      }),
            )
          ],
        ),
        body: GoogleMap(
          onTap: _selectLocation,
          mapType: MapType.normal,
          initialCameraPosition: _user,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: Set.from(myMarker),
        ));
  }
}
