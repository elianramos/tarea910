import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  final String name;
  final String lastName;
  final double latitude;
  final double longitude;

  MapScreen({
    required this.name,
    required this.lastName,
    required this.latitude,
    required this.longitude,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _locationInfo = 'Buscando ubicación...';

  @override
  void initState() {
    super.initState();
    _getLocationInfo();
  }

  Future<void> _getLocationInfo() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        widget.latitude,
        widget.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _locationInfo =
              '${place.locality ?? ''}, ${place.country ?? ''}'.trim();
        });
      } else {
        setState(() {
          _locationInfo = 'Ubicación desconocida';
        });
      }
    } catch (e) {
      setState(() {
        _locationInfo = 'Error al obtener ubicación';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng point = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(title: Text('Mapa')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: point,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: point,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('${widget.name} ${widget.lastName}'),
                        content: Text(_locationInfo),
                        actions: [
                          TextButton(
                            child: Text('Cerrar'),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    );
                  },
                  child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
