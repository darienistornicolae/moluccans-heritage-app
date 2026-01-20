/// Model representing an image from the API
class ImageModel {
  final String id;
  final String type;
  final int numericId;
  final String url;
  final String title;
  final String description;

  ImageModel({
    required this.id,
    required this.type,
    required this.numericId,
    required this.url,
    required this.title,
    required this.description,
  });

  /// Creates an ImageModel from JSON
  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['@id'] as String,
      type: json['@type'] as String,
      numericId: json['id'] as int,
      url: json['url'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  /// Converts ImageModel to JSON
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

  /// Gets the full URL for the image
  String getFullUrl(String baseUrl) {
    if (url.startsWith('http')) {
      if (url.startsWith('http://')) {
        return url.replaceFirst('http://', 'https://');
      }
      return url;
    }
    return '$baseUrl$url';
  }
}
