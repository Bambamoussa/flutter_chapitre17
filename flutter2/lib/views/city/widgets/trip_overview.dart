import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projet_dyma_end/views/city/widgets/trip_overview_city.dart';

import '../../../models/trip_model.dart';

class TripOverview extends StatelessWidget {
  final VoidCallback setDate;
  final Trip trip;
  final String cityName;
  final String cityImage;
  final double amount;

  const TripOverview({
    required this.setDate,
    required this.trip,
    required this.cityName,
    required this.amount,
    required this.cityImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TripOverviewCity(
            cityName: cityName,
            cityImage: cityImage,
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    trip.date != null
                        ? DateFormat("d/M/y").format(trip.date!)
                        : 'Choisissez une date',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                ElevatedButton(
                  child: const Text('Selectioner une date'),
                  onPressed: setDate,
                )
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: const Text(
                    'Montant / personne',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                Text(
                  '$amount \$',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
