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

class LocationSearchScreen extends ConsumerStatefulWidget {
  static const routeName = 'location_search';
  static const routePath = '/location_search';

  final String initialLocation;
  final String countryCode;

  const LocationSearchScreen({
    super.key,
    required this.initialLocation,
    required this.countryCode,
  });

  @override
  ConsumerState<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState extends ConsumerState<LocationSearchScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng _selectedLocation = const LatLng(37.5665, 126.9780); // 기본 서울 좌표
  List<Map<String, dynamic>> _searchResults = [];
  Marker? _clickedMarker; // 사용자가 클릭한 마커
  final _debouncer = Debouncer();

  Future<LatLng?> getCoordinatesFromCountryCode(String countryCode) async {
    if (countryCode.isEmpty) return null;
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?countrycodes=$countryCode&format=json');

    final response = await http.get(url);
    print('countryCode[$countryCode] ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        double lat = double.parse(data[0]['lat']);
        double lon = double.parse(data[0]['lon']);
        return _selectedLocation = LatLng(lat, lon); // ✅ 위도, 경도 반환
      }
    }
    return null; // 실패 시 null 반환
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

  @override
  void initState() {
    super.initState();
    getCoordinatesFromCountryCode(widget.countryCode);
    // _searchController.text = widget.initialLocation;
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
        surfaceTintColor: Colors.transparent, // 자동 색상 변
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
            context.pop();
          },
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 27,
            height: 27,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 🌍 지도 표시
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                onTap: (_, point) => _onMapTap(point), // 📌 지도 클릭 이벤트 추가
              ),
              children: [
                TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
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
                  onChanged: _fetchSearchResults, // 입력할 때마다 자동완성 요청
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
                          onTap: () => _selectCity(city), // 선택 시 이동
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
