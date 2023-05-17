class FavoriteCityModel {
  String name;
  bool home;

  FavoriteCityModel({required this.name, required this.home});

  static FavoriteCityModel createFavoriteCity(final Map<String, dynamic> data) {
    return FavoriteCityModel(name: data["name"], home: data["home"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "home": home,
    };
  }
}
