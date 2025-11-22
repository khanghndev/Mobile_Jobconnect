class CityModelUi {
  final String isoCountryCode;
  final String country;
  final String postalCode;
  final String administrativeArea;
  final String subAdministrativeArea;
  final String locality;
  final String subLocality;
  final String thoroughfare;
  final String subThoroughfare;

  CityModelUi({
    required this.isoCountryCode,
    required this.country,
    required this.postalCode,
    required this.administrativeArea,
    required this.subAdministrativeArea,
    required this.locality,
    required this.subLocality,
    required this.thoroughfare,
    required this.subThoroughfare,
  });

  @override
  String toString() {
    return 'CityModelUi(isoCountryCode: $isoCountryCode, country: $country, postalCode: $postalCode, administrativeArea: $administrativeArea, subAdministrativeArea: $subAdministrativeArea, locality: $locality, subLocality: $subLocality, thoroughfare: $thoroughfare, subThoroughfare: $subThoroughfare)';
  }
}