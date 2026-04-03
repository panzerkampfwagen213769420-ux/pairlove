import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/app_state.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final MapController _mapController = MapController();
  LatLng? _myLocation;
  LatLng? _partnerLocation;
  double? _mySpeed;
  double? _partnerSpeed;
  double? _myDirection;
  double? _partnerDirection;
  bool _isSharing = true;
  bool _showPartnerInfo = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _simulatePartnerLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _myLocation = LatLng(position.latitude, position.longitude);
        _mySpeed = position.speed * 3.6;
        _myDirection = position.heading;
      });
    } catch (e) {
      setState(() {
        _myLocation = LatLng(52.2297, 21.0122);
        _mySpeed = 0;
        _myDirection = 0;
      });
    }
  }

  void _simulatePartnerLocation() {
    setState(() {
      _partnerLocation = LatLng(52.2350, 21.0200);
      _partnerSpeed = 15.5;
      _partnerDirection = 45;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final partner = appState.partner;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokalizacja'),
        actions: [
          IconButton(
            icon: Icon(
              _isSharing ? Icons.location_on : Icons.location_off,
              color: _isSharing ? Colors.green : Colors.red,
            ),
            onPressed: () {
              setState(() {
                _isSharing = !_isSharing;
              });
            },
            tooltip: _isSharing
                ? 'Udostępnianie włączone'
                : 'Udostępnianie wyłączone',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _myLocation ?? LatLng(52.2297, 21.0122),
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.pairlove.app',
                    ),
                    if (_myLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _myLocation!,
                            width: 50,
                            height: 50,
                            child: _buildLocationMarker(
                              color: AppTheme.primaryColor,
                              icon: Icons.person,
                              isMe: true,
                            ),
                          ),
                        ],
                      ),
                    if (_partnerLocation != null && _showPartnerInfo)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _partnerLocation!,
                            width: 50,
                            height: 50,
                            child: _buildLocationMarker(
                              color: Colors.blue,
                              icon: Icons.favorite,
                              isMe: false,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      _buildSpeedDirectionCard(
                        title: 'Ty',
                        speed: _mySpeed ?? 0,
                        direction: _myDirection ?? 0,
                        color: AppTheme.primaryColor,
                      ),
                      if (_partnerLocation != null) ...[
                        const SizedBox(height: 8),
                        _buildSpeedDirectionCard(
                          title: 'Partner',
                          speed: _partnerSpeed ?? 0,
                          direction: _partnerDirection ?? 0,
                          color: Colors.blue,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomInfoPanel(partner),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getCurrentLocation();
          if (_myLocation != null) {
            _mapController.move(_myLocation!, 15);
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildLocationMarker({
    required Color color,
    required IconData icon,
    required bool isMe,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildSpeedDirectionCard({
    required String title,
    required double speed,
    required double direction,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.speed, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                '${speed.toStringAsFixed(1)} km/h',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.explore, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                _getDirectionText(direction),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfoPanel(partner) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                icon: Icons.battery_full,
                label: 'Bateria',
                value: partner != null ? '${partner.batteryLevel}%' : '--',
                color: _getBatteryColor(partner?.batteryLevel ?? 0),
              ),
            ),
            Expanded(
              child: _buildInfoTile(
                icon: Icons.phone_android,
                label: 'Status',
                value: partner?.isUsingPhone == true ? 'Online' : 'Offline',
                color:
                    partner?.isUsingPhone == true ? Colors.green : Colors.grey,
              ),
            ),
            Expanded(
              child: _buildInfoTile(
                icon: Icons.share_location,
                label: 'Ostatnia',
                value: '2 min temu',
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  String _getDirectionText(double direction) {
    if (direction >= 337.5 || direction < 22.5) return 'N (Północ)';
    if (direction >= 22.5 && direction < 67.5) return 'NE (Północny-Wschód)';
    if (direction >= 67.5 && direction < 112.5) return 'E (Wschód)';
    if (direction >= 112.5 && direction < 157.5)
      return 'SE (Południowy-Wschód)';
    if (direction >= 157.5 && direction < 202.5) return 'S (Południe)';
    if (direction >= 202.5 && direction < 247.5)
      return 'SW (Południowy-Zachód)';
    if (direction >= 247.5 && direction < 292.5) return 'W (Zachód)';
    return 'NW (Północny-Zachód)';
  }

  Color _getBatteryColor(int level) {
    if (level > 50) return Colors.green;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }
}
