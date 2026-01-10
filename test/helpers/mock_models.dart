import 'package:moluccans_heritage_app/models/place_model.dart';
import 'package:moluccans_heritage_app/models/image_model.dart';
import 'package:moluccans_heritage_app/models/audio_model.dart';
import 'package:moluccans_heritage_app/models/places_response.dart';

class MockModels {
  static ImageModel createMockImage({
    String? id,
    int? numericId,
    String? url,
    String? title,
    String? description,
  }) {
    return ImageModel(
      id: id ?? '/api/images/1',
      type: 'Image',
      numericId: numericId ?? 1,
      url: url ?? '/uploads/images/test.png',
      title: title ?? 'Test Image',
      description: description ?? 'Test image description',
    );
  }

  static AudioModel createMockAudio({
    String? id,
    int? numericId,
    String? url,
    String? title,
    String? description,
  }) {
    return AudioModel(
      id: id ?? '/api/audios/1',
      type: 'Audio',
      numericId: numericId ?? 1,
      url: url ?? '/uploads/audios/test.mp3',
      title: title ?? 'Test Audio',
      description: description ?? 'Test audio description',
    );
  }

  static PlaceModel createMockPlace({
    String? id,
    int? numericId,
    String? title,
    String? description,
    String? longitude,
    String? latitude,
    List<ImageModel>? images,
    List<AudioModel>? audios,
  }) {
    return PlaceModel(
      id: id ?? '/api/places/1',
      type: 'Place',
      numericId: numericId ?? 1,
      title: title ?? 'Test Place',
      description: description ?? 'Test place description',
      longitude: longitude ?? '5.528448822491121',
      latitude: latitude ?? '52.8737544770815',
      images: images ?? [createMockImage()],
      audios: audios ?? [],
    );
  }

  static PlacesResponse createMockPlacesResponse({
    int? totalItems,
    List<PlaceModel>? places,
  }) {
    return PlacesResponse(
      context: '/api/contexts/Place',
      id: '/api/places',
      type: 'Collection',
      totalItems: totalItems ?? 3,
      places: places ?? [
        createMockPlace(numericId: 1, title: 'Place 1'),
        createMockPlace(numericId: 2, title: 'Place 2'),
        createMockPlace(numericId: 3, title: 'Place 3'),
      ],
    );
  }

  static Map<String, dynamic> createMockPlaceJson({
    int? id,
    String? title,
    String? description,
  }) {
    return {
      '@id': '/api/places/${id ?? 1}',
      '@type': 'Place',
      'id': id ?? 1,
      'title': title ?? 'Test Place',
      'description': description ?? 'Test description',
      'longitude': '5.528448822491121',
      'latitude': '52.8737544770815',
      'images': [
        {
          '@id': '/api/images/1',
          '@type': 'Image',
          'id': 1,
          'url': '/uploads/images/test.png',
          'title': 'Test Image',
          'description': 'Test image description',
        }
      ],
      'audios': [],
    };
  }

  static Map<String, dynamic> createMockPlacesResponseJson({
    int? totalItems,
    List<Map<String, dynamic>>? places,
  }) {
    return {
      '@context': '/api/contexts/Place',
      '@id': '/api/places',
      '@type': 'Collection',
      'totalItems': totalItems ?? 3,
      'member': places ?? [
        createMockPlaceJson(id: 1, title: 'Place 1'),
        createMockPlaceJson(id: 2, title: 'Place 2'),
        createMockPlaceJson(id: 3, title: 'Place 3'),
      ],
    };
  }
}
