import 'package:flutter/foundation.dart';
import '../models/place_model.dart';
import '../networking/repositories/places_repository.dart';
import '../networking/interfaces/places_repository_interface.dart';

class PlacesViewModel extends ChangeNotifier {
  final PlacesRepositoryInterface _repository;

  List<PlaceModel> _places = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMorePages = true;

  PlacesViewModel({PlacesRepositoryInterface? repository})
      : _repository = repository ?? PlacesRepository();

  List<PlaceModel> get places => _places;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMorePages => _hasMorePages;
  int get currentPage => _currentPage;
  bool get hasError => _errorMessage != null;
  String get baseUrl => _repository.baseUrl;

  Future<void> fetchPlaces({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _resetState();
    }

    if (!_hasMorePages && !refresh) return;

    _setLoading(true);

    try {
      final fetchedPlaces = await _repository.fetchPlaces(page: _currentPage);
      
      _updatePlaces(fetchedPlaces, refresh);
      _updatePagination(fetchedPlaces);
      _clearError();
    } on PlacesRepositoryException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => fetchPlaces(refresh: true);

  Future<void> loadMore() async {
    if (!_isLoading && _hasMorePages) {
      await fetchPlaces(refresh: false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  PlaceModel? getPlaceById(int id) {
    try {
      return _places.firstWhere((place) => place.numericId == id);
    } catch (e) {
      return null;
    }
  }

  List<PlaceModel> searchPlaces(String query) {
    if (query.isEmpty) return _places;
    
    final lowercaseQuery = query.toLowerCase();
    return _places._filterByQuery(lowercaseQuery);
  }

  void _resetState() {
    _currentPage = 1;
    _places = [];
    _hasMorePages = true;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _updatePlaces(List<PlaceModel> fetchedPlaces, bool refresh) {
    if (refresh) {
      _places = fetchedPlaces;
    } else {
      _places.addAll(fetchedPlaces);
    }
  }

  void _updatePagination(List<PlaceModel> fetchedPlaces) {
    _hasMorePages = fetchedPlaces.isNotEmpty;
    if (fetchedPlaces.isNotEmpty) {
      _currentPage++;
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    debugPrint('Error fetching places: $message');
  }

  void _clearError() {
    _errorMessage = null;
  }
}

extension _PlaceListPrivate on List<PlaceModel> {
  List<PlaceModel> _filterByQuery(String lowercaseQuery) {
    return where((place) {
      return place.title.toLowerCase().contains(lowercaseQuery) ||
          place.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
