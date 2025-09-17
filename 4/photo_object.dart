class PhotoInfo {
  final String fileName;
  final String name;
  final String description;
  final List<String> tags;
  final DateTime createdDate;

  PhotoInfo({
    required this.fileName,
    required this.name,
    required this.description,
    required this.tags,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'name': name,
      'description': description,
      'tags': tags,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  // Фабричный конструктор - возвращает объект, а не создает. 
  // Сырые данные (Map) в готовый объект PhotoInfo.
  factory PhotoInfo.fromMap(Map<String, dynamic> map) {
    return PhotoInfo(
      fileName: map['fileName'],
      name: map['name'],
      description: map['description'],
      tags: List<String>.from(map['tags']),
      createdDate: DateTime.parse(map['createdDate']),
    );
  }

}
