import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../app/app_dependencies.dart';
import '../../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_empty_state.dart';
import '../../../../../shared/widgets/app_error_view.dart';
import '../../../navigation/real_estate_navigation_config.dart';
import '../../../widgets/real_estate_filter_bar/real_estate_filter_bar.dart';
import '../../../widgets/real_estate_search_bar/real_estate_search_bar.dart';
import '../controllers/real_estate_map_controller.dart';
import '../widgets/map_controls_bar.dart';
import '../widgets/property_map_preview_card.dart';
import '../widgets/property_price_marker.dart';
import '../widgets/search_this_area_button.dart';
import '../../utils/map_constants.dart';

class RealEstateMapPage extends StatefulWidget {
  final RealEstateMapController? controller;

  const RealEstateMapPage({super.key, this.controller});

  @override
  State<RealEstateMapPage> createState() => _RealEstateMapPageState();
}

class _RealEstateMapPageState extends State<RealEstateMapPage> {
  late final RealEstateMapController _controller;
  late final MapController _flutterMapController;
  final bool _isNavVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RealEstateMapController();
    _flutterMapController = MapController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _flutterMapController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final currentZoom = _flutterMapController.camera.zoom;
    _flutterMapController.move(
      _flutterMapController.camera.center,
      (currentZoom + 1.0).clamp(MapConstants.minZoom, MapConstants.maxZoom),
    );
  }

  void _zoomOut() {
    final currentZoom = _flutterMapController.camera.zoom;
    _flutterMapController.move(
      _flutterMapController.camera.center,
      (currentZoom - 1.0).clamp(MapConstants.minZoom, MapConstants.maxZoom),
    );
  }

  void _recenterMap() {
    _flutterMapController.move(
      MapConstants.defaultCenter,
      MapConstants.defaultZoom,
    );
  }

  void _openPropertyDetails(String id) {
    if (GoRouter.maybeOf(context) != null) {
      context.push('${RouteNames.realEstateDetail}?id=$id');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فتح تفاصيل العقار: $id'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleAddProperty() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إضافة عقار جديد من الخريطة',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                const Text('حدد تفاصيل الإعلان والعنوان الجغرافي:'),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: const Icon(
                    Icons.home_work_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('إعلان عقار للبيع على الخريطة'),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.key_outlined,
                    color: AppColors.secondary,
                  ),
                  title: const Text('إعلان عقار للإيجار على الخريطة'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.maybeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          bottom: false,
          child: ValueListenableBuilder<RealEstateMapState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.errorMessage != null) {
                return Center(
                  child: AppErrorView(
                    message: state.errorMessage!,
                    onRetry: _controller.loadMapProperties,
                  ),
                );
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Interactive Flutter Map Viewport
                  FlutterMap(
                    mapController: _flutterMapController,
                    options: MapOptions(
                      initialCenter: MapConstants.defaultCenter,
                      initialZoom: MapConstants.defaultZoom,
                      minZoom: MapConstants.minZoom,
                      maxZoom: MapConstants.maxZoom,
                      onPositionChanged: (position, hasGesture) {
                        if (hasGesture) {
                          _controller.onCameraMoved();
                        }
                      },
                      onTap: (_, _) {
                        _controller.selectProperty(null);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: MapConstants.openStreetMapTileUrl,
                        userAgentPackageName: 'com.marketspace.app',
                      ),
                      MarkerLayer(
                        markers: state.filteredListings.map((property) {
                          final isSelected =
                              state.selectedProperty?.id == property.id;
                          return Marker(
                            point: LatLng(
                              property.latitude!,
                              property.longitude!,
                            ),
                            width: 135.0,
                            height: 42.0,
                            child: PropertyPriceMarker(
                              property: property,
                              isSelected: isSelected,
                              onTap: () {
                                _controller.selectProperty(property);
                                _flutterMapController.move(
                                  LatLng(
                                    property.latitude!,
                                    property.longitude!,
                                  ),
                                  _flutterMapController.camera.zoom,
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // Loading Indicator Overlay
                  if (state.isLoading)
                    Positioned(
                      top: 130.0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14.0,
                                height: 14.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'جاري تحديث عقارات الخريطة...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 2. Top Floating Header Search & Filters Bar
                  Positioned(
                    top: 8.0,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RealEstateSearchBar(
                          onChanged: _controller.setSearchQuery,
                          onFilterTap: () {},
                        ),
                        RealEstateFilterBar(
                          selectedType: state.selectedType,
                          onTypeSelected: _controller.setFilterType,
                          onSortTap: () {},
                        ),
                      ],
                    ),
                  ),

                  // 3. "Search this area" Button
                  if (state.showSearchAreaButton)
                    Positioned(
                      top: 125.0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SearchThisAreaButton(
                          onTap: _controller.searchCurrentArea,
                        ),
                      ),
                    ),

                  // 4. Map Zoom & Recenter Controls Bar
                  Positioned(
                    left: 14.0,
                    bottom: state.selectedProperty != null ? 195.0 : 90.0,
                    child: MapControlsBar(
                      onZoomIn: _zoomIn,
                      onZoomOut: _zoomOut,
                      onRecenter: _recenterMap,
                    ),
                  ),

                  // 5. Selected Property Preview Card
                  if (state.selectedProperty != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 84.0,
                      child: PropertyMapPreviewCard(
                        property: state.selectedProperty!,
                        onDetailsTap: () =>
                            _openPropertyDetails(state.selectedProperty!.id),
                        onCloseTap: () => _controller.selectProperty(null),
                      ),
                    ),

                  // Empty Map State
                  if (state.filteredListings.isEmpty && !state.isLoading)
                    Positioned(
                      top: 180.0,
                      left: 20.0,
                      right: 20.0,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        child: const AppEmptyState(
                          title: 'لا توجد عقارات في هذه المنطقة',
                          message: 'جرّب تكبير الخريطة أو حرك موقع الكاميرا للمزيد من النتائج',
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: RealEstateNavigationConfig.config,
          currentIndex: 2, // 3rd tab is "الخريطة"
          onTabSelected: (index) {
            if (index == 0 && GoRouter.maybeOf(context) != null) {
              context.go(RouteNames.realEstate);
            } else if (index == 1 && GoRouter.maybeOf(context) != null) {
              context.push('/real-estate/reels');
            } else if (index == 3 && GoRouter.maybeOf(context) != null) {
              context.push('/real-estate/favorites');
            } else if (index == 4 && GoRouter.maybeOf(context) != null) {
              context.push('/real-estate/notifications');
            }
          },
          onFloatingActionPressed: _handleAddProperty,
          notificationController: dependencies?.notificationController,
          isVisible: _isNavVisible,
        ),
      ),
    );
  }
}
