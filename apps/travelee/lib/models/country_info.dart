import 'package:country_picker/country_picker.dart';

class CountryInfo {
  final String name;
  final String countryCode;
  final String flagEmoji;

  CountryInfo({
    required this.name,
    required this.countryCode,
    required this.flagEmoji,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'countryCode': countryCode,
      'flagEmoji': flagEmoji,
    };
  }

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      name: json['name'] as String,
      countryCode: json['countryCode'] as String,
      flagEmoji: json['flagEmoji'] as String,
    );
  }

  factory CountryInfo.fromCountry(Country country) {
    return CountryInfo(
      name: country.nameLocalized ?? country.name,
      countryCode: country.countryCode,
      flagEmoji: country.flagEmoji,
    );
  }
} 