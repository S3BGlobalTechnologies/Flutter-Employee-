import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Locator extends StatefulWidget {
  const Locator({Key? key}) : super(key: key);

  @override
  State<Locator> createState() => _LocatorState();
}

class _LocatorState extends State<Locator> {
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); // Access directly on Geolocator class
    setState(() {
      userPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Location'),
      ),
      body: userPosition != null
          ? Center(
              child: Text(
                'Latitude: ${userPosition!.latitude}, Longitude: ${userPosition!.longitude}',
                style: TextStyle(fontSize: 20),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
