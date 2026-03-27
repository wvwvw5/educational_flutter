class Fact {
  final String text;

  Fact({required this.text});

  factory Fact.fromJson(Map<String, dynamic> json) {
    return Fact(text: json['fact'] ?? '');
  }
}
