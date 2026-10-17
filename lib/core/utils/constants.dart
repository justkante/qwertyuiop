class PrefKeys {
  static const token = 'token';
  static const password = 'userPassword';
}

class Constants {
  static const url = "https://creatifyapp.com";
  static const termsAndConditionsUrl = 'https://creatifyapp.com/terms-of-service';
  static const privacyPolicyUrl = 'https://creatifyapp.com/privacy-policy';
}

/// Safely parse response message from API response data, preventing null reference errors on buttons/actions
String parseResponseMessage(dynamic responseData, [String defaultMsg = 'Operation successful']) {
  if (responseData is Map) {
    return responseData['message']?.toString() ??
           responseData['status']?.toString() ??
           defaultMsg;
  }
  return defaultMsg;
}
