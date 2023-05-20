class GeocodingModel {
  List<Results>? results;
  double? generationtimeMs;

  GeocodingModel({this.results, this.generationtimeMs});

  GeocodingModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
    generationtimeMs = json['generationtime_ms'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    data['generationtime_ms'] = generationtimeMs;
    return data;
  }
}

class Results {
  int? id;
  String? name;
  double? latitude;
  double? longitude;
  double? elevation;
  String? featureCode;
  String? countryCode;
  int? admin1Id;
  int? admin2Id;
  int? admin3Id;
  String? timezone;
  int? population;
  int? countryId;
  String? country;
  String? admin1;
  String? admin2;
  String? admin3;

  Results(
      {this.id,
        this.name,
        this.latitude,
        this.longitude,
        this.elevation,
        this.featureCode,
        this.countryCode,
        this.admin1Id,
        this.admin2Id,
        this.admin3Id,
        this.timezone,
        this.population,
        this.countryId,
        this.country,
        this.admin1,
        this.admin2,
        this.admin3});

  String get city =>"$name, $countryCode";

  Results.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    elevation = json['elevation'];
    featureCode = json['feature_code'];
    countryCode = json['country_code'];
    admin1Id = json['admin1_id'];
    admin2Id = json['admin2_id'];
    admin3Id = json['admin3_id'];
    timezone = json['timezone'];
    population = json['population'];
    countryId = json['country_id'];
    country = json['country'];
    admin1 = json['admin1'];
    admin2 = json['admin2'];
    admin3 = json['admin3'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['elevation'] = elevation;
    data['feature_code'] = featureCode;
    data['country_code'] = countryCode;
    data['admin1_id'] = admin1Id;
    data['admin2_id'] = admin2Id;
    data['admin3_id'] = admin3Id;
    data['timezone'] = timezone;
    data['population'] = population;
    data['country_id'] = countryId;
    data['country'] = country;
    data['admin1'] = admin1;
    data['admin2'] =admin2;
    data['admin3'] = admin3;
    return data;
  }
}
