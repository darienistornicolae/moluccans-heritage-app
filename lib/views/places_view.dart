import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../viewmodels/places_viewmodel.dart';
import '../widgets/place_card.dart';
import 'place_details_view.dart';

/// PlacesView displays places as cards
/// Follows MVVM pattern - UI observes ViewModel state
class PlacesView extends StatefulWidget {
  const PlacesView({super.key});

  @override
  State<PlacesView> createState() => _PlacesViewState();
}

class _PlacesViewState extends State<PlacesView> {
  late PlacesViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = PlacesViewModel();
    _viewModel.fetchPlaces();
    
    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _viewModel.loadMore();
    }
  }

  void _openPlaceDetails(PlaceModel place, String baseUrl) {
    final isCupertino = !kIsWeb && Platform.isIOS;
    final route = isCupertino
        ? CupertinoPageRoute<void>(
            builder: (context) => PlaceDetailsView(
              place: place,
              baseUrl: baseUrl,
            ),
          )
        : MaterialPageRoute<void>(
            builder: (context) => PlaceDetailsView(
              place: place,
              baseUrl: baseUrl,
            ),
          );
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Kamp Wyldemerk'),
        border: const Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 1.0,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<PlacesViewModel>(
          builder: (context, viewModel, child) {
            // Loading state (initial load)
            if (viewModel.isLoading && viewModel.places.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!kIsWeb && Platform.isIOS)
                      const CupertinoActivityIndicator(radius: 16)
                    else
                      const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Loading places...'),
                  ],
                ),
              );
            }

            // Error state (with no data)
            if (viewModel.hasError && viewModel.places.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        viewModel.errorMessage ?? 'An error occurred',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!kIsWeb && Platform.isIOS)
                      CupertinoButton.filled(
                        onPressed: () => viewModel.refresh(),
                        child: const Text('Retry'),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => viewModel.refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                  ],
                ),
              );
            }

            // Empty state
            if (viewModel.places.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No places found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for updates',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            // Success state with data
            return _buildPlatformList(viewModel);
          },
        ),
      ),
    );
  }

  /// Builds a platform-adaptive scrollable list
  Widget _buildPlatformList(PlacesViewModel viewModel) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final horizontalPadding = screenWidth > 600 ? 24.0 : 0.0; // More padding on larger screens
    
    // iOS uses ListView with CupertinoSliverRefreshControl wrapped in CustomScrollView
    if (!kIsWeb && Platform.isIOS) {
      // CustomScrollView is needed because CupertinoSliverRefreshControl is a Sliver widget
      // Sliver widgets can only be used inside CustomScrollView, not regular ListView
      return CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () => viewModel.refresh(),
          ),
          // Add safe area to ensure content starts below navigation bar
          SliverSafeArea(
            top: true,
            sliver: SliverPadding(
              padding: EdgeInsets.only(
                top: 16,
                bottom: 8,
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= viewModel.places.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      );
                    }

                    final place = viewModel.places[index];
                    return PlaceCard(
                      place: place,
                      baseUrl: viewModel.baseUrl,
                      onTap: () {
                        _openPlaceDetails(place, viewModel.baseUrl);
                      },
                    );
                  },
                  childCount: viewModel.places.length + (viewModel.hasMorePages ? 1 : 0),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Android/Web uses RefreshIndicator with ListView
    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: horizontalPadding,
          right: horizontalPadding,
        ),
        itemCount: viewModel.places.length + (viewModel.hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= viewModel.places.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final place = viewModel.places[index];
          // Add extra top padding for the first card
          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 8 : 0,
            ),
            child: PlaceCard(
              place: place,
              baseUrl: viewModel.baseUrl,
              onTap: () {
                _openPlaceDetails(place, viewModel.baseUrl);
              },
            ),
          );
        },
      ),
    );
  }
}

