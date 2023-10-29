import 'dart:collection';
 
import 'package:_iwu_pack/setup/index.dart';
import 'package:dio/dio.dart';

import 'network_resources/resources.dart';
 

const String methodGet = "GET";
const String methodPost = "POST";
const String methodPut = "PUT";
const String methodDelete = "DELETE";

var appHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Credentials": true,
  "Access-Control-Allow-Headers":
      "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
  "Access-Control-Allow-Methods": "POST, OPTIONS"
};

Map<String, dynamic> appMapParms([Map? value]) {
  Map<String, dynamic> params = {};
  if (value != null && value.isNotEmpty) {
    params.addAll(HashMap.from(value));
  }
  // params..removeWhere((key, value) => value == null)
      // ..addAll({
      //   'platformId': valuePlatformByConfig(),
      //   'languageCode': appPrefs.languageCode,
      // })
  return params;
}

PNetworkOptionsImpl get networkOptions =>
    appSetup.networkOptions as PNetworkOptionsImpl;

String get appBaseUrl => networkOptions.baseUrl;
String get appBaseUrlAsset => networkOptions.baseUrlAsset; 
String? get appMqttUrl => networkOptions.mqttUrl;
int? get appMqttPort => networkOptions.mqttPort;
Function(DioException)? get errorInterceptor => networkOptions.errorInterceptor;

class PNetworkOptionsImpl extends PNetworkOptions {
  final Function(DioException)? errorInterceptor;

  final String? responsePrefixData;
  final bool Function(NetworkResponse response)? responseIsSuccess;

  //loging setting
  final bool loggingEnable;
  final bool loggingrequestHeader;
  final bool loggingrequestBody;
  final bool loggingresponseBody;
  final bool loggingresponseHeader;
  final bool loggingerror;
  final bool loggingcompact;
  final int loggingmaxWidth;

  PNetworkOptionsImpl({
    required super.baseUrl,
    required super.baseUrlAsset, 
    super.mqttUrl,
    super.mqttPort,
    this.errorInterceptor,
    this.loggingEnable = true,
    this.loggingrequestHeader = false,
    this.loggingrequestBody = true,
    this.loggingresponseBody = true,
    this.loggingresponseHeader = false,
    this.loggingerror = true,
    this.loggingcompact = true,
    this.loggingmaxWidth = 120,
    this.responsePrefixData,
    this.responseIsSuccess,
  });
}
