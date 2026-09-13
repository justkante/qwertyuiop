import 'dart:developer';

import 'package:get_ip_address/get_ip_address.dart';

Future<String> getDeviceIP() async {
  try {
    /// Initialize Ip Address
    var ipAddress = IpAddress(type: RequestType.text);

    /// Get the IpAddress based on requestType.
    dynamic data = await ipAddress.getIpAddress();
    log(data.toString());
    return data.toString();
  } on IpAddressException catch (exception) {
    /// Handle the exception.
    throw exception.message;
  }
}
