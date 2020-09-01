class Planet {
  String title;
  DateTime startDate;

  Planet(
    this.title,
    this.startDate,
  );

  Map<String, dynamic> toJson() => {
        'title': title,
        'startDate': startDate,
      };
}
