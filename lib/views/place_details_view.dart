import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/place_model.dart';

class PlaceDetailsView extends StatelessWidget {
  final PlaceModel place;
  final String baseUrl;

  const PlaceDetailsView({
    super.key,
    required this.place,
    required this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(place.title),
        ),
        child: SafeArea(
          child: _buildContent(context),
        ),
      );
    }

    if (kIsWeb) {
      return Scaffold(
        body: SafeArea(
          child: _buildContent(context),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final description = place.description.isEmpty
        ? 'No description available.'
        : place.description;
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final horizontalPadding = width > 600 ? 24.0 : 16.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 24),
      children: [
        Text(
          place.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _PlaceImagesSection(
          place: place,
          baseUrl: baseUrl,
          availableWidth: width - (horizontalPadding * 2),
        ),
        if (place.hasImages) const SizedBox(height: 16),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        _CoordinatesSection(place: place),
        if (place.hasAudios) ...[
          const SizedBox(height: 20),
          Text(
            'Audio stories',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...place.audios.map((audio) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.audiotrack),
                title: Text(audio.title),
                subtitle: Text(audio.getFullUrl(baseUrl)),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _PlaceImagesSection extends StatelessWidget {
  final PlaceModel place;
  final String baseUrl;
  final double availableWidth;

  const _PlaceImagesSection({
    required this.place,
    required this.baseUrl,
    required this.availableWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (!place.hasImages) {
      return _ImagePlaceholder(width: availableWidth);
    }

    final itemWidth = availableWidth.clamp(260, 520).toDouble();

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: place.images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final image = place.images[index];
          final imageUrl = image.getFullUrl(baseUrl);
          return SizedBox(
            width: itemWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                webHtmlElementStrategy: kIsWeb
                    ? WebHtmlElementStrategy.prefer
                    : WebHtmlElementStrategy.never,
                errorBuilder: (context, error, stackTrace) {
                  return _ImagePlaceholder(width: itemWidth);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double width;

  const _ImagePlaceholder({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 240,
      child: Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: Icon(
          Icons.photo_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 48,
        ),
      ),
    );
  }
}

class _CoordinatesSection extends StatelessWidget {
  final PlaceModel place;

  const _CoordinatesSection({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.place_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Coordinates',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            '${place.latitudeValue.toStringAsFixed(4)}, ${place.longitudeValue.toStringAsFixed(4)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
