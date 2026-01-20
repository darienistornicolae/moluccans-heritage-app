/// Model representing an audio file from the API
class AudioModel {
  final String url;
  final String title;
  final String place;
  final String file;

  AudioModel({
    required this.url,
    required this.title,
    required this.place,
    required this.file,
  });

  /// Creates an AudioModel from JSON
  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      url: json['url'] as String,
      title: json['title'] as String,
      place: json['place'] as String,
      file: json['file'] as String,
    );
  }

  /// Converts AudioModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'place': place,
      'file': file,
    };
  }

  /// Gets the full URL for the audio file
  String getFullUrl(String baseUrl) {
    if (file.startsWith('http')) {
      if (file.startsWith('http://')) {
        return file.replaceFirst('http://', 'https://');
      }
      return file;
    }
    return '$baseUrl$file';
  }
}
