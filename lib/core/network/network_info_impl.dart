import 'package:expiry_wise_app/core/network/network_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';


class NetworkInfoImpl implements NetworkInfo{

  NetworkInfoImpl();

  @override
  Future<bool> get checkInternetStatus async => await InternetConnection().hasInternetAccess;

}

final networkInfoProvider = Provider<NetworkInfoImpl>((Ref ref){
  return NetworkInfoImpl();
});