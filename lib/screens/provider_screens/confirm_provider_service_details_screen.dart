import 'dart:convert';
import 'dart:async';
import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/ServiceArrivalProvider.dart';
import 'package:first_flutter/widgets/user_only_title_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';

import '../../NATS Service/NatsService.dart';
import '../../widgets/ProviderConfirmServiceDetails.dart';
import '../user_screens/WidgetProviders/EndWorkOTPDialog.dart';
import '../user_screens/WidgetProviders/OTPDialog.dart';
import '../../providers/StartWorkProvider.dart';
import 'navigation/ServiceTimerScreen.dart';

class ConfirmProviderServiceDetailsScreen extends StatefulWidget {
  final String serviceId;

  const ConfirmProviderServiceDetailsScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<ConfirmProviderServiceDetailsScreen> createState() =>
      _ConfirmProviderServiceDetailsScreenState();
}

class _ConfirmProviderServiceDetailsScreenState
    extends State<ConfirmProviderServiceDetailsScreen> {
  final NatsService _natsService = NatsService();
  Map<String, dynamic>? _serviceData;
  Map<String, dynamic>? _locationData;
  bool _isLoading = true;
  String? _errorMessage;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};
  String? _arrivalTime;
  Timer? _locationUpdateTimer;
  bool _isMapReady = false;

  bool _isNearDestination = false;
  double _distanceToDestination = 0.0;
  static const double ARRIVAL_THRESHOLD_METERS = 100.0;

  static const String GOOGLE_MAPS_API_KEY =
      'AIzaSyAkV6lz1n4MNS_lJaje3oIEXa2DN4QMz6U';

  @override
  void initState() {
    super.initState();
    _initializeAndFetchData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arrivalProvider = Provider.of<ServiceArrivalProvider>(
        context,
        listen: false,
      );
      arrivalProvider.loadTimerState(widget.serviceId);
    });
  }

  Future<void> _initializeAndFetchData() async {
    try {
      if (!_natsService.isConnected) {
        final connected = await _natsService.connect(
          url: 'nats://api.moyointernational.com:4222',
        );

        if (!connected) {
          setState(() {
            _errorMessage = 'Failed to connect to NATS server';
            _isLoading = false;
          });
          return;
        }
      }

      await _fetchServiceDetails();
      await _fetchLocationDetails();

      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: 10),
        (timer) => _fetchLocationDetails(),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchServiceDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final providerToken = prefs.getString('provider_auth_token');

      if (providerToken == null) {
        setState(() {
          _errorMessage = 'Provider authentication token not found';
          _isLoading = false;
        });
        return;
      }

      String? providerId;
      try {
        final parts = providerToken.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          providerId =
              payload['provider_id']?.toString() ??
              payload['id']?.toString() ??
              payload['sub']?.toString();
        } else {
          providerId = providerToken;
        }
      } catch (e) {
        providerId = providerToken;
      }

      if (providerId == null) {
        setState(() {
          _errorMessage = 'Could not extract provider ID from token';
          _isLoading = false;
        });
        return;
      }

      final requestData = jsonEncode({
        'service_id': widget.serviceId,
        'provider_id': providerId,
      });

      final response = await _natsService.request(
        'service.info.details',
        requestData,
        timeout: const Duration(seconds: 5),
      );

      if (response != null) {
        final data = jsonDecode(response);
        setState(() {
          _serviceData = data;
        });
      } else {
        setState(() {
          _errorMessage = 'No response received from server';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching service details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLocationDetails() async {
    try {
      final requestData = jsonEncode({'service_id': widget.serviceId});

      final response = await _natsService.request(
        'service.location.info',
        requestData,
        timeout: const Duration(seconds: 3),
      );

      if (response != null) {
        final data = jsonDecode(response);
        setState(() {
          _locationData = data;
          _isLoading = false;
        });

        _checkArrivalDistance();

        if (_isMapReady) {
          _setupMap(animate: _markers.isNotEmpty);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching location details: $e');
    }
  }

  void _checkArrivalDistance() {
    if (_locationData == null) return;

    final serviceLat = double.tryParse(
      _locationData!['latitude']?.toString() ?? '0',
    );
    final serviceLng = double.tryParse(
      _locationData!['longitude']?.toString() ?? '0',
    );
    final providerLat = double.tryParse(
      _locationData!['provider']?['latitude']?.toString() ?? '0',
    );
    final providerLng = double.tryParse(
      _locationData!['provider']?['longitude']?.toString() ?? '0',
    );

    if (serviceLat == null ||
        serviceLng == null ||
        providerLat == null ||
        providerLng == null) {
      return;
    }

    final distanceKm = _calculateDistance(
      providerLat,
      providerLng,
      serviceLat,
      serviceLng,
    );

    _distanceToDestination = distanceKm * 1000;

    setState(() {
      _isNearDestination = _distanceToDestination <= ARRIVAL_THRESHOLD_METERS;
    });
  }

  Future<void> _handleArrived() async {
    final provider = Provider.of<ServiceArrivalProvider>(
      context,
      listen: false,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Confirm Arrival',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Have you arrived at the service location?',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(fontSize: 16.sp)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            ),
            child: Text(
              'Yes, I\'ve Arrived',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.confirmProviderArrival(widget.serviceId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Arrival confirmed! Timer started for work.',
                style: TextStyle(fontSize: 14.sp),
              ),
              backgroundColor: Colors.green,
            ),
          );

          await _fetchServiceDetails();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.errorMessage ?? 'Failed to confirm arrival',
                style: TextStyle(fontSize: 14.sp),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showOTPDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return OTPDialog(serviceId: widget.serviceId);
      },
    );

    // Handle the result after dialog is closed
    if (result == true && mounted) {
      // Clear arrival timer state
      final arrivalProvider = Provider.of<ServiceArrivalProvider>(
        context,
        listen: false,
      );
      await arrivalProvider.clearTimerState(widget.serviceId);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Work started successfully!',
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Fetch latest service details to get duration
        await _fetchServiceDetails();

        if (_serviceData != null) {
          // Extract duration information
          final durationValue = _serviceData!['duration_value'] ?? 1;
          final durationUnit = _serviceData!['duration_unit'] ?? 'hour';

          // Navigate to Timer Screen
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ServiceTimerScreen(
                  serviceId: widget.serviceId,
                  durationValue: durationValue is int
                      ? durationValue
                      : int.tryParse(durationValue.toString()) ?? 1,
                  durationUnit: durationUnit.toString(),
                ),
              ),
            );
          }
        }

        // Reset provider state
        final startWorkProvider = Provider.of<StartWorkProvider>(
          context,
          listen: false,
        );
        startWorkProvider.reset();
      }
    }
  }

  // NEW METHOD: Navigate to Timer Screen without OTP
  void _navigateToTimerScreen() {
    if (_serviceData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Service data not available',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Extract duration information
    final durationValue = _serviceData!['duration_value'] ?? 1;
    final durationUnit = _serviceData!['duration_unit'] ?? 'hour';

    // Navigate to Timer Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ServiceTimerScreen(
          serviceId: widget.serviceId,
          durationValue: durationValue is int
              ? durationValue
              : int.tryParse(durationValue.toString()) ?? 1,
          durationUnit: durationUnit.toString(),
        ),
      ),
    );
  }

  bool _isWorkInProgress() {
    if (_serviceData == null) return false;
    final status = _serviceData!['status']?.toString().toLowerCase() ?? '';
    return status == 'in_progress' || status == 'started';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isWorkInProgress() && _serviceData != null) {
        final durationValue = _serviceData!['duration_value'] ?? 1;
        final durationUnit = _serviceData!['duration_unit'] ?? 'hour';

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ServiceTimerScreen(
              serviceId: widget.serviceId,
              durationValue: durationValue is int
                  ? durationValue
                  : int.tryParse(durationValue.toString()) ?? 1,
              durationUnit: durationUnit.toString(),
            ),
          ),
        );
      }
    });
  }

  Future<List<LatLng>> _getDirectionsRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$GOOGLE_MAPS_API_KEY&mode=driving';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final routes = data['routes'] as List;
          if (routes.isNotEmpty) {
            final route = routes[0];

            final legs = route['legs'] as List;
            if (legs.isNotEmpty) {
              final duration = legs[0]['duration'];
              if (duration != null) {
                final durationValue = duration['value'];
                setState(() {
                  _arrivalTime = (durationValue / 60).round().toString();
                });
              }
            }

            final polylinePoints = route['overview_polyline']['points'];
            List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(
              polylinePoints,
            );

            return decodedPoints
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();
          }
        }
      }

      return [origin, destination];
    } catch (e) {
      debugPrint('Error fetching directions: $e');
      return [origin, destination];
    }
  }

  void _setupMap({bool animate = false}) async {
    if (_locationData == null) return;

    final serviceLat = double.tryParse(
      _locationData!['latitude']?.toString() ?? '0',
    );
    final serviceLng = double.tryParse(
      _locationData!['longitude']?.toString() ?? '0',
    );
    final providerLat = double.tryParse(
      _locationData!['provider']?['latitude']?.toString() ?? '0',
    );
    final providerLng = double.tryParse(
      _locationData!['provider']?['longitude']?.toString() ?? '0',
    );

    if (serviceLat == null ||
        serviceLng == null ||
        providerLat == null ||
        providerLng == null) {
      return;
    }

    final providerLocation = LatLng(providerLat, providerLng);
    final serviceLocation = LatLng(serviceLat, serviceLng);

    final distance = _calculateDistance(
      providerLat,
      providerLng,
      serviceLat,
      serviceLng,
    );
    final fallbackTimeInMinutes = (distance / 0.5).round();

    _markers = {
      Marker(
        markerId: const MarkerId('service_location'),
        position: serviceLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        anchor: const Offset(0.5, 1.0),
        infoWindow: const InfoWindow(title: 'Service Location'),
      ),
      Marker(
        markerId: const MarkerId('provider_location'),
        position: providerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        anchor: const Offset(0.5, 0.5),
        infoWindow: const InfoWindow(title: 'Provider Location'),
      ),
    };

    _circles = {
      Circle(
        circleId: const CircleId('provider_circle'),
        center: providerLocation,
        radius: 1,
        fillColor: Colors.orange.withOpacity(0.2),
        strokeColor: Colors.orange,
        strokeWidth: 2,
      ),
    };

    List<LatLng> routePoints = await _getDirectionsRoute(
      providerLocation,
      serviceLocation,
    );

    if (_arrivalTime == null) {
      _arrivalTime = fallbackTimeInMinutes.toString();
    }

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: const Color(0xFF5B8DEE),
        width: 5,
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };

    setState(() {});

    if (_mapController != null) {
      final bounds = _calculateBounds([serviceLocation, providerLocation]);

      Future.delayed(const Duration(milliseconds: 100), () {
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      });
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (var pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    double latPadding = (maxLat - minLat) * 0.2;
    double lngPadding = (maxLng - minLng) * 0.2;

    return LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '';
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return ' at $displayHour:$minute $period';
      }
      return ' at $timeString';
    } catch (e) {
      return ' at $timeString';
    }
  }

  String _formatDuration(Map<String, dynamic> data) {
    final mode = data['service_mode'];
    final value = data['duration_value'];
    final unit = data['duration_unit'];

    if (mode == null || value == null) return 'N/A';

    if (mode == 'hrs') {
      final unitText = unit ?? 'hour';
      return '$value $unitText${value > 1 ? 's' : ''}';
    } else if (mode == 'days') {
      return '$value day${value > 1 ? 's' : ''}';
    }
    return 'N/A';
  }

  String _getDurationType(String? mode) {
    if (mode == null) return 'One Time';
    if (mode == 'hrs') return 'Hourly';
    if (mode == 'days') return 'Daily';
    return 'One Time';
  }

  List<String> _buildParticulars(Map<String, dynamic> data) {
    final List<String> particulars = [];

    final service = data['service'];
    if (service != null && service.toString().isNotEmpty) {
      particulars.add(service.toString());
    }

    final tenure = data['tenure'];
    if (tenure != null && tenure.toString().isNotEmpty) {
      particulars.add(tenure.toString().replaceAll('_', ' '));
    }

    final duration = _formatDuration(data);
    if (duration != 'N/A') {
      particulars.add(duration);
    }

    final serviceType = data['service_type'];
    if (serviceType != null && serviceType.toString().isNotEmpty) {
      particulars.add('Type: ${serviceType.toString()}');
    }

    final paymentMethod = data['payment_method'];
    if (paymentMethod != null && paymentMethod.toString().isNotEmpty) {
      particulars.add('Payment: ${paymentMethod.toString()}');
    }

    final dynamicFields = data['dynamic_fields'];
    if (dynamicFields != null && dynamicFields is Map<String, dynamic>) {
      dynamicFields.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          final formattedKey = key.replaceAll('_', ' ');
          particulars.add('$formattedKey: $value');
        }
      });
    }

    return particulars;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.call4helpScaffoldGradient,
      appBar: UserOnlyTitleAppbar(title: "Service Details"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _initializeAndFetchData();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: Text('Retry', style: TextStyle(fontSize: 16.sp)),
                  ),
                ],
              ),
            )
          : _serviceData == null
          ? Center(
              child: Text(
                'No service data available',
                style: TextStyle(fontSize: 16.sp),
              ),
            )
          : Consumer<ServiceArrivalProvider>(
              builder: (context, arrivalProvider, child) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProviderConfirmServiceDetails(
                        isProvider: true,
                        user_id: _serviceData!['user_id']?.toString() ?? 'N/A',
                        category:
                            _serviceData!['category']?.toString() ?? 'N/A',
                        serviceId: _serviceData!['id']?.toString() ?? 'N/A',
                        subCategory:
                            _serviceData!['service']?.toString() ??
                            _serviceData!['title']?.toString() ??
                            'N/A',
                        date:
                            _formatDate(_serviceData!['schedule_date']) +
                            _formatTime(_serviceData!['schedule_time']),
                        pin: _serviceData!['start_otp']?.toString() ?? 'N/A',
                        providerPhone:
                            _serviceData!['user']?['mobile']?.toString() ??
                            'N/A',
                        dp:
                            _serviceData!['user']?['image']?.toString() ??
                            'https://picsum.photos/200/200',
                        name:
                            '${_serviceData!['user']?['firstname']?.toString() ?? ''} ${_serviceData!['user']?['lastname']?.toString() ?? ''}'
                                .trim()
                                .isEmpty
                            ? 'N/A'
                            : '${_serviceData!['user']?['firstname']?.toString() ?? ''} ${_serviceData!['user']?['lastname']?.toString() ?? ''}'
                                  .trim(),
                        rating: "4.5",
                        status:
                            _serviceData!['status']?.toString() ?? 'pending',
                        durationType: _getDurationType(
                          _serviceData!['service_mode']?.toString(),
                        ),
                        duration: _formatDuration(_serviceData!),
                        price: _serviceData!['bid']?['amount']?.toString(),
                        address: _serviceData!['location']?.toString() ?? 'N/A',
                        particular: _buildParticulars(_serviceData!),
                        description:
                            _serviceData!['description']?.toString() ?? 'N/A',
                        onStartWork: _showOTPDialog,
                        onTaskComplete: _showEndWorkOTPDialog,
                        onSeeWorktime: _navigateToTimerScreen,
                      ),
                      if (_locationData != null && _shouldShowMap()) ...[
                        SizedBox(height: 16.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Container(
                            height: 300.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    double.parse(
                                      _locationData!['latitude']?.toString() ??
                                          '0',
                                    ),
                                    double.parse(
                                      _locationData!['longitude']?.toString() ??
                                          '0',
                                    ),
                                  ),
                                  zoom: 13,
                                ),
                                markers: _markers,
                                polylines: _polylines,
                                circles: _circles,
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                                compassEnabled: false,
                                mapToolbarEnabled: false,
                                myLocationEnabled: false,
                                mapType: MapType.normal,
                                onMapCreated: (controller) {
                                  _mapController = controller;
                                  _isMapReady = true;
                                  _setupMap();
                                },
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.access_time,
                                color: Colors.black87,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Arriving in $_arrivalTime minutes',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        if (_isNearDestination &&
                            !arrivalProvider.hasArrived) ...[
                          SizedBox(height: 16.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.green,
                                        size: 24.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'You are ${_distanceToDestination.round()}m from destination',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56.h,
                                  child: ElevatedButton(
                                    onPressed:
                                        arrivalProvider.isProcessingArrival
                                        ? null
                                        : _handleArrived,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: arrivalProvider.isProcessingArrival
                                        ? SizedBox(
                                            height: 24.h,
                                            width: 24.w,
                                            child:
                                                const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 28.sp,
                                              ),
                                              SizedBox(width: 12.w),
                                              Text(
                                                'I\'ve Arrived',
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],

                      SizedBox(height: 16.h),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showEndWorkOTPDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EndWorkOTPDialog(serviceId: widget.serviceId);
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Work completed successfully!',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      await _fetchServiceDetails();

      final startWorkProvider = Provider.of<StartWorkProvider>(
        context,
        listen: false,
      );
      startWorkProvider.reset();
    }
  }

  bool _shouldShowMap() {
    if (_serviceData == null) return false;
    final status = _serviceData!['status']?.toString().toLowerCase() ?? '';
    return status == 'assigned';
  }
}
