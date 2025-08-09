class Translation {
  String translation;
  String title;
  String license;

  Translation(this.translation, this.title, this.license);

  factory Translation.fromMap(Map<String, dynamic> map) {
    return Translation(map['translation'], map['title'], map['license']);
  }
}
