class FavoriteCityModel {
  String? name;
  bool? home;

  FavoriteCityModel({required this.name, required this.home});

  FavoriteCityModel.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    home = json["home"];
  }

  // static FavoriteCityModel createFavoriteCity(final Map<String, dynamic> data) {
  //   return FavoriteCityModel(name: data["name"], home: data["home"]);
  // }

  Map<String, dynamic> toJson() => {
      "name": name,
      "home": home,
    };
}
