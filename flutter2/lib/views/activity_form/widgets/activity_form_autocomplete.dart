import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projet_dyma_end/apis/google_api.dart';
import 'package:projet_dyma_end/models/activity_model.dart';
import 'package:projet_dyma_end/models/place_model.dart';

Future<LocationActivity?> showInputAutocomplete(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => InputAddress(),
  );
}

class InputAddress extends StatefulWidget {
  @override
  _InputAddressState createState() => _InputAddressState();
}

class _InputAddressState extends State<InputAddress> {
  List<Place> _places = [];
  Timer? _debounce;

  Future<void> _searchAddress(String value) async {
    try {
      if (_debounce?.isActive == true) _debounce?.cancel();
      _debounce = Timer(Duration(seconds: 1), () async {
        if (value.isNotEmpty) {
          _places = await getAutocompleteSuggestions(value);
          setState(() {});
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getPlaceDetails(String placeId) async {
    try {
      LocationActivity location = await getPlaceDetailsApi(placeId);
      Navigator.pop(context, location);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: 'Rechercher',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _searchAddress,
                autofocus: true,
              ),
              Positioned(
                top: 5,
                right: 3,
                child: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => Navigator.pop(context, null),
                ),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _places.length,
              itemBuilder: (_, i) {
                var place = _places[i];
                return ListTile(
                  leading: Icon(Icons.place),
                  title: Text(place.description),
                  onTap: () => getPlaceDetails(place.placeId),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
