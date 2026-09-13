class ResponseHandler {
  dynamic handleResponse({
    required Map<String, dynamic> response,
    required Function() onSuccess,
  }) {
    try {
      if (response['code'] != '200') {
        throw response['error']['message'];
      } else {
        return onSuccess();
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
