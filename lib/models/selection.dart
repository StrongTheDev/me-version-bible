class Selection {
  int bookIndex = 0;
  int chapterIndex = 0;

  Selection();
  Selection.at(this.bookIndex, this.chapterIndex);

  @override
  String toString() {
    return "$bookIndex:$chapterIndex";
  }

  factory Selection.fromString(String str) {
    var parts = str.split(":");
    if (parts.length != 2) {
      throw Exception("Invalid selection string");
    }
    return Selection.at(int.parse(parts[0]), int.parse(parts[1]));
  }

  @override
  bool operator ==(Object other) {
    if (other is! Selection) {
      return false;
    }
    return hashCode == other.hashCode &&
        bookIndex == other.bookIndex &&
        chapterIndex == other.chapterIndex;
  }

  @override
  int get hashCode => Object.hash(bookIndex, chapterIndex);
}
