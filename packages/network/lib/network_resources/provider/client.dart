import 'dart:convert';

import 'package:_iwu_pack_network/options.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

class AppClient extends DioForNative {
  static AppClient? _instance;
  static bool _enableErrorHandler = true;

  factory AppClient(
      {required bool requiredToken,
      bool isAuthorizationCustom = false,
      String? token,
      String? baseUrl,
      bool enableErrorHandler = true,
      BaseOptions? options}) {
    _enableErrorHandler = enableErrorHandler;

    _instance ??= AppClient._(baseUrl: baseUrl ?? appBaseUrl, options: options);
    if (options != null) _instance!.options = options;
    _instance!.options.baseUrl = baseUrl ?? appBaseUrl;
    (_instance!.transformer as BackgroundTransformer).jsonDecodeCallback =
        parseJson;
    if ((token == null || token.isEmpty)) {
      _instance!.options.headers.remove(r'Authorization');
    } else if (requiredToken) {
      _instance!.options.headers.addAll({
        r'Authorization': isAuthorizationCustom ? token : ('Bearer $token')
      });
    }
    _instance!.options.headers.addAll(appHeaders);
    return _instance!;
  }

  AppClient._({String? baseUrl, BaseOptions? options}) : super(options) {
    interceptors.add(InterceptorsWrapper(
      onRequest: _requestInterceptor,
      onResponse: _responseInterceptor,
      onError: _errorInterceptor,
    ));
    if (networkOptions.loggingEnable) {
      interceptors.add(
        PrettyDioLogger(
          requestHeader: networkOptions.loggingrequestHeader,
          requestBody: networkOptions.loggingrequestBody,
          responseBody: networkOptions.loggingrequestBody,
          responseHeader: networkOptions.loggingrequestHeader,
          error: networkOptions.loggingerror,
          compact: networkOptions.loggingcompact,
          maxWidth: networkOptions.loggingmaxWidth,
        ),
      );
    }
    this.options.baseUrl = baseUrl ?? appBaseUrl;
  }

  _requestInterceptor(
      RequestOptions ops, RequestInterceptorHandler handler) async {
    switch (ops.method) {
      case methodGet:
        ops.queryParameters = appMapParms(ops.queryParameters);

        break;
      case methodPost:
      case methodPut:
      case methodDelete:
        if (ops.data is Map) {
          ops.data = appMapParms(ops.data);
        } else if (ops.data is FormData) {}
        break;
      default:
        break;
    }
    ops.connectTimeout = const Duration(seconds: 30000);
    ops.receiveTimeout = const Duration(seconds: 30000);
    handler.next(ops);
  }

  _responseInterceptor(Response r, ResponseInterceptorHandler handler) {
    handler.next(r);
  }

  _errorInterceptor(DioException e, ErrorInterceptorHandler handler) {
    if (_enableErrorHandler) {
      if (errorInterceptor != null) errorInterceptor!(e);
    }
    handler.next(e);
  }
}
