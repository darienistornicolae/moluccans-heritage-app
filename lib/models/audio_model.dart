/// Model representing an audio file from the API
class AudioModel {
  final String id;
  final String type;
  final int numericId;
  final String url;
  final String title;
  final String description;

  AudioModel({
    required this.id,
    required this.type,
    required this.numericId,
    required this.url,
    required this.title,
    required this.description,
  });

  /// Creates an AudioModel from JSON
  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      id: json['@id'] as String,
      type: json['@type'] as String,
      numericId: json['id'] as int,
      url: json['url'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  /// Converts AudioModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '@id': id,
      '@type': type,
      'id': numericId,
      'url': url,
      'title': title,
      'description': description,
    };
  }

  /// Gets the full URL for the audio file
  String getFullUrl(String baseUrl) {
    if (url.startsWith('http')) {
      return url;
    }
    return '$baseUrl$url';
  }
}
