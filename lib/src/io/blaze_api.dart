import 'dart:convert';
import 'package:http/http.dart' as http;

final blazeApi = BlazeApi();

class BlazeApi {
  // static const blazeKey = '00277013413d772cb0f5e45509ad4535567695cf17';
  static const appKey = '002acb3ebf7beb00000000003';
  static const masterKey = 'K002ZIkwJP72HrfkHfb8UkpApcmR764';
  final bucketId = 'aaec7b23be3baf777bae0b10';

  late final headerAuthKey = {
    'Authorization':
        'Basic ' + base64.encode(utf8.encode('$appKey:$masterKey')),
  };
  Future<void> _auth() async {
    final url = 'https://api.backblazeb2.com/b2api/v2/b2_authorize_account';
    var response = await http.get(
      Uri.parse(url),
      headers: headerAuthKey,
    );
    // _authResponse = jsonDecode(response.body);
    // _authToken = _authResponse['authorizationToken'];
    // _apiUrl = _authResponse['apiUrl'];
    // trace("auth response: ", response.body);
    // print(_authToken);
    // 4_002acb3ebf7beb00000000003_019d9d5c_cfc3b9_acct_XjhEA0aFGpwu0ogx0roxPAvGtHI
    // _getUploadUrl();
  }

  /// todo: implement the file uploader.

}
