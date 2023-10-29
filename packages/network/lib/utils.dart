import 'package:_iwu_pack/_iwu_pack.dart';
import 'package:dio/dio.dart';

import 'network_resources/resources.dart';

Future<NetworkResponse<T>> handleNetworkError<T>({
  required Future<NetworkResponse<T>> Function() proccess,
  Function(DioException)? builder,
}) async {
  bool isDisconnect = await WifiService.isDisconnectWhenCallApi();
  if (isDisconnect) return NetworkResponse.withDisconnect();
  try {
    return await proccess.call();
  } on DioException catch (e) {
    appDebugPrint('DioException: $e');
    if (builder != null) {
      var _ = builder.call(e);
      if (_ is NetworkResponse<T>) return _;
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
