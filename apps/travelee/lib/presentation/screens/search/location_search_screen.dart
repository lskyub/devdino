import 'dart:convert';
import 'dart:async';

import 'package:design_systems/dino/dino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:travelee/domain/entities/location_data.dart';
import 'package:travelee/gen/app_localizations.dart';

class LocationSearchScreen extends ConsumerStatefulWidget {
  static const routeName = 'location_search';
  static const routePath = '/location_search';

  final String initialLocation;
  final String countryCode;
  final double initialLatitude;
  final double initialLongitude;

  const LocationSearchScreen({
    super.key,
    required this.initialLocation,
    required this.countryCode,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  ConsumerState<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState extends ConsumerState<LocationSearchScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng _selectedLocation = const LatLng(37.5665, 126.9780);
  List<Map<String, dynamic>> _searchResults = [];
  Marker? _clickedMarker;
  final _debouncer = Debouncer();
  bool _isLoading = true;
  late String _location;
  late double _latitude;
  late double _longitude;

  Future<LatLng?> getCoordinatesFromCountryCode(String countryCode) async {
    if (countryCode.isEmpty) return null;
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?countrycodes=$countryCode&format=json');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        double lat = double.parse(data[0]['lat']);
        double lon = double.parse(data[0]['lon']);
        return _selectedLocation = LatLng(lat, lon);
      }
    }
    return null;
  }

  // 📌 자동완성 검색 요청
  Future<void> _fetchSearchResults(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    _debouncer.call(() async {
      // 한글을 포함한 검색어를 URL 인코딩
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
          "https://nominatim.openstreetmap.org/search?format=json&q=$encodedQuery&limit=5");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data
              .map((item) => {
                    "name": item["display_name"],
                    "lat": double.parse(item["lat"]),
                    "lon": double.parse(item["lon"]),
                  })
              .toList();
        });
      }
    });
  }

  // 📌 도시 선택 시 지도 이동
  void _selectCity(Map<String, dynamic> city) {
    setState(() {
      _selectedLocation = LatLng(city["lat"], city["lon"]);
      _searchController.text = city["name"];
      _searchResults = []; // 자동완성 목록 숨기기
    });

    // 📌 지도 이동
    _mapController.move(_selectedLocation, 12.0);
  }

  // 📌 지도 클릭 시 마커 추가 & 주변 식당 가져오기
  void _onMapTap(LatLng point) {
    setState(() {
      _selectedLocation = point;
      _clickedMarker = Marker(
        width: 80.0,
        height: 80.0,
        point: point,
        child: Icon(
          Icons.location_pin,
          color: $dinoToken.color.primary.resolve(context),
          size: 40.0,
        ),
      );
    });
  }

  // 📌 줌인
  void _zoomIn() {
    double currentZoom = _mapController.camera.zoom;
    if (currentZoom < 18.0) {
      _mapController.move(_mapController.camera.center, currentZoom + 1);
    }
  }

  // 📌 줌아웃
  void _zoomOut() {
    double currentZoom = _mapController.camera.zoom;
    if (currentZoom > 4.0) {
      _mapController.move(_mapController.camera.center, currentZoom - 1);
    }
  }

  // 위치 선택 완료 버튼 추가
  Widget _buildConfirmButton() {
    if (_clickedMarker == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: ElevatedButton(
        onPressed: () {
          final locationData = LocationData(
            latitude: _selectedLocation.latitude,
            longitude: _selectedLocation.longitude,
            location: _searchController.text,
          );
          context.pop(locationData);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: $dinoToken.color.primary.resolve(context),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(AppLocalizations.of(context)!.locationSelectDone),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
    _location = widget.initialLocation;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLatitude != 0 && widget.initialLongitude != 0) {
      setState(() {
        _selectedLocation = LatLng(_latitude, _longitude);
        _clickedMarker = Marker(
          width: 80.0,
          height: 80.0,
          point: _selectedLocation,
          child: Icon(
            Icons.location_pin,
            color: $dinoToken.color.primary.resolve(context),
            size: 40.0,
          ),
        );
        _isLoading = false;
      });
    } else {
      final coordinates =
          await getCoordinatesFromCountryCode(widget.countryCode);
      if (coordinates != null) {
        setState(() {
          _latitude = coordinates.latitude;
          _longitude = coordinates.longitude;
          _selectedLocation = coordinates;
          _clickedMarker = Marker(
            width: 80.0,
            height: 80.0,
            point: _selectedLocation,
            child: Icon(
              Icons.location_pin,
              color: $dinoToken.color.primary.resolve(context),
              size: 40.0,
            ),
          );
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          width: 120,
          colorFilter: ColorFilter.mode(
            $dinoToken.color.primary.resolve(context),
            BlendMode.srcIn,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_clickedMarker != null) {
              final locationData = LocationData(
                latitude: _latitude,
                longitude: _longitude,
                location: _location,
              );
              context.pop(locationData);
            } else {
              context.pop();
            }
          },
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 27,
            height: 27,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      onTap: (_, point) => _onMapTap(point),
                      initialCenter: _selectedLocation,
                      initialZoom: 12.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      ),
                      if (_clickedMarker != null)
                        MarkerLayer(markers: [_clickedMarker!]),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "도시 이름을 입력하세요",
                          border: const OutlineInputBorder(),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchResults = [];
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: _fetchSearchResults,
                      ),
                      if (_searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 5)
                            ],
                          ),
                          child: Column(
                            children: _searchResults.map((city) {
                              return ListTile(
                                title: Text(city["name"]),
                                onTap: () => _selectCity(city),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 50,
                  right: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: _zoomIn,
                        tooltip: 'Zoom In',
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: _zoomOut,
                        tooltip: 'Zoom Out',
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
                _buildConfirmButton(),
              ],
            ),
    );
  }
}

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
