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

  CountryInfo copyWith({
    String? name,
    String? countryCode,
    String? flagEmoji,
  }) {
    return CountryInfo(
      name: name ?? this.name,
      countryCode: countryCode ?? this.countryCode,
      flagEmoji: flagEmoji ?? this.flagEmoji,
    );
  }

  @override
  String toString() => 'CountryInfo(name: $name, countryCode: $countryCode, flagEmoji: $flagEmoji)';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country_code': countryCode,
      'flag_emoji': flagEmoji,
    };
  }

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      name: json['name'] as String,
      countryCode: json['country_code'] as String,
      flagEmoji: json['flag_emoji'] as String,
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