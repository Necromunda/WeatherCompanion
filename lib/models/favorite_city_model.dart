class FavoriteCity {
  String name;
  bool home;

  FavoriteCity({required this.name, required this.home});

  static FavoriteCity createFavoriteCity(final Map<String, dynamic> data) {
    return FavoriteCity(name: data["name"], home: data["home"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "home": home,
    };
  }
}
