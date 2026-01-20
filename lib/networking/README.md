# Networking Layer

This folder contains the networking infrastructure for the Moluccans Heritage App. It follows **DRY** (Don't Repeat Yourself), **SOLID** principles, and **MVVM** (Model-View-ViewModel) architecture pattern.

## Architecture Overview

```
networking/
├── core/               # Core networking components
│   ├── api_client.dart      # Base HTTP client
│   └── api_exception.dart   # Custom exceptions
├── models/             # Data models
│   ├── place_model.dart
│   ├── image_model.dart
│   ├── audio_model.dart
│   └── places_response.dart
├── services/           # API service layer
│   └── places_api_service.dart
├── repositories/       # Repository layer
│   └── places_repository.dart
└── networking.dart     # Main export file
```

## Design Principles

### 1. SOLID Principles

- **Single Responsibility Principle (SRP)**: Each class has one responsibility
  - `ApiClient`: HTTP communication
  - `PlacesApiService`: Places API endpoints
  - `PlacesRepository`: Data management and caching
  - Models: Data representation only

- **Open/Closed Principle (OCP)**: Classes are open for extension but closed for modification
  - New API services can extend the base `ApiClient`
  - Custom exceptions extend `ApiException`

- **Liskov Substitution Principle (LSP)**: Subclasses can replace base classes
  - All custom exceptions can be caught as `ApiException`

- **Interface Segregation Principle (ISP)**: Clients depend only on what they use
  - Services expose only necessary methods
  - Models contain only relevant data

- **Dependency Inversion Principle (DIP)**: Depend on abstractions, not concretions
  - Repository depends on service abstraction
  - Services can be injected for testing

### 2. DRY (Don't Repeat Yourself)

- Common HTTP logic centralized in `ApiClient`
- Error handling abstracted into custom exceptions
- URL building and header management reused across all requests
- Model serialization/deserialization in one place

### 3. MVVM Pattern

```
View (news_view.dart)
    ↓
ViewModel (places_viewmodel.dart)
    ↓
Repository (places_repository.dart)
    ↓
Service (places_api_service.dart)
    ↓
API Client (api_client.dart)
    ↓
API
```

## Components

### Core Components

#### ApiClient
Base HTTP client that handles all network requests with proper error handling.

**Features:**
- GET, POST, PUT, DELETE methods
- Automatic JSON encoding/decoding
- Timeout handling
- Custom headers support
- Query parameter support
- Exception mapping

**Usage:**
```dart
final client = ApiClient(baseUrl: 'https://api.example.com');
final data = await client.get('/endpoint');
```

#### ApiException
Custom exception hierarchy for different error types:
- `NetworkException`: Connection issues
- `TimeoutException`: Request timeout
- `ServerException`: 5xx errors
- `ClientException`: 4xx errors
- `ParseException`: JSON parsing errors

### Models

Data classes that represent API responses:
- `PlaceModel`: Heritage place with location, images, and audio
- `ImageModel`: Image metadata and URL
- `AudioModel`: Audio file metadata and URL
- `PlacesResponse`: Paginated list of places

All models include:
- `fromJson()`: Create instance from JSON
- `toJson()`: Convert instance to JSON
- Helper methods for data access

### Services

#### PlacesApiService
Handles all API calls related to places.

**Methods:**
- `getPlaces({int page})`: Fetch paginated places
- `getPlaceById(int id)`: Fetch single place
- `baseUrl`: Get base URL for images/audio

### Repositories

#### PlacesRepository
Manages data access and provides clean API to ViewModels.

**Features:**
- Error handling and transformation
- Future: Caching support
- Future: Offline support
- Data validation

**Methods:**
- `fetchPlaces({int page})`: Get places list
- `fetchPlaceById(int id)`: Get single place
- `baseUrl`: Base URL for assets

## Usage Example

### In a ViewModel

```dart
class PlacesViewModel extends ChangeNotifier {
  final PlacesRepository _repository;
  List<PlaceModel> _places = [];
  
  PlacesViewModel({PlacesRepository? repository})
      : _repository = repository ?? PlacesRepository();
  
  Future<void> fetchPlaces() async {
    try {
      _places = await _repository.fetchPlaces();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
```

### In a View

```dart
class MyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlacesViewModel()..fetchPlaces(),
      child: Consumer<PlacesViewModel>(
        builder: (context, viewModel, _) {
          return ListView.builder(
            itemCount: viewModel.places.length,
            itemBuilder: (context, index) {
              final place = viewModel.places[index];
              return PlaceCard(place: place);
            },
          );
        },
      ),
    );
  }
}
```

## Testing

The architecture supports easy testing:

```dart
// Mock repository for testing
class MockPlacesRepository extends PlacesRepository {
  @override
  Future<List<PlaceModel>> fetchPlaces({int page = 1}) async {
    return [/* mock data */];
  }
}

// Use in tests
final viewModel = PlacesViewModel(
  repository: MockPlacesRepository(),
);
```

## Adding New Endpoints

1. **Add service method** in appropriate service class
2. **Add repository method** to handle errors and caching
3. **Update ViewModel** with new functionality
4. **Update View** to use new data

Example:
```dart
// 1. Service
class PlacesApiService {
  Future<PlaceModel> createPlace(PlaceModel place) async {
    return await _apiClient.post('/api/places', body: place.toJson());
  }
}

// 2. Repository
class PlacesRepository {
  Future<PlaceModel> createPlace(PlaceModel place) async {
    try {
      return await _apiService.createPlace(place);
    } catch (e) {
      throw PlacesRepositoryException(message: 'Failed to create place');
    }
  }
}

// 3. ViewModel
class PlacesViewModel {
  Future<void> createPlace(PlaceModel place) async {
    try {
      final newPlace = await _repository.createPlace(place);
      _places.add(newPlace);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
```

## Error Handling

Errors flow through the layers:
1. **ApiClient**: Network/HTTP errors → Custom exceptions
2. **Service**: API-specific errors
3. **Repository**: Business logic errors
4. **ViewModel**: User-facing error messages
5. **View**: Error UI display

## Future Enhancements

- [ ] Local caching with shared_preferences or hive
- [ ] Offline support
- [ ] Request queuing
- [ ] Request cancellation
- [ ] Authentication/Authorization
- [ ] Request/Response interceptors
- [ ] Analytics integration
- [ ] Retry logic with exponential backoff
