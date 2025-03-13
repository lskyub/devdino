import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:go_router/go_router.dart';

class LocationSearchScreen extends ConsumerStatefulWidget {
  static const routeName = 'location_search';
  static const routePath = '/location_search';

  final String initialLocation;

  const LocationSearchScreen({
    super.key,
    required this.initialLocation,
  });

  @override
  ConsumerState<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends ConsumerState<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialLocation;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchLocation(String query) {
    // TODO: 실제 위치 검색 API 연동
    setState(() {
      _searchResults = [
        '서울특별시 강남구',
        '서울특별시 강남구 테헤란로',
        '서울특별시 강남구 역삼동',
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          width: 120,
          colorFilter: ColorFilter.mode(
            $b2bToken.color.primary.resolve(context),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '위치를 검색하세요',
                prefixIcon: Icon(
                  Icons.search,
                  color: $b2bToken.color.gray400.resolve(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _searchLocation,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final location = _searchResults[index];
                return ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: $b2bToken.color.primary.resolve(context),
                  ),
                  title: B2bText.medium(
                    type: B2bTextType.body2,
                    text: location,
                    color: $b2bToken.color.labelNomal.resolve(context),
                  ),
                  onTap: () {
                    context.pop(location);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 