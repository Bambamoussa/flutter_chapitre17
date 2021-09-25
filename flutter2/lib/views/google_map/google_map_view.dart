import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:projet_dyma_end/models/activity_model.dart';
import 'package:projet_dyma_end/providers/trip_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleMapView extends StatefulWidget {
  static const String routeName = '/google-map';

  @override
  _GoogleMapViewState createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  bool _isLoaded = false;
  late GoogleMapController _controller;
  late Activity _activity;

  @override
  void didChangeDependencies() {
    if (!_isLoaded) {
      var arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, String?>;
      _activity =
          Provider.of<TripProvider>(context, listen: false).getActivityByIds(
        activityId: arguments['activityId']!,
        tripId: arguments['tripId']!,
      );
      print(_activity.location!.latitude);
      print(_activity.location!.longitude);
    }
    super.didChangeDependencies();
  }

  get _activityLatLng {
    return LatLng(
      _activity.location!.latitude!,
      _activity.location!.longitude!,
    );
  }

  get _initialCameraPosition {
    return CameraPosition(
      target: _activityLatLng,
      zoom: 16.0,
    );
  }

  Future<void> _openUrl() async {
    final url = 'google.navigation:q=${_activity.location!.address}';
    try {
      await launch(url);
    } catch(e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_activity.name),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) => _controller = controller,
        markers: Set.of([
          Marker(
            markerId: MarkerId('123'),
            flat: true,
            position: _activityLatLng,
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.directions_car),
        onPressed: _openUrl,
        label: Text('Go'),
      ),
    );
  }
}
