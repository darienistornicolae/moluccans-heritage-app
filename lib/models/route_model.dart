class RouteModel {
  final List<RouteStep> steps;
  final double duration;
  final double distance;
  final List<Coordinate> coordinates;

  RouteModel({
    required this.steps,
    required this.duration,
    required this.distance,
    required this.coordinates,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final geometry = route['geometry'];
    final leg = route['legs'][0];
    
    final coordinates = (geometry['coordinates'] as List)
        .map((coord) => Coordinate(coord[0].toDouble(), coord[1].toDouble()))
        .toList();

    final steps = (leg['steps'] as List)
        .map((step) => RouteStep.fromJson(step))
        .toList();

    return RouteModel(
      steps: steps,
      duration: route['duration'].toDouble(),
      distance: route['distance'].toDouble(),
      coordinates: coordinates,
    );
  }

  double get durationMinutes => duration / 60;
}

class RouteStep {
  final String instruction;
  final double distance;

  RouteStep({
    required this.instruction,
    required this.distance,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['maneuver']?['instruction'] ?? 'Continue',
      distance: (json['distance'] ?? 0).toDouble(),
    );
  }

  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    }
    return '${(distance / 1000).toStringAsFixed(2)} km';
  }
}

class Coordinate {
  final double longitude;
  final double latitude;

  Coordinate(this.longitude, this.latitude);
}