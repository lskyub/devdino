import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:travelee/models/country_info.dart';
import 'dart:developer' as dev;

class CountrySelectModal extends ConsumerStatefulWidget {
  final List<CountryInfo> countryInfos;
  final String? currentCountryName; // 현재 선택된 국가명

  const CountrySelectModal({
    super.key,
    required this.countryInfos,
    this.currentCountryName,
  });

  @override
  ConsumerState<CountrySelectModal> createState() => _CountrySelectModalState();
}

class _CountrySelectModalState extends ConsumerState<CountrySelectModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  List<CountryInfo> get _filteredCountries {
    if (_searchQuery.isEmpty) {
      return widget.countryInfos;
    }
    
    return widget.countryInfos.where((country) {
      return country.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  void _selectCountry(CountryInfo country) {
    dev.log('국가 선택: ${country.name} ${country.flagEmoji} ${country.countryCode}');
    Navigator.pop(context, {
      'name': country.name,
      'flag': country.flagEmoji,
      'code': country.countryCode,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              B2bText.bold(
                type: B2bTextType.title3,
                text: '국가 선택',
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: $b2bToken.color.gray400.resolve(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.currentCountryName != null && widget.currentCountryName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  B2bText.medium(
                    type: B2bTextType.body2,
                    text: '현재 선택된 국가: ',
                    color: $b2bToken.color.gray500.resolve(context),
                  ),
                  const SizedBox(width: 8),
                  B2bText.bold(
                    type: B2bTextType.body1,
                    text: widget.currentCountryName!,
                    color: $b2bToken.color.primary.resolve(context),
                  ),
                ],
              ),
            ),
          Flexible(
            child: widget.countryInfos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: B2bText.medium(
                      type: B2bTextType.body2,
                      text: '이 여행에 추가된 국가가 없습니다',
                      color: $b2bToken.color.gray400.resolve(context),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.countryInfos.length,
                  itemBuilder: (context, index) {
                    final country = widget.countryInfos[index];
                    final isSelected = country.name == widget.currentCountryName;
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? $b2bToken.color.primary.resolve(context).withOpacity(0.1)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      child: ListTile(
                        leading: Text(
                          country.flagEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          country.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected 
                              ? $b2bToken.color.primary.resolve(context)
                              : null,
                          ),
                        ),
                        trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: $b2bToken.color.primary.resolve(context),
                            )
                          : null,
                        onTap: () => _selectCountry(country),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
} 