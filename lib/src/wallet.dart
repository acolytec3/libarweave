import 'package:jose/jose.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:libarweave/src/utils.dart';
import 'package:pointycastle/export.dart';

class Wallet {
  JsonWebKey _wallet;
  String _owner;
  String _address;
  dynamic _jwk;

  Wallet({String jsonWebKey}) {
    if (jsonWebKey != null) {
      _jwk = jsonDecode(jsonWebKey);
      _wallet = JsonWebKey.fromJson(_jwk);
      _owner = _jwk['n'];
      _address = base64Url.encode(sha256
          .convert(base64Url.decode(
              _owner + List.filled((4 - _owner.length % 4) % 4, '=').join()))
          .bytes);
      if (_address.endsWith('=')) {
        _address = _address.substring(0, _address.length - 1);
      }
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

  JsonWebKey get jwk {
    return _wallet;
  }

  Future<double> balance() async {
    var response = await getHttp('/wallet/$_address/balance');
    return winstonToAr(response);
  }

  Future<String> lastTransaction() async {
    var response = await getHttp('/wallet/$_address/last_tx');
    return response;
  }

  Future<List> allTransactionsFromAddress() async {
    final response = await getHttp('/wallet/$_address/txs/');
    return jsonDecode(response);
  }

  Future<List> allTransactionsToAddress() async {
    final response = await getHttp('/wallet/$_address/deposits/');
    return jsonDecode(response);
  }

  Future<List> dataTransactionHistory() async {
    final query = {
      'query':
          'query {transactions(from: ["${_address}"]){id tags{name value}}} '
    };
    final response = await postHttp('/arql', jsonEncode(query));
    if (response.body != '') {
      final txns = jsonDecode(response.body)['data']['transactions'];
      return txns;
    }
    return [];
  }

  List<int> createTransaction(String lastTx, String reward,
      {String targetAddress = '',
      List tags,
      String quantity = '0',
      List<int> data}) {
    final dataBytes =
        decodeBase64EncodedBytes(encodeBase64EncodedBytes(data));
    final lastTxBytes = decodeBase64EncodedBytes(lastTx);
    final targetBytes = decodeBase64EncodedBytes(targetAddress);
    final ownerBytes = decodeBase64EncodedBytes(_owner);
    final rewardBytes = utf8.encode(reward);
    final quantityBytes = utf8.encode(quantity);
    List<int> tagsBytes = [] ;

    
    if (tags != null) {
      for (var tag in tags) {
        tagsBytes += decodeBase64EncodedBytes(
            encodeBase64EncodedBytes(utf8.encode(tag['name'])));
        tagsBytes += decodeBase64EncodedBytes(
            encodeBase64EncodedBytes(utf8.encode(tag['value'])));
      }
    } else {
      tagsBytes = [];
    }

    print('Tags are: ${tags.toString()}');
    print('Tag bytes: ${tagsBytes.toString()}');
    var rawTransaction = ownerBytes +
        targetBytes +
        dataBytes +
        quantityBytes +
        rewardBytes +
        lastTxBytes +
        tagsBytes;

    return rawTransaction;
  }

  Future<dynamic> postTransaction(
      List<int> signature, String lastTx, String reward,
      {String targetAddress = '',
      List tags,
      String quantity = '0',
      List<int> data}) async {
    final digest = SHA256Digest();
    final hash = digest.process(signature);
    List tagsB64;
    if (tags != null) {
      for (var tag in tags) {
        if (tagsB64 != null) {
          print('Adding tag: ${tag.toString()}');
          tagsB64.add({
            'name': encodeBase64EncodedBytes(utf8.encode(tag['name'])),
                'value': encodeBase64EncodedBytes(utf8.encode(tag['value']))
          });
        } else {
          print('Adding tag: ${tag.toString()}');
          tagsB64 = [
            {
              'name': (encodeBase64EncodedBytes(utf8.encode(tag['name']))),
                  'value':(encodeBase64EncodedBytes(utf8.encode(tag['value'])))
            }
          ];
        }
      }
    }
    final id = encodeBase64EncodedBytes(hash);
    print('Transaction ID is: $id');
    final body = json.encode({
      'id': id,
      'last_tx': lastTx,
      'owner': _owner,
      'tags': tagsB64,
      'target': encodeBase64EncodedBytes(utf8.encode(targetAddress)),
      'reward': reward,
      'quantity': quantity,
      'data': encodeBase64EncodedBytes(data),
      'signature': encodeBase64EncodedBytes(signature)
    });
    final response = await postHttp('/tx', body);
    return response;
  }
}
