import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
class GoogleMapLocationPage extends StatefulWidget {
  final double lat;
  final double long;
  const GoogleMapLocationPage({super.key ,required this.lat,required this.long});

  @override
  State<GoogleMapLocationPage> createState() => _GoogleMapLocationPageState();
}

class _GoogleMapLocationPageState extends State<GoogleMapLocationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
              onPressed: () => MapsLauncher.launchQuery(
              '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'),
              child: const Text('LAUNCH QUERY'),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
        onPressed: () => MapsLauncher.launchCoordinates(
        37.4220041, -122.0862462, 'Google Headquarters are here'),
        child: const Text('LAUNCH COORDINATES'),
        ),
        ],
    )
      ),
    );
  }
}
