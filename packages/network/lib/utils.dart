import 'package:_iwu_pack/_iwu_pack.dart';
import 'package:dio/dio.dart';

import 'network_resources/resources.dart';

Future<NetworkResponse> handleNetworkError({
  required Future<NetworkResponse> Function() proccess,
  Function(DioException)? builder,
}) async {
  bool isDisconnect = await WifiService.isDisconnectWhenCallApi();
  if (isDisconnect) return NetworkResponse.withDisconnect();
  try {
    return proccess.call();
  } on DioException catch (e) {
    appDebugPrint('DioException: $e');
    if (builder != null) {
      var _ = builder.call(e);
      if (_ is NetworkResponse) return _;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkResponse.withDisconnect();
    }
    return NetworkResponse.withErrorRequest(e);
  } catch (e) {
    return NetworkResponse.withErrorConvert(e);
  }
}
