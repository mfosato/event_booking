import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_map_location_picker/generated/i18n.dart'
    as location_picker;
import 'package:google_map_location_picker/generated/i18n.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPick extends StatefulWidget {
  @override
  _LocationPickState createState() => _LocationPickState();
}

class _LocationPickState extends State<LocationPick> {
  LocationResult _pickedLocation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('location picker'),
      ),
      body: Builder(builder: (context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  LocationResult result = await showLocationPicker(
                    context,
                    "AIzaSyBxEniSBP1bAaiNzyhagqHt69eS2H-IxXU",
                    initialCenter: LatLng(31.1975844, 29.9598339),
//                      automaticallyAnimateToCurrentLocation: true,
//                      mapStylePath: 'assets/mapStyle.json',
                    myLocationButtonEnabled: true,
                    layersButtonEnabled: true,
//                      resultCardAlignment: Alignment.bottomCenter,
                  );
                  print("result = $result");
                  setState(() => _pickedLocation = result);
                },
                child: Text('Pick location'),
              ),
              Text(_pickedLocation.toString()),
            ],
          ),
        );
      }),
    );
  }
}
