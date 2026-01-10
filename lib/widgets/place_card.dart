import 'package:flutter/material.dart';
import '../models/place_model.dart';

/// A card widget to display place information
/// Follows Single Responsibility Principle - only displays place data
class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final String baseUrl;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.place,
    required this.baseUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            if (place.hasImages) _buildImage() else _buildPlaceholder(),
            
            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    place.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    place.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Additional info
                  _buildInfoRow(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = place.images.first.getFullUrl(baseUrl);
    
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.grey[300],
        child: const Icon(
          Icons.location_on,
          size: 64,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    return Row(
      children: [
        // Images indicator
        if (place.hasImages)
          Row(
            children: [
              Icon(
                Icons.image,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${place.images.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
            ],
          ),
        
        // Audio indicator
        if (place.hasAudios)
          Row(
            children: [
              Icon(
                Icons.audiotrack,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${place.audios.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
            ],
          ),
        
        // Location indicator
        Icon(
          Icons.location_pin,
          size: 16,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 4),
        Text(
          '${place.latitudeValue.toStringAsFixed(2)}, ${place.longitudeValue.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
