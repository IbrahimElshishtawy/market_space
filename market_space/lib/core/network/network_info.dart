import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  const NetworkInfoImpl({
    required this.connectivity,
  });

  @override
  Future<bool> get isConnected async {
    final connectivityResults = await connectivity.checkConnectivity();
    return !connectivityResults.contains(ConnectivityResult.none);
  }
}
