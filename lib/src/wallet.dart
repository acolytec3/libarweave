import 'package:jose/jose.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'package:libarweave/src/utils.dart';

class Wallet {
  JsonWebKey _wallet;
  String _owner;
  String _address;

  Wallet(String jsonWebKey) {
    var jwk = jsonDecode(jsonWebKey);
    _wallet = JsonWebKey.fromJson(jwk);
    _owner = jwk['n'];
    _address = base64Url.encode(sha256
        .convert(base64Url.decode(
            _owner + List.filled((4 - _owner.length % 4) % 4, '=').join()))
        .bytes);
    if (_address.endsWith('=')) {
      _address = _address.substring(0, _address.length - 1);
    }
  }

  void loadWallet(String jsonWebKey) {
    var jwk = jsonDecode(jsonWebKey);
    _wallet = JsonWebKey.fromJson(jwk);
    _owner = jwk['n'];
    _address = base64Url.encode(sha256
        .convert(base64Url.decode(
            _owner + List.filled((4 - _owner.length % 4) % 4, '=').join()))
        .bytes);
    if (_address.endsWith('=')) {
      _address = _address.substring(0, _address.length - 1);
    }
  }

  String get address {
    return _address;
  }

  Future<double> balance() async {
    var response = await getHttp('/wallet/$_address/balance');
    return int.parse(response) / pow(10, 12);
  }

  Future<String> last_tx() async {
    var response = await getHttp('/wallet/$_address/last_tx');
    return response;
  }

  Future<List> dataTransactionHistory() async {
    final query = {
      'query':
          'query {transactions(from: ["${_address}"]){id tags{name value}}} '
    };
    final response = await postHttp('/arql', jsonEncode(query));
    if (response != '') {
      final txns = jsonDecode(response)['data']['transactions'];
      return txns;
    }
    return [];
  }
}
