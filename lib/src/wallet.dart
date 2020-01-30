import 'package:jose/jose.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:libarweave/libarweave.dart';

class Wallet {
  JsonWebKey _wallet;
  String _owner;
  String _address;
  String api_url = "http://54.36.165.155:1984";

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
    var response = await http.get(api_url + '/wallet/' + _address + '/balance');
    return int.parse(response.body) / pow(10, 12);
  }

  Future<String> last_tx() async {
    var response = await http.get(api_url + '/wallet/' + _address + '/last_tx');
    return response.body;
  }

  Future<List> transactionHistory() async {
    final query = {
      'query':
          'query {transactions(from: ["${_address}"]){id tags{name value}}} '
    };
    final response = await http.post('http://54.36.165.155:1984/arql',
        body: jsonEncode(query));
    final txns = jsonDecode(response.body)['data']['transactions'];
    return txns;
  }
}
