import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:projet_dyma_end/apis/google_api.dart';
import 'package:projet_dyma_end/models/activity_model.dart';
import 'package:projet_dyma_end/providers/city_provider.dart';
import 'package:projet_dyma_end/views/activity_form/widgets/activity_form_autocomplete.dart';
import 'package:provider/provider.dart';

import 'activity_form_image_picker.dart';

class ActivityForm extends StatefulWidget {
  final String cityName;

  ActivityForm({required this.cityName});

  @override
  _ActivityFormState createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late FocusNode _priceFocusNode;
  late FocusNode _urlFocusNode;
  late FocusNode _addressFocusNode;
  late Activity _newActivity;
  late String _nameInputAsync;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  FormState get form {
    return _formKey.currentState!;
  }

  @override
  void initState() {
    _newActivity = Activity(
      city: widget.cityName,
      name: '',
      price: 0,
      image: '',
      location: LocationActivity(
        address: '',
        longitude: 0,
        latitude: 0,
      ),
      status: ActivityStatus.ongoing,
    );
    _priceFocusNode = FocusNode();
    _urlFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _addressFocusNode.addListener(() async {
      if (_addressFocusNode.hasFocus) {
        var location = await showInputAutocomplete(context);
        _addressFocusNode.nextFocus();
        if (location != null) {
          _newActivity.location = location;
          setState(() {
            _addressController.text = location.address!;
          });
        }
      } else {
        print('no focus');
      }
    });
    super.initState();
  }

  void updateUrlField(String url) {
    setState(() {
      _urlController.text = url;
    });
  }

  void _getCurrentLocation() async {
    try {
      LocationData userLocation = await Location().getLocation();
      String address = await getAddressFromLatLng(
        lat: userLocation.latitude!,
        lng: userLocation.longitude!,
      );
      _newActivity.location = LocationActivity(
        address: address,
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
      setState(() {
        _addressController.text = address;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _urlFocusNode.dispose();
    _addressFocusNode.dispose();
    _urlController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    try {
      CityProvider cityProvider = Provider.of<CityProvider>(
        context,
        listen: false,
      );
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      _nameInputAsync = await cityProvider.verifyIfActivityNameIsUnique(
        widget.cityName,
        _newActivity.name,
      );
      if (form.validate()) {
        await cityProvider.addActivityToCity(_newActivity);
        Navigator.pop(context);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              autofocus: true,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Remplissez le nom';
                else if (_nameInputAsync != null) return _nameInputAsync;
                return null;
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Nom',
              ),
              onSaved: (value) => _newActivity.name = value!,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_priceFocusNode),
            ),
            SizedBox(
              height: 30,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              focusNode: _priceFocusNode,
              decoration: InputDecoration(
                hintText: 'Prix',
              ),
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_urlFocusNode),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
              },
              onSaved: (value) => _newActivity.price = double.parse(value!),
            ),
            SizedBox(
              height: 30,
            ),
            TextFormField(
              focusNode: _addressFocusNode,
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Adresse',
              ),
              onSaved: (value) => _newActivity.location!.address = value,
            ),
            SizedBox(
              height: 10,
            ),
            TextButton.icon(
              icon: Icon(Icons.gps_fixed),
              label: Text('Utilisez ma position actuelle'),
              onPressed: _getCurrentLocation,
            ),
            SizedBox(
              height: 30,
            ),
            TextFormField(
              keyboardType: TextInputType.url,
              focusNode: _urlFocusNode,
              controller: _urlController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Remplissez l\'Url';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Url image',
              ),
              onSaved: (value) => _newActivity.image = value!,
            ),
            SizedBox(
              height: 30,
            ),
            ActivityFormImagePicker(updateUrl: updateUrlField),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: Text('annuler'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text('sauvegarder'),
                  onPressed: _isLoading ? null : submitForm,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
